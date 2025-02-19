# redo everything and only focus on attrition by department  and maybe some job role and how different thing can afect it why is it why on some aspect and i will only analysis hard 
	-- thing like covairate bivariate so only complex things i will take other analysis that i made but only the one that help me with invesgating attriton

#👍  
	-- this look at if engagment has a corelation with attrition
		-- this see if some engagemnt have higher attriion than other , univariate so mayby connets this with other to have a better look at this to simple
#STORED
with Engagementattrition as 
(select survey.`Engagement Score`,  
			cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*)) as decimal(10,2)) AS lefter_rate,
			cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*))  as decimal(10,2)) AS stayer_rate								
from second_project.employee_data_cleaned as employee																		
join employee_engagement_survey_data as survey
	on employee.`Employee ID`=survey.`Employee ID`
group by survey.`Engagement Score`
)
SELECT 
    m.`Engagement Score`,
    m.lefter_rate, 
    m.stayer_rate
    ,cast((select sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / NULLIF(count(*), 0) from second_project.employee_data_cleaned) as decimal(10,2)) as 
	company_attrition
FROM Engagementattrition m
ORDER BY lefter_rate  DESC;
































		#use pearson correlation coefficeint to calculate if engagement has a correlation with turnover
			-- -1 → Strong negative relationship (High engagement = Low turnover).
			-- +1 → Strong positive relationship (High engagement = High turnover).
			-- 0 → No clear relationship (Engagement doesn’t impact turnover much).
#👍 engagement attrition
	-- to see if engagment actually have an empact on attrition and its no but look at this wiht other like Department or jobrole
    -- this confirm that engagement alone have no corelation to attrition
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







#👍 department attrition
	-- this see if some deparment have higher attriion than other , univariate so mayby connets this with other to have a better look at this to simple
#STORED
with Departmentattrition as 
(select `Department`,
					cast((COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END)* 100.0 / count(*))as decimal(10,2)) lefter,
                    cast((COUNT(CASE WHEN `attrition flag` = 0 THEN `Employee Id` END)* 100.0 / count(*))as decimal(10,2))  stayer
from second_project.employee_data_cleaned
group by Department
)
SELECT 
    m.Department,
	m.lefter,
    m.stayer
    ,cast((select sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0  END)*100/count(*) from second_project.employee_data_cleaned)as decimal(10,2)) company_attrition
FROM Departmentattrition m
;





# ************************************************************************ to do later ************************************************************************

#👍 performance attrition shorten the code
	-- this confirm that performance alone have no corelation to attrition
	-- this could be better by covariating it with other since this does not answer a question
    
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


# do later
with Performance_attrition_corrlation as 
(
select	 `Performance Score`,
				sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END)  AS lefted_employee,
				sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) AS stayed_employee,
				sum((CASE WHEN `attrition flag` = 1 THEN 1 else 0 END)+(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END)) total_employee
from second_project.employee_data_cleaned
group by `Performance Score`
),expected_attrition as
(select `Performance Score`,
			sum(lefted_employee)*sum(lefted_employee+ stayed_employee)/sum(total_employee) as expected_left,
			sum(stayed_employee)*sum(lefted_employee+ stayed_employee)/sum(total_employee) expected_stayed
from  Performance_attrition_corrlation 
group by `Performance Score`
)
select o.`Performance Score`,sum(power(e.expected_left-o.lefted_employee,2))/e.expected_left lefter_correlation,
						sum(power(e.expected_stayed-o.stayed_employee,2))/e.expected_stayed stay_correlation
  from expected_attrition e 
 join  Performance_attrition_corrlation o
	on e.`Performance Score`=o.`Performance Score`
 GROUP BY `Performance Score`  
;
#this analysis can be use to confirm the query below

# *************************************************************************to do later************************************************************************










#covariate of performance and department 👍 performance department attrition (needs investigation ,'Software Engineering')!!
	-- since department and performance alone is enuogh to confirm i combined them and see if the result stay the same or change 
	-- good analysis but the code is shit
		-- maybe try to do a spearman corrlation on  this or chi to confirm id department and performance has a corelation
# this analysis is the best type of analysis
-- ✔ this is done
with Performancedeparment_vs_attrition as 
(select `Performance Score`,Department, 
			cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END)* 100.0 / count(*)) as decimal(10,2)) employee_left,
            cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END)* 100.0 / count(*)) as decimal(10,2)) employee_stay
from second_project.employee_data_cleaned 
group by `Performance Score`,Department
)
SELECT 
    m.`Performance Score`,
     m.Department,
	m.employee_left,
    m.employee_stay,
	cast((select sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / NULLIF(count(*), 0) from second_project.employee_data_cleaned)as decimal(10,2)) as company_attrition
FROM Performancedeparment_vs_attrition m
ORDER BY Department DESC
;







#👍 department attion corilation
	 	-- to see if department actually have an empact on attrition since normal analysis isn ot enough answer the quesetion
			#and its no but look at this wiht other like Department or jobrole
		-- this confirm that engagement alone have no corelation to attrition
	#and try this with engagemnt 
    #do this after am done with the other attrition
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
















