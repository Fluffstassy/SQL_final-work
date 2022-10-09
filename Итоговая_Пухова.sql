1 задание. В каких городах больше одного аэропорта?

select city 
from airports --из таблицы аэропортов вывели названия городов
group by city --сгруппировали по городам, чтобы найти повторные значения
having count(*)>1 --фильтруем по количеству повторений (больше 1)

2 задание. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?

select distinct departure_airport as "Аэропорт отправления" --выводим уникальные аэропорты отправления
from (
	select aircraft_code --выделяем из таблицы самолетов коды самолетов
	from aircrafts 
	order by range desc --фильтруем дальность полета от максимальной к минимальной
	limit 1) a --ограничиваем 1, т.е берем самую большую дальность полета
join flights f on f.aircraft_code = a.aircraft_code --присоединяем таблицу полетов по коду самолета, чтобы увидеть аэропорты

3 задание. Вывести 10 рейсов с максимальным временем задержки вылета

select actual_departure - scheduled_departure as "Время задержки вылета", flight_no as "Номер рейса"
from flights --вывели разницу между фактическим временем вылета и временем вылета по расписанию. Это показывает время задержки рейса
where actual_departure - scheduled_departure is not null --ставим ограничение задержки рейса больше нуля
order by "Время задержки вылета" desc --фильтруем время задержки рейса от самой долгой к самой маленькой
limit 10 --ограничиваем 10 записями

4 задание. Были ли брони, по которым не были получены посадочные талоны?

select b.book_ref as "Номер бронирования", bp.boarding_no as "Посадочный талон"--выводим номер бронирования и номер посадочного талона
from bookings b
left join tickets t on t.book_ref = b.book_ref --присоединяем таблицу  билеты, чтобы через нее вывести номер посадочного талона из таблицы boarding_passes 
left join boarding_passes bp on t.ticket_no = bp.ticket_no --присоединяем таблицу boarding_passes, чтобы вывести номер посадочного талона
where bp.boarding_no is null --ограничиваем номер посадочного талона нулем, т.к нам нужны брони, на которые не получены посадочные талоны

5 задание. Найдите процентное соотношение перелетов по типам самолетов от общего количества

select model, (round(plane / (sum(plane) over()), 2)*100) as "Процент" --считаем процент от общей суммы перелетов
from (select count(flight_id) as plane, model --считаем количество полетов
	from flights f 
	join aircrafts a on a.aircraft_code = f.aircraft_code --присоединяем столбец "самолеты", чтобы через него получить названия моделей самолетов
	group by model) a
	
6 задание. Были ли города, в которые можно добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?

with cte as 
	(select distinct flight_id, max(amount) as "Цена эконом", fare_conditions as "Класс"
	from ticket_flights 
	where fare_conditions = 'Economy' --выводим максимальную цену эконома на рейсе, сортируем по рейсу
	group  by flight_id, fare_conditions 
	order by flight_id),
cte2 as 
	(select distinct flight_id, min(amount) as "Цена бизнес", fare_conditions as "Класс"
	from  ticket_flights tf 
	where fare_conditions = 'Business' --выводим минимальную цену бизнес класса
	group by flight_id, fare_conditions 
	order by flight_id)
select distinct city as "Город" --выводим уникальные названия городов
from cte 
join cte2 on cte2.flight_id  = cte.flight_id 
join flights f on f.flight_id = cte.flight_id --присоединяем таблицы, чтобы вывести названия городов через идентификатор полета и код аэропорта прибытия
join airports a on a.airport_code = f.arrival_airport
where "Цена бизнес" < "Цена эконом" --ставим условие, чтобы цена бизнес класса была меньше цены эконома

Ответ: нет

7 задание. Между какими городами нет прямых рейсов?

create view cities as 
select departure_city, arrival_city --создаем представление с городами вылета и прибытия
from flights_v

select a.city city_one, a2.city city_two
from airports a, airports a2 -- находим пары городов
where a.city != a2.city
except --находим разность выборок и выводим города, сочетания которых нет в нашем представлении
select departure_city, arrival_city 
from cities

