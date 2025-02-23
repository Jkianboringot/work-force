#department,jobrole, engagement score highst
with cte as (
select a.Department,a.`Job Role`,b.`Engagement Score`,
			sum(case when `attrition flag`=1 then 1 else 0 end) lefter
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by a.Department,a.`Job Role`,b.`Engagement Score`
)select  * from(select * ,row_number() over(partition by Department order by lefter desc) as ranking
from cte) a
where  ranking <=3
;





# resign,Retirement,voluntary,involuntary attrition distrubution engagement
with cte as (
select a.Department,b.`Engagement Score`,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end) involuntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) voluntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
         sum(case when `Termination`="Unk" then 1 else 0 end) Unk
         

from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
#where `attrition flag` =1
group by a.Department,b.`Engagement Score`
)select  * from(select * ,row_number() over(partition by Department order by Unk  desc) as ranking
from cte) a
where  ranking <=3
;


# resign,Retirement,voluntary,involuntary attrition distrubution Work-Life Balance Score
with cte as (
select a.Department,b.`Work-Life Balance Score`,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end) involuntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) voluntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement

from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
where `attrition flag` =1
group by a.Department,b.`Work-Life Balance Score`
)select  * from(select * ,row_number() over(partition by Department order by resign desc) as ranking
from cte) a

;



select a.Department,b.tenure_year,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end)involuntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) voluntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
         sum(case when `Termination`="Unk" then 1 else 0 end) UNK

from employee_data_cleaned a
join diversity_dataset b
	on a.`Employee ID`=b.`Employee ID`
group by a.Department,b.tenure_year;




#what depaertment has the lower retention
WITH cte as (
select a.Department,b.tenure_year,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end)voluntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) involuntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
         sum(case when `Termination`="Unk" then 1 else 0 end) UNK

from employee_data_cleaned a
join diversity_dataset b
	on a.`Employee ID`=b.`Employee ID`
group by a.Department,b.tenure_year
)select  * from(select * ,row_number() over(partition by Department order by resign,Retirement,voluntary,involuntary desc) as ranking
from cte) a
#where  ranking <=3

;

WITH cte as (
select  a.Department,b.`Engagement Score`,tenure_year,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end)voluntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) involuntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
         sum(case when `Termination`="Unk" then 1 else 0 end) UNK

from employee_data_cleaned a
join diversity_dataset b
	on a.`Employee ID`=b.`Employee ID`
group by a.Department,b.`Engagement Score`,tenure_year
)select  * from(select * ,row_number() over(partition by  `Engagement Score` order by tenure_year) as ranking
from cte) a
#where  tenure_year >=1

;

WITH cte as (
select  a.Department,b.`Performance Score`,tenure_year,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end)voluntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) involuntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
         sum(case when `Termination`="Unk" then 1 else 0 end) UNK

from employee_data_cleaned a
join diversity_dataset b
	on a.`Employee ID`=b.`Employee ID`
group by a.Department,b.`Performance Score`,tenure_year
)select  * from(select * ,row_number() over(partition by  `Performance Score` order by tenure_year) as ranking
from cte) a
#where  tenure_year >=1

;


with tenure_performance as 
(
select `Performance Score`,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end) involuntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) voluntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
		TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE()))tenure_year
from second_project.employee_data_cleaned a
group by TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE())),`Performance Score`
order by tenure_year desc
)
select *,
    ( 
		select 
			COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) companyattrition
		from second_project.employee_data_cleaned
) comapanyattrition
 from tenure_performance t;


select * from employee_data_cleaned;
select * from employee_survey_stagging;





with tenure_performance as 
(
select b.`Work-Life Balance Score`,
		sum(case when `Termination`="Resignation" then 1 else 0 end) resign ,
        sum(case when `Termination`="Voluntary" then 1 else 0 end) involuntary  ,
        sum(case when `Termination`="Involuntary" then 1 else 0 end) voluntary,
         sum(case when `Termination`="Retirement" then 1 else 0 end) Retirement,
		TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE()))tenure_year
from second_project.employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE())),`Work-Life Balance Score`
order by tenure_year desc
)
select *,
    ( 
		select 
			COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) companyattrition
		from second_project.employee_data_cleaned
) comapanyattrition
 from tenure_performance t

