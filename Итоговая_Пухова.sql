1 �������. � ����� ������� ������ ������ ���������?

select city 
from airports --�� ������� ���������� ������ �������� �������
group by city --������������� �� �������, ����� ����� ��������� ��������
having count(*)>1 --��������� �� ���������� ���������� (������ 1)

2 �������. � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?

select distinct departure_airport as "�������� �����������" --������� ���������� ��������� �����������
from (
	select aircraft_code --�������� �� ������� ��������� ���� ���������
	from aircrafts 
	order by range desc --��������� ��������� ������ �� ������������ � �����������
	limit 1) a --������������ 1, �.� ����� ����� ������� ��������� ������
join flights f on f.aircraft_code = a.aircraft_code --������������ ������� ������� �� ���� ��������, ����� ������� ���������

3 �������. ������� 10 ������ � ������������ �������� �������� ������

select actual_departure - scheduled_departure as "����� �������� ������", flight_no as "����� �����"
from flights --������ ������� ����� ����������� �������� ������ � �������� ������ �� ����������. ��� ���������� ����� �������� �����
where actual_departure - scheduled_departure is not null --������ ����������� �������� ����� ������ ����
order by "����� �������� ������" desc --��������� ����� �������� ����� �� ����� ������ � ����� ���������
limit 10 --������������ 10 ��������

4 �������. ���� �� �����, �� ������� �� ���� �������� ���������� ������?

select b.book_ref as "����� ������������", bp.boarding_no as "���������� �����"--������� ����� ������������ � ����� ����������� ������
from bookings b
left join tickets t on t.book_ref = b.book_ref --������������ �������  ������, ����� ����� ��� ������� ����� ����������� ������ �� ������� boarding_passes 
left join boarding_passes bp on t.ticket_no = bp.ticket_no --������������ ������� boarding_passes, ����� ������� ����� ����������� ������
where bp.boarding_no is null --������������ ����� ����������� ������ �����, �.� ��� ����� �����, �� ������� �� �������� ���������� ������

5 �������. ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������

select model, (round(plane / (sum(plane) over()), 2)*100) as "�������" --������� ������� �� ����� ����� ���������
from (select count(flight_id) as plane, model --������� ���������� �������
	from flights f 
	join aircrafts a on a.aircraft_code = f.aircraft_code --������������ ������� "��������", ����� ����� ���� �������� �������� ������� ���������
	group by model) a
	
6 �������. ���� �� ������, � ������� ����� ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?

with cte as 
	(select distinct flight_id, max(amount) as "���� ������", fare_conditions as "�����"
	from ticket_flights 
	where fare_conditions = 'Economy' --������� ������������ ���� ������� �� �����, ��������� �� �����
	group  by flight_id, fare_conditions 
	order by flight_id),
cte2 as 
	(select distinct flight_id, min(amount) as "���� ������", fare_conditions as "�����"
	from  ticket_flights tf 
	where fare_conditions = 'Business' --������� ����������� ���� ������ ������
	group by flight_id, fare_conditions 
	order by flight_id)
select distinct city as "�����" --������� ���������� �������� �������
from cte 
join cte2 on cte2.flight_id  = cte.flight_id 
join flights f on f.flight_id = cte.flight_id --������������ �������, ����� ������� �������� ������� ����� ������������� ������ � ��� ��������� ��������
join airports a on a.airport_code = f.arrival_airport
where "���� ������" < "���� ������" --������ �������, ����� ���� ������ ������ ���� ������ ���� �������

�����: ���

7 �������. ����� ������ �������� ��� ������ ������?

create view cities as 
select departure_city, arrival_city --������� ������������� � �������� ������ � ��������
from flights_v

select a.city city_one, a2.city city_two
from airports a, airports a2 -- ������� ���� �������
where a.city != a2.city
except --������� �������� ������� � ������� ������, ��������� ������� ��� � ����� �������������
select departure_city, arrival_city 
from cities

