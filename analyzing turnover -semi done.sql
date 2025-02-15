#clasify querys to too univarieta or or covarieta 
	# it must nnot be too simple and for every simple one that i pic there must by an advance one after it ,preferably related

#👍  
	-- this look at if engagment has a corelation with attrition
		-- this see if some engagemnt have higher attriion than other , univariate so mayby connets this with other to have a better look at this to simple
	#try making this a store procedure
with Engagementattrition as 
(select survey.`Engagement Score`,  COUNT(CASE WHEN `attrition flag` = 1 THEN employee.`Employee Id` END) * 100.0 / NULLIF(count(*), 0) AS Engagement_attrition_rate
from second_project.employee_data_cleaned as employee
join employee_engagement_survey_data as survey
	on employee.`Employee ID`=survey.`Employee ID`
group by survey.`Engagement Score`
order by survey.`Engagement Score`
)
,CompanyAttrition as 
(
select COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0)AS company_avg_attrition
from second_project.employee_data_cleaned
)
SELECT 
    m.`Engagement Score`,
    m.Engagement_attrition_rate, 
    c.company_avg_attrition
FROM Engagementattrition m
JOIN CompanyAttrition c ON 1=1
ORDER BY Engagement_attrition_rate  DESC;


		#use pearson correlation coefficeint to calculate if engagement has a correlation with turnover
			-- -1 → Strong negative relationship (High engagement = Low turnover).
			-- +1 → Strong positive relationship (High engagement = High turnover).
			-- 0 → No clear relationship (Engagement doesn’t impact turnover much).
#👍 engagement attrition
	-- to see if engagment actually have an empact on attrition and its no but look at this wiht other like Department or jobrole
    -- this confirm that engagement alone have no corelation to attrition
with engagement_correlation as
(
SELECT `Engagement Score` ,count(CASE WHEN `attrition flag`=1 then edc.`Employee ID`end) * 100 / NULLIF(count(*), 0) as engagement_attrition
from second_project.employee_data_cleaned edc
join employee_survey_stagging ess
	on edc.`Employee ID`=ess.`Employee ID`
group by `Engagement Score`
order by `Engagement Score`
),avg_engagement_cte as 
(
select avg(`Engagement Score`) avg_engagement_score,
		avg(engagement_attrition) avg_engagement_attrition
 from engagement_correlation
 ),numerator_denominator as 
 (
 select sum(atr.`Engagement Score`-aec.avg_engagement_score )
		* SUM(atr.`Engagement_attrition`-aec.avg_engagement_score )  numerator ,
			sqrt(sum(power(atr.`Engagement Score`-aec.avg_engagement_score ,2))
			* SUM(power(atr.`Engagement_attrition`-aec.avg_engagement_score ,2)))  denominator
 from engagement_correlation atr,avg_engagement_cte aec
 )
 select numerator/denominator from numerator_denominator
;



















#👍 department attrition
	-- this see if some deparment have higher attriion than other , univariate so mayby connets this with other to have a better look at this to simple
    #try making this a store procedure
with Departmentattrition as 
(select `Department`,
					COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END)* 100.0 / NULLIF(count(*), 0) lefter,
                    COUNT(CASE WHEN `attrition flag` = 0 THEN `Employee Id` END)* 100.0 / NULLIF(count(*), 0) stayer
from second_project.employee_data_cleaned
group by Department
order by Department
)
SELECT 
    m.Department,
	m.lefter,
    m.stayer
FROM Departmentattrition m
;





#👍 performance attrition shorten the code
	-- this confirm that performance alone have no corelation to attrition
	-- this could be better by covariating it with other since this does not answer a question
    
with Performance_attrition_corrlation as 
(select
		`Performance Score`,  COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END)  lefted_employee,
							  COUNT(CASE WHEN `attrition flag` = 0 THEN `Employee Id` END) AS stayed_employee
from second_project.employee_data_cleaned
group by `Performance Score`
order by `Performance Score`
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
limit 4
)
select o.`Performance Score`,sum(power(e.expected_left-o.lefted_sum,2))/e.expected_left,
						sum(power(e.expected_stayed-o.stayed_sum,2))/e.expected_stayed
  from expected_attrition e 
 join observe o
	on e.`Performance Score`=o.`Performance Score`
 GROUP BY `Performance Score`

 ;


