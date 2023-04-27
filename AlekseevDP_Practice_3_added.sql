/*/�������� �.�., �������� �3
 �������� ������� �� ���� ������� SQL�
���� ������: dvd-rental
�������� �����:
-�������� ��������, ������� ������ 300-�� �����������
-�������� � ������� ���������� ����� � ������� �� �����
�������������� �����:
-�������� ��� ����������� � ������ ���������, ������� ������ 300-�� �����������
-�������� ���������� �������, ����������� � �������, ������� ������� � ������ �� 2,99

�������� �����:
-�������� ��������, ������� ������ 300-�� �����������*/
select c.store_id, count(c.store_id)
from customer c
group by c.store_id
having count(c.store_id)>300;

--�������� � ������� ���������� ����� � ������� �� �����
select c.customer_id, c.address_id, a.city_id, city.city 
from customer c 
join address a on a.address_id = c.address_id
join city on city.city_id = a.city_id  

--�������������� �����:
---�������� ��� ����������� � ������ ���������, ������� ������ 300-�� �����������
select c.store_id, store.address_id, a.city_id, city.city, store.manager_staff_id, staff.first_name, staff.last_name 
from customer c
join store on store.store_id = c.store_id 
join address a on a.address_id = store.address_id 
join city on city.city_id = a.city_id 
join staff on staff.store_id = store.store_id 
group by c.store_id, store.address_id, a.city_id, city.city, store.manager_staff_id, staff.first_name, staff.last_name
having count(c.store_id)>300;

--����� ������������� (�.�������):
--� ������ �������������� ����� ������������ ���������� � ������� �� ������������� �����������:
select ci.city, concat(st.last_name, ' ', st.first_name) as name
from staff st
left join store s on s.store_id = st.store_id 
left join address a on s.address_id = a.address_id 
left join city ci on ci.city_id = a.city_id
where st.store_id in 
	(select c.store_id
	from customer c
	group by c.store_id
	having count(c.customer_id) > 300)
	
select ci.city, concat(st.last_name, ' ', st.first_name) as name
from (select c.store_id
	from customer c
	group by c.store_id
	having count(c.customer_id) > 300) as t
left join store s on s.store_id = t.store_id 
left join staff st on st.store_id = s.store_id
left join address a on s.address_id = a.address_id 
left join city ci on ci.city_id = a.city_id

---�������� ���������� �������, ����������� � �������, ������� ������� � ������ �� 2,99
--[�������������� ������� � ���������� ����������, �� ��-������� �� ��������]--
select count (distinct actor_id)
from (
select p.payment_id, r.rental_id, r.inventory_id, i.film_id, f.title 
from payment p
join rental r on r.rental_id = p.rental_id 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
group by p.payment_id, r.rental_id, r.inventory_id, i.film_id, f.title 
having amount = 2.99) as t1
join film_actor fa on fa.film_id = t1.film_id 

--����� ������������� (�.�������):
--�� ������ �������������� payment.amount - ������� �������� ������������, ��������� ������ - film.rental_rate.

--������� �.��������� ����� ���������:
select count(distinct actor_id)
from film f
join film_actor fa on fa.film_id = f.film_id
where f.rental_rate = 2.99;


