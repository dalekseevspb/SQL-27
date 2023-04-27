/*Алексеев Д.П. (DSU-4, SQL-27)
Домашнее задание по теме “Углубление в SQL” - Практика №4

База данных: если подключение к облачной базе, то создаете новые таблицы в формате: таблица_фамилия, если подключение к контейнеру или 
локальному серверу, то создаете новую схему и в ней создаете таблицы.

Основная часть:
Спроектируйте базу данных для следующих сущностей:
-язык (в смысле английский, французский и тп)
-народность (в смысле славяне, англосаксы и тп)
-страны (в смысле Россия, Германия и тп)

Правила следующие:
-на одном языке может говорить несколько народностей
-одна народность может входить в несколько стран
-каждая страна может состоять из нескольких народностей

Суть задания - научиться проектировать архитектуру и работать с ограничениями. Таким образом должно получиться 5 таблиц. Три таблицы-справочника и две таблицы со связями.
(Пример таблицы со связями - film_actor)

Пришлите скрипты создания таблиц и скрипты по добавлению в каждую таблицу по 5 строк с данными

Дополнительная часть:
-показать, как назначать внешние ключи краткой записью при создании таблицы и как можно присвоить внешние ключи для столбцов существующей таблицы
-масштабировать получившуюся базу данных используя следующие типы данных: timestamp, boolean и text[] */

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

--заполняем таблицы значениями
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

--создаем таблицы со связями
create table nation_lang (
	nation_id int2 not null, 
	language_id int2 not null,
	constraint nation_lang_pkey primary key (nation_id, language_id), --задаем составной первичный ключ
	constraint nation_lang_nation_id_fkey foreign key (nation_id) references nation(nation_id), -- 1-ая часть первичного ключа
	constraint nation_lang_language_id_fkey foreign key (language_id) references lang(language_id) -- 2-ая часть первичного ключа
)

create table nation_country (
	nation_id int2 not null,
	country_id int2 not null,
	constraint nation_country_pkey primary key (nation_id, country_id),
	constraint nation_country_nation_id_fkey foreign key (nation_id) references nation(nation_id), 
	constraint nation_country_country_id_fkey foreign key (country_id) references country(country_id)
)

--заполняем таблицу nation_lang всеми комбинациями (можно выбрать и конкретные связи, тогда комбинаций будет меньше в данной таблице)
insert into nation_lang (nation_id, language_id) 
select n.nation_id, l.language_id
from nation n, lang l

--заполняем таблицу nation_country всеми комбинациями (можно выбрать и конкретные связи, тогда комбинаций будет меньше в данной таблице)
insert into nation_country (nation_id, country_id) 
select n.nation_id, c.country_id
from nation n, country c

