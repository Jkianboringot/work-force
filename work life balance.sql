select Department,count(case when `Work-Life Balance Score` < 3 then a.`Employee ID` end) from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by Department;


select b.`Work-Life Balance Score`,`attrition flag`,
		#sum(case when `Work-Life Balance Score` < 3 then 1 else 0 end) low_rating,
        (sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)*100)/cast(count(*)as decimal) fullymeets,
         (sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)*100)/cast(count(*)as decimal) exceed,
          (sum(case when `Performance Score` = 'PIP' then 1 else 0 end)*100)/cast(count(*)as decimal) pip,
           (sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)*100)/cast(count(*)as decimal) needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by b.`Work-Life Balance Score`,`attrition flag`
order by  `Work-Life Balance Score`,`attrition flag`;






select b.`Work-Life Balance Score`,`attrition flag`,
		#sum(case when `Work-Life Balance Score` < 3 then 1 else 0 end) low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100  pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100  needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by b.`Work-Life Balance Score`,`attrition flag`
order by  `Work-Life Balance Score`,`attrition flag`;







#in department executive office  pip is exceptionally high so investigate that this is a good analysis maybe improvethis morea
	# and analysis make sure its correct and as for the other it seem to be normal since i now attrition is 51% but i hting onle 
	#executive office is teh problem sofware engineering seem to have a problem since data is weird
	# but this data has a common of admin has a higher stay with low worklife balance and the other has lefter being higher
#🤢🤢
with performance as (
select a.`Performance Score`,
		sum(case when `Work-Life Balance Score` = 5 then 1 else 0 end) low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end) fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end) exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end) pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end) needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `Performance Score`
order by a.`Performance Score`)
, Department as (
select a.`Department`,`attrition flag`,
		sum(case when `Work-Life Balance Score` = 5 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `Department`,`attrition flag` 
),attrition as ( # 🚨might but  No clear direct link between poor work-life balance and attrition in your dataset.
select `attrition flag`,`Work-Life Balance Score`,
		#sum(case when `Work-Life Balance Score` >= 1 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `attrition flag` ,`Work-Life Balance Score`
order by `Work-Life Balance Score`,`attrition flag` 
),engagement as (
# might but no corelation even when paired up with attrition and department but executive seem to have a problem with pip
#Production shows higher "Needs Improvement" and PIP for lower engagement levels.
select `Engagement Score`,`attrition flag`,
		sum(case when `Work-Life Balance Score` = 1 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `Engagement Score`,`attrition flag`
order by  `Engagement Score`,`attrition flag`)
,satisfaction as (
# might but no corelation even when paired up with department but executive seem to have a problem with pip
select `Satisfaction Score`,Department,
		sum(case when `Work-Life Balance Score` = 1 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `Satisfaction Score`,Department
order by  `Satisfaction Score`,Department)
select * from engagement; # may redo this but with engagemt









with per_engage as (
select `Satisfaction Score`,
		sum(case when `Work-Life Balance Score` = 1 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           sum(case when `Engagement Score` = 1 then 1 else 0 end)/count(*)*100 engagement_1,
        sum(case when `Engagement Score` = 2 then 1 else 0 end)/count(*)*100 engagement_2,
         sum(case when `Engagement Score` = 3 then 1 else 0 end)/count(*)*100 engagement_3,
          sum(case when `Engagement Score` = 4 then 1 else 0 end)/count(*)*100 engagement_4,
           sum(case when `Engagement Score` = 5 then 1 else 0 end)/count(*)*100 engagement_5,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `Satisfaction Score`
order by  `Satisfaction Score`)
,department as (
# might but no corelation everyhting seem to be normal but why is executive office have a high engagement5
select Department,
		sum(case when `Work-Life Balance Score` = 1 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           sum(case when `Engagement Score` = 1 then 1 else 0 end)/count(*)*100 engagement_1,
        sum(case when `Engagement Score` = 2 then 1 else 0 end)/count(*)*100 engagement_2,
         sum(case when `Engagement Score` = 3 then 1 else 0 end)/count(*)*100 engagement_3,
          sum(case when `Engagement Score` = 4 then 1 else 0 end)/count(*)*100 engagement_4,
           sum(case when `Engagement Score` = 5 then 1 else 0 end)/count(*)*100 engagement_5,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by Department
order by  Department)
# might but no corelation
select `attrition flag`,
		sum(case when `Work-Life Balance Score` = 1 then 1 else 0 end)/count(*)*100 low_rating,
        sum(case when `Performance Score` = 'Fully Meets' then 1 else 0 end)/count(*)*100 fullymeets,
         sum(case when `Performance Score` = 'Exceeds' then 1 else 0 end)/count(*)*100 exceed,
          sum(case when `Performance Score` = 'PIP' then 1 else 0 end)/count(*)*100 pip,
           sum(case when `Performance Score` = 'Needs Improvement' then 1 else 0 end)/count(*)*100 needimprovement,
           sum(case when `Engagement Score` = 1 then 1 else 0 end)/count(*)*100 engagement_1,
        sum(case when `Engagement Score` = 2 then 1 else 0 end)/count(*)*100 engagement_2,
         sum(case when `Engagement Score` = 3 then 1 else 0 end)/count(*)*100 engagement_3,
          sum(case when `Engagement Score` = 4 then 1 else 0 end)/count(*)*100 engagement_4,
           sum(case when `Engagement Score` = 5 then 1 else 0 end)/count(*)*100 engagement_5,
           count(*) con
from employee_data_cleaned a
join employee_survey_stagging b
	on a.`Employee ID`=b.`Employee ID`
group by `attrition flag`
order by  `attrition flag`;








select * from employee_survey_stagging;



#am done i can rest now if i want but tomorrow i need to fix the analyst and pic one that will be in my resume and make the code more productive
	#and investigate if it is correct make some better  learn how to visualize ask the reason why it use that in this































































