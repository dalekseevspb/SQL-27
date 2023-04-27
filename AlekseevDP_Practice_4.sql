/*�������� �.�. (DSU-4, SQL-27)
�������� ������� �� ���� ����������� � SQL� - �������� �4

���� ������: ���� ����������� � �������� ����, �� �������� ����� ������� � �������: �������_�������, ���� ����������� � ���������� ��� 
���������� �������, �� �������� ����� ����� � � ��� �������� �������.

�������� �����:
������������� ���� ������ ��� ��������� ���������:
-���� (� ������ ����������, ����������� � ��)
-���������� (� ������ �������, ���������� � ��)
-������ (� ������ ������, �������� � ��)

������� ���������:
-�� ����� ����� ����� �������� ��������� �����������
-���� ���������� ����� ������� � ��������� �����
-������ ������ ����� �������� �� ���������� �����������

���� ������� - ��������� ������������� ����������� � �������� � �������������. ����� ������� ������ ���������� 5 ������. ��� �������-����������� � ��� ������� �� �������.
(������ ������� �� ������� - film_actor)

�������� ������� �������� ������ � ������� �� ���������� � ������ ������� �� 5 ����� � �������

�������������� �����:
-��������, ��� ��������� ������� ����� ������� ������� ��� �������� ������� � ��� ����� ��������� ������� ����� ��� �������� ������������ �������
-�������������� ������������ ���� ������ ��������� ��������� ���� ������: timestamp, boolean � text[] */

create schema practice_4

set search_path to practice_4

create table "lang" (
	language_id serial primary key,  
	language_name varchar(50) not null)
	
create table "nation" (
	nation_id serial primary key,  
	nation_name varchar(50) not null)
	
create table "country" (
	country_id serial primary key,  
	country_name varchar(50) not null)

--��������� ������� ����������
insert into lang (language_name)
values ('Russian'),
		('English'), 
		('German'), 
		('Francais'),
		('Japanese');
	
insert into nation (nation_name)
values ('Russians'),
		('Britans'), 
		('Germans'), 
		('Canadians'),
		('Indians');

insert into country (country_name)
values ('Russia'),
		('Germany'), 
		('France'), 
		('Canada'),
		('Japan');

--������� ������� �� �������
create table nation_lang (
	nation_id int2 not null, 
	language_id int2 not null,
	constraint nation_lang_pkey primary key (nation_id, language_id), --������ ��������� ��������� ����
	constraint nation_lang_nation_id_fkey foreign key (nation_id) references nation(nation_id), -- 1-�� ����� ���������� �����
	constraint nation_lang_language_id_fkey foreign key (language_id) references lang(language_id) -- 2-�� ����� ���������� �����
)

create table nation_country (
	nation_id int2 not null,
	country_id int2 not null,
	constraint nation_country_pkey primary key (nation_id, country_id),
	constraint nation_country_nation_id_fkey foreign key (nation_id) references nation(nation_id), 
	constraint nation_country_country_id_fkey foreign key (country_id) references country(country_id)
)

--��������� ������� nation_lang ����� ������������ (����� ������� � ���������� �����, ����� ���������� ����� ������ � ������ �������)
insert into nation_lang (nation_id, language_id) 
select n.nation_id, l.language_id
from nation n, lang l

--��������� ������� nation_country ����� ������������ (����� ������� � ���������� �����, ����� ���������� ����� ������ � ������ �������)
insert into nation_country (nation_id, country_id) 
select n.nation_id, c.country_id
from nation n, country c

