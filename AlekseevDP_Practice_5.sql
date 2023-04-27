/*Алексеев Д.П. (DSU-4)
 SQL-27
Домашнее задание по теме “Работа с PostgreSQL” (#5)
База данных: dvd-rental
Основная часть:
1.	Сделайте запрос к таблице rental. Используя оконную функцию добавьте колонку с порядковым номером аренды для каждого пользователя (сортировать по rental_date)*/
select r.customer_id, r.rental_date,
	row_number() over (partition by r.customer_id order by r.rental_date), --колонка с порядковым номером аренды для каждого пользователя
	r.inventory_id, r.return_date 
from rental r 

/*2.	Для каждого пользователя подсчитайте сколько он брал в аренду фильмов со специальным атрибутом Behind the Scenes
-напишите этот запрос
-создайте материализованное представление с этим запросом
-обновите материализованное представление
-напишите три варианта условия для поиска Behind the Scenes*/

/*[справочно: вывод всей таблицы для проверки: select r.customer_id, f.film_id, f.title, f.special_features 
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where f.special_features::text ilike '%Behind the Scenes%'
group by r.customer_id, f.film_id 
order by r.customer_id;]*/

--напишите этот запрос:
select distinct r.customer_id, 
	count(f.film_id) over (partition by r.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where f.special_features::text ilike '%Behind the Scenes%'
group by r.customer_id, f.film_id

--создайте материализованное представление с этим запросом:
create materialized view Behind_the_Scenes as
	select distinct r.customer_id, 
		count(f.film_id) over (partition by r.customer_id)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id 
	join film f on f.film_id = i.film_id
	where f.special_features::text ilike '%Behind the Scenes%'
	group by r.customer_id, f.film_id
with NO data;

--обновите материализованное представление:
refresh materialized view Behind_the_Scenes;

--напишите три варианта условия для поиска Behind the Scenes:
--0) вариант, который использовался выше:
select distinct r.customer_id, 
	count(f.film_id) over (partition by r.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where f.special_features::text ilike '%Behind the Scenes%'
group by r.customer_id, f.film_id

--1) 
select distinct r.customer_id, 
	count(f.film_id) over (partition by r.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where array_position(f.special_features, 'Behind the Scenes') is not null
group by r.customer_id, f.film_id
order by r.customer_id;

--2)
select distinct r.customer_id, 
	count(f.film_id) over (partition by r.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where f.special_features @> array['Behind the Scenes'] 
group by r.customer_id, f.film_id
order by r.customer_id;

--3)
select distinct r.customer_id, 
	count(f.film_id) over (partition by r.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where special_features && array['Behind the Scenes'] 
group by r.customer_id, f.film_id
order by r.customer_id;
