/*/�������� ������� (DSU-4)
 �������� ������� �� ����� SQL-27*/ -- ����� ��������� 06.05.21 (��.����������� �� ������ ����)
--1) � ����� ������� ������ ������ ���������?
 select ap.city
 from airports ap
 group by ap.city
 having count(ap.city)>1;

--2) � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
--� ������� ����������� ������ ���� ������������: 
--���������
select f.departure_airport --���������, ���� �� ����� ����� ��� "������������ �������" ����� �� ��� ����������, �� ������� ������� ����� ��������.
--���� �� �������� � ���, ��� �� ����� ������������, �� ����������� ��� ������� ����������� �� f.arrival_airport. 
--������� ��������� ("���") ���������� ����� ������, �� � ��� ����� ����������� �� �� �� 7 ���������� ����������, ��� �������.
from flights f 
join aircrafts ac on ac.aircraft_code = f.aircraft_code
where ac."range" in (select max("range") from aircrafts)
group by f.departure_airport;

--3) ������� 10 ������ � ������������ �������� �������� ������
--� ������� ����������� ������ ���� ������������: 
--�������� LIMIT
select f.flight_id, f.flight_no, max(f.actual_departure - f.scheduled_departure) as max_delay, f.scheduled_departure, f.actual_departure 
from flights f 
where f.actual_departure is not null --����� ������ ���������� ������� �����
group by f.flight_id
order by max_delay desc
limit 10;

--4) ���� �� �����, �� ������� �� ���� �������� ���������� ������?
--� ������� ����������� ������ ���� ������������: 
-- ������ ��� JOIN
select b.book_ref, bp.boarding_no
from bookings b
left join tickets t on t.book_ref = b.book_ref 
left join boarding_passes bp on bp.ticket_no = t.ticket_no 
where bp.boarding_no is null
group by b.book_ref, bp.boarding_no;

--5) ������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����.
--� ������� ����������� ������ ���� ������������: 
-- - ������� �������
-- - ����������

--���������� �� 06.05.21: ������ ��������� ������ �� ���������� �������, � �� �������, ��� ���� ������� �����
select bp.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport,  
	count(bp.seat_no) as used_seats, --������� ���������� ������� ���� (�� ������� ������ ���������� ������) 
	cap.capacity, 
	100 - round(count(bp.seat_no)/cap.capacity::numeric*100, 1) as free_seats_percent-- ��������� % ��������� ���� ���������� �� 100
	--count(f.actual_departure) over (partition by f.departure_airport)  --[������� ������� ������ ���������� ������������ ���������, � �� ����������, � ����� �� ���� ������ �� ����������...]
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

--���������� �� 06.05.21: 
--������� ������� ������ �������� ������� ���� (�� ������� ���������� ������ ���������� ������), � �� ���������...
select f.flight_id, f.flight_no, f.status, f.aircraft_code, bp.boarding_no, bp.seat_no 
from flights f
join boarding_passes bp on bp.flight_id = f.flight_id 
left join (
	select s.seat_no 
	from seats s
	) seats_all on seats_all.seat_no is null 
where bp.boarding_no is not null;

--6) ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
--� ������� ����������� ������ ���� ������������: 
-- - ���������
-- - �������� ROUND
--[�� ������ �������, ��������� ���� (��� ������������ � ��� ������ ���������������), ��� �� ������ ������������? �������� �� ���� ���������]
select f2.aircraft_code, 
	count(f2.aircraft_code) as total_by_aircraft, 
	(select count(*) from flights) as total,
	round(count(f2.aircraft_code)/(select count(*) from flights)::numeric*100,2) as aircraft_percentage
from flights f2 
group by f2.aircraft_code 
order by total_by_aircraft desc

--7) ���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?
--� ������� ����������� ������ ���� ������������: 
-- - CTE
with flight_conditions as (
	--���� ������ � ������ ����������� ��������, � �� ����� ���� ���������:	
	select tf.flight_id, a2.city, tf.fare_conditions, min(tf.amount) as min_amount, max(tf.amount) as max_amount  
	--(�����������: ���� �� ���� ����� ����� ���� ���������, �� ����������� �� tf.flight_id ���������� ������)
	from flights f3
	join ticket_flights tf using (flight_id)
	join airports a2 on a2.airport_code = f3.arrival_airport --���������� �������� ��������
	group by tf.flight_id, a2.city, tf.fare_conditions
	)