#i can group this by performance and compare each year perfomance 
 ;









select * from employee_data_cleaned;


with engagement_correlation as
(
SELECT `Engagement Score` ,cast((sum(CASE WHEN `attrition flag`=1 then 1 else 0 end) * 100 / count(*))as decimal(10,2)) as engagement_attrition
from second_project.employee_data_cleaned edc
join employee_survey_stagging ess
	on edc.`Employee ID`=ess.`Employee ID`
group by `Engagement Score`
),avg_engagement_cte as 
(
select avg(`Engagement Score`) avg_engagement_score,
		avg(engagement_attrition) avg_engagement_attrition
 from engagement_correlation
)
 select sum((atr.`Engagement Score`-aec.avg_engagement_score )
		* (atr.`Engagement_attrition`-aec.avg_engagement_attrition ))   /
			sqrt(sum(power(atr.`Engagement Score`-aec.avg_engagement_score ,2))
			* SUM(power(atr.`Engagement_attrition`-aec.avg_engagement_attrition ,2)))  	correlation_coefficient
 from engagement_correlation atr
 join avg_engagement_cte aec
	 ON 1=1
;






with Performance_attrition_corrlation as 
(select
		`Performance Score`,  sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END)  lefted_employee,
							  sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) AS stayed_employee
from second_project.employee_data_cleaned
group by `Performance Score`
),observe as(
SELECT 
    m.`Performance Score`,
    sum(m.lefted_employee) lefted_sum, 
    sum(m.stayed_employee) stayed_sum,
	sum(lefted_employee+stayed_employee) total_employee,
    case when `Performance Score` is null then "Total Performance Score" else  `Performance Score`end  as `Total Performance Score`
FROM Performance_attrition_corrlation m
group by `Performance Score` with rollup
ORDER BY `Performance Score` DESC
),expected_value as 
(
select total_employee,sum(lefted_sum) k,sum(stayed_sum) j from  observe
group by total_employee
order by total_employee desc
limit 1
),expected_attrition as
(select t.`Performance Score`,
			sum(e.k)*sum(t.lefted_sum+ t.stayed_sum)/sum(e.total_employee) as expected_left,
			sum(e.j)*sum(t.lefted_sum+ t.stayed_sum)/sum(e.total_employee) expected_stayed
from expected_value e,observe t
group by t.`Performance Score`

)
select o.`Performance Score`,sum(power(e.expected_left-o.lefted_sum,2))/e.expected_left lefter_correlation,
						sum(power(e.expected_stayed-o.stayed_sum,2))/e.expected_stayed stay_correlation
  from expected_attrition e 
 join observe o
	on e.`Performance Score`=o.`Performance Score`
 GROUP BY `Performance Score`  
;







with Department_attrition_corrlation as 
(select
		Department,  COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END)  lefted_employee,
							  COUNT(CASE WHEN `attrition flag` = 0 THEN `Employee Id` END) AS stayed_employee
from second_project.employee_data_cleaned
group by Department
order by Department
),observe as(
SELECT 
    m.Department,
    sum(m.lefted_employee) lefted_sum, 
    sum(m.stayed_employee) stayed_sum,
	sum(lefted_employee+stayed_employee) total_employee,
    case when Department is null then "Total Performance Score" else Department end  as `Total Performance Score`
FROM Department_attrition_corrlation m
group by Department with rollup 
ORDER BY Department DESC
),expected_value as 
(
select total_employee,sum(lefted_sum) k,sum(stayed_sum) j from  observe
group by total_employee
order by total_employee desc
limit 1
),expected_attrition as
(select t.Department,
			sum(e.k)*sum(t.lefted_sum+ t.stayed_sum)/sum(e.total_employee) as expected_left,
			sum(e.j)*sum(t.lefted_sum+ t.stayed_sum)/sum(e.total_employee) expected_stayed
from expected_value e,observe t
group by t.Department
limit 4
)
select o.Department,sum(power(e.expected_left-o.lefted_sum,2))/e.expected_left,
						sum(power(e.expected_stayed-o.stayed_sum,2))/e.expected_stayed
  from expected_attrition e 
 join observe o
	on e.Department=o.Department
 GROUP BY Department

 ;























