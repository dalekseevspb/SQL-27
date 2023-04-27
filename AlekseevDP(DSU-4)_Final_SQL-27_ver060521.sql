/*/Алексеев Дмитрий (DSU-4)
 Итоговое задание по курсу SQL-27*/ -- ПОСЛЕ ДОРАБОТКИ 06.05.21 (см.комментарии по тексту ниже)
--1) В каких городах больше одного аэропорта?
 select ap.city
 from airports ap
 group by ap.city
 having count(ap.city)>1;

--2) В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--В решении обязательно должно быть использовано: 
--Подзапрос
select f.departure_airport --актуально, если мы имеем ввиду под "выполняемыми рейсами" рейсы из тех аэропортов, из которых самолет может вылететь.
--Если же говорить о тех, где он может приземлиться, то добавляется ещё уровень группировки по f.arrival_airport. 
--Таблица сочетаний ("пар") аэропортов будет больше, но в ней будут встречаться всё те же 7 уникальных аэропортов, что логично.
from flights f 
join aircrafts ac on ac.aircraft_code = f.aircraft_code
where ac."range" in (select max("range") from aircrafts)
group by f.departure_airport;

--3) Вывести 10 рейсов с максимальным временем задержки вылета
--В решении обязательно должно быть использовано: 
--Оператор LIMIT
select f.flight_id, f.flight_no, max(f.actual_departure - f.scheduled_departure) as max_delay, f.scheduled_departure, f.actual_departure 
from flights f 
where f.actual_departure is not null --берем только фактически начатые рейсы
group by f.flight_id
order by max_delay desc
limit 10;

--4) Были ли брони, по которым не были получены посадочные талоны?
--В решении обязательно должно быть использовано: 
-- Верный тип JOIN
select b.book_ref, bp.boarding_no
from bookings b
left join tickets t on t.book_ref = b.book_ref 
left join boarding_passes bp on bp.ticket_no = t.ticket_no 
where bp.boarding_no is null
group by b.book_ref, bp.boarding_no;

--5) Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
--В решении обязательно должно быть использовано: 
-- - Оконная функция
-- - Подзапросы

--Дополнение от 06.05.21: запрос переделан исходя из посадочных талонов, а не билетов, как было сделано ранее
select bp.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport,  
	count(bp.seat_no) as used_seats, --считаем количество занятых мест (на которые выданы посадочные талоны) 
	cap.capacity, 
	100 - round(count(bp.seat_no)/cap.capacity::numeric*100, 1) as free_seats_percent-- Вычисляем % свободных мест вычитанием из 100
	--count(f.actual_departure) over (partition by f.departure_airport)  --[Удалось вывести только количество отправленных самолетов, а не пассажиров, в целом за весь период по аэропортам...]
from boarding_passes bp
join flights f on f.flight_id = bp.flight_id 
join (
	select a.aircraft_code, count(s.seat_no) as capacity
	from aircrafts a 
	join seats s on s.aircraft_code = a.aircraft_code 
	group by a.aircraft_code) cap on cap.aircraft_code = f.aircraft_code
where f.actual_departure is not null
group by bp.flight_id, f.flight_no, f.scheduled_departure, cap.capacity, f.departure_airport 
order by f.scheduled_departure; 

--Дополнение от 06.05.21: 
--Удалось вывести только перечень занятых мест (по которым фактически выданы посадочные талоны), а не свободных...
select f.flight_id, f.flight_no, f.status, f.aircraft_code, bp.boarding_no, bp.seat_no 
from flights f
join boarding_passes bp on bp.flight_id = f.flight_id 
left join (
	select s.seat_no 
	from seats s
	) seats_all on seats_all.seat_no is null 
where bp.boarding_no is not null;

--6) Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--В решении обязательно должно быть использовано: 
-- - Подзапрос
-- - Оператор ROUND
--[не совсем понятно, перелетов всех (уже состоявшихся и ещё только запланированных), или же только состоявшихся? Посчитал от всех перелетов]
select f2.aircraft_code, 
	count(f2.aircraft_code) as total_by_aircraft, 
	(select count(*) from flights) as total,
	round(count(f2.aircraft_code)/(select count(*) from flights)::numeric*100,2) as aircraft_percentage
from flights f2 
group by f2.aircraft_code 
order by total_by_aircraft desc

--7) Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
--В решении обязательно должно быть использовано: 
-- - CTE
with flight_conditions as (
	--если именно в рамках конкретного перелета, а не среди всех перелетов:	
	select tf.flight_id, a2.city, tf.fare_conditions, min(tf.amount) as min_amount, max(tf.amount) as max_amount  
	--(продолжение: если же надо найти среди всех перелетов, то группировку по tf.flight_id необходимо убрать)
	from flights f3
	join ticket_flights tf using (flight_id)
	join airports a2 on a2.airport_code = f3.arrival_airport --используем аэропорт прибытия
	group by tf.flight_id, a2.city, tf.fare_conditions
	)
