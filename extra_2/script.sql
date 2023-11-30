drop table Employee;

create table Employee(
	id INT, 
	FIO VARCHAR(100), 
	date_of_status DATE,
	Status TEXT
);

insert into Employee (
	id,
	FIO,
	date_of_status,
	Status
) 
values
	(1, 'Иванов Иван Иванович', '2022-12-12', 'Работа offline'),
	(1, 'Иванов Иван Иванович', '2022-12-13', 'Работа offline'),
	(1, 'Иванов Иван Иванович', '2022-12-14', 'Больничный'),
	(1, 'Иванов Иван Иванович', '2022-12-15', 'Больничный'),
	(1, 'Иванов Иван Иванович', '2022-12-16', 'Удаленная работа'),
	(2, 'Петров Петр Петрович', '2022-12-12', 'Работа offline'),
	(2, 'Петров Петр Петрович', '2022-12-13', 'Работа offline'),
	(2, 'Петров Петр Петрович', '2022-12-14', 'Удаленная работа'),
	(2, 'Петров Петр Петрович', '2022-12-15', 'Удаленная работа'),
	(2, 'Петров Петр Петрович', '2022-12-16', 'Работа offline');
	
select *
from Employee;

with full_status as (
	select id, FIO, date_of_status, Status,
		lag(date_of_status) over (partition by id, FIO, Status order by date_of_status) as date_before,
		lead(date_of_status) over (partition by id, FIO, Status order by date_of_status) as date_after,
		count(*) over (partition by id, FIO, Status order by date_of_status) as continue_days
	from Employee
)
select fs1.id, fs1.FIO, fs1.date_of_status as date_from, fs2.date_of_status as date_to, fs1.Status
from full_status fs1 join full_status fs2 on fs1.id = fs2.id and fs1.FIO = fs2.FIO and fs1.Status = fs2.Status
where (fs1.date_before is null or fs1.date_of_status - fs1.date_before > 1) and 
	(fs2.date_after is null or fs2.date_after - fs2.date_of_status > 1) and 
	(fs2.date_of_status - fs1.date_of_status >= 0 and fs2.date_of_status - fs1.date_of_status <= fs2.continue_days)
order by fs1.id, fs1.date_of_status;