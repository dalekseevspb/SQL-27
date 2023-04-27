--вывести всех неактивных покупателей:
select c.customer_id, c.first_name, c.last_name, c.active 
from customer c
where active = 0
order by customer_id;

--вывести все фильмы, выпущенные в 2006 году
select f.film_id, f.title, f.release_year 
from film f 
where release_year = 2006
order by film_id;

--вывести 10 последних платежей за прокат фильмов
select p.payment_id, p.customer_id, p.amount, p.payment_date 
from payment p 
order by payment_date desc 
limit 10

--ƒополнительна€ часть:
---вывести первичные ключи через запрос. ƒл€ написани€ простого запроса можете воспользоватьс€ information_schema.table_constraints
select tc.constraint_name, tc.table_name, tc.constraint_type
from information_schema.table_constraints tc 
where constraint_type ='PRIMARY KEY'

---расширить запрос с первичными ключами, добавив информацию по типу данных information_schema.columns
--[Ќе совсем пон€л задачу, нужно решить с JOIN или без?]
select *
from information_schema."columns" c
where column_default is not null and column_name ilike ('%id');


--ƒополнение (корректное решение с использованием JOIN - ??? добавлено из —лака, не отрабатывает??):
select tc.table_name, kcu.column_name, tc.constraint_name, c.data_type
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu on kcu.constraint_name = tc.constraint_name 
	and tc.table_name = kcu.table_name 
	and tc.constraint_schema = kcu.constraint_schema
left join information_schema.columns c on c.column_name = kcu.column_name 
	and kcu.table_name = c.table_name 
	and kcu.constraint_schema = c.table_schema
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY';