select flight_conditions.flight_id, flight_conditions.city, min_business.min_business_amount, max_economy.max_economy_amount, (min_business.min_business_amount - max_economy.max_economy_amount) as delta
from flight_conditions
join ( 
	select flight_conditions.flight_id, flight_conditions.min_amount as min_business_amount --находим минимальную стоимость бизнес-класса в рамках конкретного перелета(flight_id)
	from flight_conditions 
	where flight_conditions.fare_conditions = 'Business'
	group by flight_conditions.flight_id, flight_conditions.min_amount) min_business on min_business.flight_id = flight_conditions.flight_id
join (
	select flight_conditions.flight_id, flight_conditions.max_amount as max_economy_amount --находим максимальную стоимость эконом-класса в рамках конкретного перелета(flight_id)
	from flight_conditions 
	where flight_conditions.fare_conditions = 'Economy'
	group by flight_conditions.flight_id, flight_conditions.max_amount) max_economy on max_economy.flight_id = flight_conditions.flight_id
where min_business.min_business_amount < max_economy.max_economy_amount 
group by flight_conditions.flight_id, flight_conditions.city, min_business.min_business_amount, max_economy.max_economy_amount;
-- Ответ от 26.04.21: разница между самым дешевым бизнес-классом и самым дорогим эконом-классом по конкретным перелетам составляет от 12700 до 135500 руб.
-- Следовательно, городов, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета, не было.
-- [Если же оценивать по всем перелетам в целом, то такие города были - например, Киров.]
--Дополнение от 06.05.21: добавил условие "where min_business.min_business_amount < max_economy.max_economy_amount". 
--Теперь запрос выводит 0 строк, т.е. городов, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета, не было.


--Дополнение от 06.05.21:
--8) Между какими городами нет прямых рейсов?
--В решении обязательно должно быть использовано: 
-- - Декартово произведение в предложении FROM
-- - Самостоятельно созданные представления --[Не совсем понял, с какой целью создавать представление]
-- - Оператор EXCEPT
select a2.city as city_1, a3.city as city_2 
from airports a2 
cross join airports a3 --используем Декартово произведение: формируем таблицу "все-ко-всем", т.е. таблицу любых сочетаний городов, в которых есть аэропорты
except ( --"Вычитаем" из сформированной выше таблицы "все-ко-всем" таблицу прямых сообщений между городами, 
	--сформированную в подзапросе на основании таблицы перелетов (flights) с дважды присоединенной таблицей аэропортов (используем код аэропорта, 
	--т.к. в одном городе может быть несколько аэропортов - например, в Москве и Ульяновске):
	select dep.city as departure_city, arr.city as arrival_city
	from flights f
	join airports dep on dep.airport_code = f.departure_airport 
	join airports arr on arr.airport_code = f.arrival_airport
	group by dep.city, arr.city)
order by city_1; --сортировка по городу_1 для упорядочения результатов

/*Дополнение от 06.05.21:
--9) Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы.
--В решении обязательно должно быть использовано: 
-- - Оператор RADIANS или использование sind/cosd
В локальной базе координаты находятся в столбцах airports.longitude и airports.latitude.
Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять ее за сферу) определяется зависимостью:
d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)}, где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, d — расстояние между пунктами измеряется в радианах длиной дуги большого круга земного шара.
Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
L = d·R, где R = 6371 км — средний радиус земного шара.*/

select f.flight_no, f.aircraft_code, ac."range" as max_range, dep.airport_code as dep_airport, dep.city as departure_city, dep.latitude as dep_lat, dep.longitude as dep_long,
arr.airport_code as arr_airport, arr.city as arrival_city, arr.latitude as arr_lat, arr.longitude as arr_long,
round((acos(sind(dep.latitude)*sind(arr.latitude) + cosd(dep.latitude)*cosd(arr.latitude)*cosd(dep.longitude-arr.longitude))*6371)::numeric, 0) as Distance_in_km,
(ac."range" - round((acos(sind(dep.latitude)*sind(arr.latitude) + cosd(dep.latitude)*cosd(arr.latitude)*cosd(dep.longitude-arr.longitude))*6371)::numeric, 0)) as Delta
from flights f
join airports dep on dep.airport_code = f.departure_airport 
join airports arr on arr.airport_code = f.arrival_airport
join aircrafts ac on ac.aircraft_code = f.aircraft_code 
group by f.flight_no, f.aircraft_code, ac."range", dep.airport_code, dep.city, arr.airport_code, arr.city
order by Delta asc;

--Ответ: на всех рейсах максимальная дальность полета возд.судна превышает расстояние между аэропортами, 
--но есть "критические" рейсы, где дельта минимальна (например, Москва-Кемерово 6(14)км, Новокузнецк - Череповец 15км, Ярославль - Томск 17км).