# !!! tenure if lefter thisis bad find the better one
-- COULD be good be need toe be long like make year column
-- i think there is better one this where it go up to six year
#🙄🔐🛠🛠🛠 already have a better one
with tenure_performance as 
(
select `Performance Score`,TIMESTAMPDIFF(year,StartDate,ExitDate)year,
		count(case when `attrition flag`= 1 then `Employee ID` end ) as employee_left ,
        count(case when ExitDate is null then `Employee ID` end) as employee_all ,
		sum(TIMESTAMPDIFF(month,StartDate,ExitDate)) as month
from second_project.employee_data_cleaned a
group by TIMESTAMPDIFF(year,StartDate,ExitDate),`Performance Score`
order by `year` desc
),Companyattrition as
( 
select 
	COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) companyattrition
from second_project.employee_data_cleaned
),jobrole as
(
select t.year,
	t.`Performance Score`,
	t.employee_left,
	(t.employee_left/month)*100 attrition_year,
    c.companyattrition
 from tenure_performance t
 join Companyattrition c
	on 1=1
where year is not null
),final as(
select year,sum(employee_left) sum_employee_left,sum(attrition_year) sum_tenure,companyattrition,rank() over(order by year ) rank_attrition
from jobrole
where year is not null
group by year,companyattrition
)select * from jobrole
#i can group this by performance and compare each year perfomance 
 ;
 












# 😆😆 migth be good
	-- maybe do a spearman correlation with this but to confirm if this actualy dont affect attriton as much
with jobrole_attrition as 
(select `Job Role`, 
		 sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / NULLIF(count(*), 0) AS jobrole_attrition_rate_left,
        sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / NULLIF(count(*), 0) AS jobrole_attrition_rate_stay
from second_project.employee_data_cleaned
group by `Job Role`
)
SELECT 
    m.`Job Role`,
    
    m.jobrole_attrition_rate_left, 
    m.jobrole_attrition_rate_stay,
    cast((select sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / NULLIF(count(*), 0) from second_project.employee_data_cleaned)as decimal(10,2)) "company attrition"
FROM jobrole_attrition m

ORDER BY jobrole_attrition_rate_left  DESC
;




























#iwant to check the satisfaction level of lefter anf stayer
	-- if satisfaction affect the attrition but it look like it does not so combine with other to see more because its to simple

#STORED
with Satisfaction_Score as (
select `Satisfaction Score`,
							 sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*)  leftemployee_satisfaction,
							 sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*) stayemployee_satisfaction
from employee_survey_stagging  sur
join second_project.employee_data_cleaned dat
	on sur.`Employee ID`=dat.`Employee ID`
group by `Satisfaction Score` 
)select * from Satisfaction_Score
;


#👍`worklife balance by department
-- search what is the production code for this
with worklifebalance_Score as (
select `Work-Life Balance Score`,Department,
							sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*) left_work_life_balance_Score,
							sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*) stay_work_life_balance_Score
from second_project.employee_survey_stagging  sur
join second_project.employee_data_cleaned dat
	on sur.`Employee ID`=dat.`Employee ID`
group by `Work-Life Balance Score`,Department
)select * 
from worklifebalance_Score
order by `Work-Life Balance Score`
;


















#!! this code be good but i think theres better one 
with tenure_Department as 
(
select `Department`,TIMESTAMPDIFF(year,StartDate,ExitDate)year,
		count(case when `attrition flag`= 1 then `Employee ID` end ) as employee_left ,
		sum(TIMESTAMPDIFF(month,StartDate,ExitDate)) as month
from second_project.employee_data_cleaned a
group by TIMESTAMPDIFF(year,StartDate,ExitDate),`Department`
order by `year` desc
),
Companyattrition as
( 
select 
	COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) companyattrition
from second_project.employee_data_cleaned
),
jobrole as
(
select t.year,
	t.`Department`,
	t.employee_left,
	(t.employee_left/month)*100 attrition_year,
    c.companyattrition
 from tenure_Department t
 join Companyattrition c
	on 1=1
where year is not null
),
final as
(
select year,
		sum(employee_left) sum_employee_left,
		sum(attrition_year) sum_tenure,companyattrition,rank() over(order by year ) rank_attrition
from jobrole
where year is not null
group by year,companyattrition
)
select * from jobrole
order by `Department`
 ;








#this figure out what year most people left
#✌ this a great findings because we can see that 5 6 have no lefter but 1 and 2 have alot of lefter even higher then the stayer this mean their is great retention
	-- or better treatment for senior level and not so much in low tenure years
#stored
select TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE())) years,
		count(case when `attrition flag`= 1  and ExitDate is not null then `Employee ID` end ) as employee_left , # i dont need to do this since this i how i got attrition flag
        count(case when `attrition flag`= 0 then `Employee ID` end ) as employee_stay 
		
from second_project.employee_data_cleaned a
group by TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE())) with rollup
order by years desc;

#i will redo everything and this time i will only focus on attriton and investigate thourhly fuck the other 



