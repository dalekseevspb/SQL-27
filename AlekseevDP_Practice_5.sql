/*�������� �.�. (DSU-4)
 SQL-27
�������� ������� �� ���� ������� � PostgreSQL� (#5)
���� ������: dvd-rental
�������� �����:
1.	�������� ������ � ������� rental. ��������� ������� ������� �������� ������� � ���������� ������� ������ ��� ������� ������������ (����������� �� rental_date)*/
select r.customer_id, r.rental_date,
	row_number() over (partition by r.customer_id order by r.rental_date), --������� � ���������� ������� ������ ��� ������� ������������
	r.inventory_id, r.return_date 
from rental r 

/*2.	��� ������� ������������ ����������� ������� �� ���� � ������ ������� �� ����������� ��������� Behind the Scenes
-�������� ���� ������
-�������� ����������������� ������������� � ���� ��������
-�������� ����������������� �������������
-�������� ��� �������� ������� ��� ������ Behind the Scenes*/

/*[���������: ����� ���� ������� ��� ��������: select r.customer_id, f.film_id, f.title, f.special_features 
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where f.special_features::text ilike '%Behind the Scenes%'
group by r.customer_id, f.film_id 
order by r.customer_id;]*/

--�������� ���� ������:
select distinct r.customer_id, 
	count(f.film_id) over (partition by r.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where f.special_features::text ilike '%Behind the Scenes%'
group by r.customer_id, f.film_id

--�������� ����������������� ������������� � ���� ��������:
create materialized view Behind_the_Scenes as
	select distinct r.customer_id, 
		count(f.film_id) over (partition by r.customer_id)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id 
	join film f on f.film_id = i.film_id
	where f.special_features::text ilike '%Behind the Scenes%'
	group by r.customer_id, f.film_id
with NO data;

--�������� ����������������� �������������:
refresh materialized view Behind_the_Scenes;

--�������� ��� �������� ������� ��� ������ Behind the Scenes:
--0) �������, ������� ������������� ����:
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