select flight_conditions.flight_id, flight_conditions.city, min_business.min_business_amount, max_economy.max_economy_amount, (min_business.min_business_amount - max_economy.max_economy_amount) as delta
from flight_conditions
join ( 
	select flight_conditions.flight_id, flight_conditions.min_amount as min_business_amount --������� ����������� ��������� ������-������ � ������ ����������� ��������(flight_id)
	from flight_conditions 
	where flight_conditions.fare_conditions = 'Business'
	group by flight_conditions.flight_id, flight_conditions.min_amount) min_business on min_business.flight_id = flight_conditions.flight_id
join (
	select flight_conditions.flight_id, flight_conditions.max_amount as max_economy_amount --������� ������������ ��������� ������-������ � ������ ����������� ��������(flight_id)
	from flight_conditions 
	where flight_conditions.fare_conditions = 'Economy'
	group by flight_conditions.flight_id, flight_conditions.max_amount) max_economy on max_economy.flight_id = flight_conditions.flight_id
where min_business.min_business_amount < max_economy.max_economy_amount 
group by flight_conditions.flight_id, flight_conditions.city, min_business.min_business_amount, max_economy.max_economy_amount;
-- ����� �� 26.04.21: ������� ����� ����� ������� ������-������� � ����� ������� ������-������� �� ���������� ��������� ���������� �� 12700 �� 135500 ���.
-- �������������, �������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������, �� ����.
-- [���� �� ��������� �� ���� ��������� � �����, �� ����� ������ ���� - ��������, �����.]
--���������� �� 06.05.21: ������� ������� "where min_business.min_business_amount < max_economy.max_economy_amount". 
--������ ������ ������� 0 �����, �.�. �������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������, �� ����.


--���������� �� 06.05.21:
--8) ����� ������ �������� ��� ������ ������?
--� ������� ����������� ������ ���� ������������: 
-- - ��������� ������������ � ����������� FROM
-- - �������������� ��������� ������������� --[�� ������ �����, � ����� ����� ��������� �������������]
-- - �������� EXCEPT
select a2.city as city_1, a3.city as city_2 
from airports a2 
cross join airports a3 --���������� ��������� ������������: ��������� ������� "���-��-����", �.�. ������� ����� ��������� �������, � ������� ���� ���������
except ( --"��������" �� �������������� ���� ������� "���-��-����" ������� ������ ��������� ����� ��������, 
	--�������������� � ���������� �� ��������� ������� ��������� (flights) � ������ �������������� �������� ���������� (���������� ��� ���������, 
	--�.�. � ����� ������ ����� ���� ��������� ���������� - ��������, � ������ � ����������):
	select dep.city as departure_city, arr.city as arrival_city
	from flights f
	join airports dep on dep.airport_code = f.departure_airport 
	join airports arr on arr.airport_code = f.arrival_airport
	group by dep.city, arr.city)
order by city_1; --���������� �� ������_1 ��� ������������ �����������

/*���������� �� 06.05.21:
--9) ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, ������������� ��� �����.
--� ������� ����������� ������ ���� ������������: 
-- - �������� RADIANS ��� ������������� sind/cosd
� ��������� ���� ���������� ��������� � �������� airports.longitude � airports.latitude.
���������� ���������� ����� ����� ������� A � B �� ������ ����������� (���� ������� �� �� �����) ������������ ������������:
d = arccos {sin(latitude_a)�sin(latitude_b) + cos(latitude_a)�cos(latitude_b)�cos(longitude_a - longitude_b)}, ��� latitude_a � latitude_b � ������, longitude_a, longitude_b � ������� ������ �������, d � ���������� ����� �������� ���������� � �������� ������ ���� �������� ����� ������� ����.
���������� ����� ��������, ���������� � ����������, ������������ �� �������:
L = d�R, ��� R = 6371 �� � ������� ������ ������� ����.*/

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

--�����: �� ���� ������ ������������ ��������� ������ ����.����� ��������� ���������� ����� �����������, 
--�� ���� "�����������" �����, ��� ������ ���������� (��������, ������-�������� 6(14)��, ����������� - ��������� 15��, ��������� - ����� 17��).