#covariate of performance and department 👍 performance department attrition (needs investigation ,'Software Engineering')!!
	-- since department and performance alone is enuogh to confirm i combined them and see if the result stay the same or change 
	-- good analysis but the code is shit
		-- maybe try to do a spearman corrlation on  this or chi to confirm id department and performance has a corelation
with Performancedeparment_vs_attrition as 
(select `Performance Score`,Department, 
			#COUNT(CASE WHEN `attrition flag` = 1 THEN employee.`Employee Id` END) * 100.0 / NULLIF(count(*), 0) AS performance_attrition_rate,
			count(CASE WHEN `attrition flag` = 1 THEN employee.`Employee Id` END)* 100.0 / NULLIF(count(*), 0) employee_left,
            count(CASE WHEN `attrition flag` = 0 THEN employee.`Employee Id` END) * 100.0 / NULLIF(count(*), 0)employee_stay
from second_project.employee_data_cleaned as employee
group by `Performance Score`,Department
order by `Performance Score`,Department
)
,totalattrition as 
(
select COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) AS company_avg_attrition
from second_project.employee_data_cleaned
)
SELECT 
    m.`Performance Score`,
     m.Department,
	m.employee_left,
    
    m.employee_stay,
   
    #m.performance_attrition_rate, 
    c.company_avg_attrition
FROM Performancedeparment_vs_attrition m
JOIN totalattrition  c ON 1=1

ORDER BY Department DESC
;







#👍 department attion corilation
	 	-- to see if department actually have an empact on attrition since normal analysis isn ot enough answer the quesetion
			#and its no but look at this wiht other like Department or jobrole
		-- this confirm that engagement alone have no corelation to attrition
	#and try this with engagemnt 
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
		COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) AS jobrole_attrition_rate_left,
		COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) employee_left,
        COUNT(CASE WHEN `attrition flag` = 0 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) AS jobrole_attrition_rate_stay,
        COUNT(CASE WHEN `attrition flag` = 0 THEN `Employee Id` END) employee_stay
from second_project.employee_data_cleaned
group by `Job Role`
order by `Job Role`
)
,CompanyAttrition as 
(
select COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) AS company_avg_attrition
from second_project.employee_data_cleaned
)
SELECT 
    m.`Job Role`,
    m.employee_left,
	m.employee_stay,
    m.jobrole_attrition_rate_left, 
    m.jobrole_attrition_rate_stay,
    c.company_avg_attrition
FROM jobrole_attrition m
JOIN CompanyAttrition c ON 1=1

ORDER BY jobrole_attrition_rate_left  DESC
;




























#iwant to check the satisfaction level of lefter anf stayer
	-- if satisfaction affect the attrition but it look like it does not so combine with other to see more because its to simple
#try making this a store procedure
with Satisfaction_Score as (
select `Satisfaction Score`,
							
							count(case when `attrition flag` =1 then dat.`Employee ID` end)*100 /NULLIF(count(*), 0)  leftemployee_satisfaction,
							#count(case when `attrition flag` =1 then dat.`Employee ID` end) employee_left,
                            count(case when `attrition flag` =0 then dat.`Employee ID` end)*100 /NULLIF(count(*), 0) stayemployee_satisfaction
							#count(case when `attrition flag` =0 then dat.`Employee ID` end) employee_stay
from employee_survey_stagging  sur
join second_project.employee_data_cleaned dat
	on sur.`Employee ID`=dat.`Employee ID`
group by `Satisfaction Score` 
)select * from Satisfaction_Score
;


#👍`worklife balance by department
with worklifebalance_Score as (
select `Work-Life Balance Score`,Department,count(case when `attrition flag` =1 then dat.`Employee ID` end)*100 /NULLIF(count(*), 0) leftworklifebalance_Score,
							#count(case when `attrition flag` =1 then dat.`Employee ID` end) employee_left,
                            count(case when `attrition flag` =0 then dat.`Employee ID` end)*100 /NULLIF(count(*), 0) stayworklifebalance_Score
							#count(case when `attrition flag` =0 then dat.`Employee ID` end) employee_stay
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























#when analysing did you consider this 
#	did this answer the question of analysing the reason for employee turnover what is a way to improve it
	-- after do cleaning add it to github
	-- 									*************************************DONE*******************************************************








