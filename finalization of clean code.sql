#i could change this so that i have to put a perosrmance or engagement then if i want i could add another paremeter where what i put in it will group by that
	-- like department, the goal of this is to have the ability to eaither only see the attrition of performance like univariate but with , what i want is
	-- to have the ability to make it covariate
DELIMITER $$
CREATE procedure attrition_comparision(in attrition varchar(250))
begin 

DECLARE Company_attrition decimal(10,2);
        select 
				COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(count(*), 0) 
                into Company_attrition
		from second_project.employee_data_cleaned;
        
        
        
if attrition = "Engagement rate" then
	with Engagement_rate as (
		select survey.`Engagement Score`,
         COALESCE(CAST(`Engagement Score` AS CHAR), 'Total Company Distribution') AS engagement,
				cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS lefter_rate,
				cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS stayer_rate
		from second_project.employee_data_cleaned as employee
		join employee_engagement_survey_data as survey
				on employee.`Employee ID`=survey.`Employee ID`
		group by survey.`Engagement Score` with rollup)
        SELECT *, Company_attrition AS company_avg_attrition
        FROM Engagement_rate;
        
elseif attrition ="Performance Score" then
with Performace_Score_attrition as 
(select `Performance Score`,
 COALESCE(CAST(`Performance Score` AS CHAR), 'Total Company Distribution') AS performance,
				cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS lefter_rate,
				cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS stayer_rate
from second_project.employee_data_cleaned
group by `Performance Score` with rollup
order by `Performance Score`
)SELECT *, Company_attrition AS company_avg_attrition
        FROM Performace_Score_attrition;

elseif attrition ="Department rate" then
		with Department_rate as (
		select `Department`,
					COALESCE(CAST(`Department` AS CHAR), 'Total Company Distribution') AS deparment,					
					cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS lefter_rate,
				    cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS stayer_rate
		from second_project.employee_data_cleaned
		group by Department  with rollup)
        SELECT *, Company_attrition AS company_avg_attrition
        FROM Department_rate;

elseif attrition ="Job role rate" then
			with Job_role_rate as (
		select `Job Role`, 
							COALESCE(CAST(`Job Role` AS CHAR), 'Total Company Distribution') AS jobrole,
							cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS lefter_rate,
							cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS stayer_rate
		from second_project.employee_data_cleaned
		group by `Job Role`  with rollup)
        SELECT *, Company_attrition AS company_avg_attrition
        FROM Job_role_rate;
        
elseif attrition ="Department rate" then
		with Satisfaction_rate as (
		select `Satisfaction Score`,
					COALESCE(CAST(`Satisfaction Score` AS CHAR), 'Total Company Distribution') AS satisfaction,
					cast((sum(CASE WHEN `attrition flag` = 1 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS lefter_rate,
					cast((sum(CASE WHEN `attrition flag` = 0 THEN 1 else 0 END) * 100.0 / count(*))as decimal(10,2)) AS stayer_rate
		from employee_survey_stagging  sur
		join second_project.employee_data_cleaned dat
			on sur.`Employee ID`=dat.`Employee ID`
		group by `Satisfaction Score` with rollup
        )
        SELECT *, Company_attrition AS company_avg_attrition
        FROM Satisfaction_rate;
        
elseif attrition = "Tenure attrition" then 
        select TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE())) years,

				count(case when `attrition flag`= 1 then `Employee ID` end ) as employee_left ,
				count(case when `attrition flag`= 0 then `Employee ID` end ) as employee_stay 				
		from second_project.employee_data_cleaned a
		group by TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE())) with rollup
		order by years desc;


else  
		select "Input invalid" as message;
		end if;
		
end $$

delimiter ;

CALL attrition_comparision("Tenure attrition");
# this are good to visualize but its to basic



DELIMITER $$
CREATE procedure diversity_distribution(in diversity varchar(50))
begin

if diversity = "gender" then

  SELECT 
         coalesce(Department,"Total Company Distribution") Department,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY Department WITH ROLLUP;

elseif diversity = "marital" then

    SELECT 
        COALESCE(Department, 'Total Company Distribution') AS Department,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset
    GROUP BY Department WITH ROLLUP;
    
elseif diversity = "race" then
SELECT 
    coalesce(Department,"Total Company Distribution") Department,
    sum( Race = 'Black' ) * 100 / NULLIF(COUNT(*), 0) Black,
    sum( Race = 'Asian' ) * 100 / NULLIF(COUNT(*), 0) Asian,
    sum(Race = 'White' ) * 100 / NULLIF(COUNT(*), 0) White,
    sum(Race = 'Hispanic' ) * 100 / NULLIF(COUNT(*), 0) Hispanic,
    sum(Race = 'Other' ) * 100 / NULLIF(COUNT(*), 0) Other
FROM
    diversity_dataset
GROUP BY Department with rollup
;
else  
	select "invalid must be gender.race,marital" as message;
    end if;
    
end $$

delimiter ;

call diversity_distribution("race"); 


delimiter $$
create procedure engagement_devirsity(engagementdevi varchar(255))
begin

if engagementdevi='gender' or engagementdevi='GENDER' then
    SELECT 
         coalesce(`Engagement Score`,"Total Company Distribution") enagagement,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY `Engagement Score` WITH ROLLUP
;

elseif engagementdevi='race' or engagementdevi='RACE' then



SELECT 
    coalesce(`Engagement Score`,"Total Company Distribution") Engagement ,
    sum( Race = 'Black' ) * 100 / NULLIF(COUNT(*), 0) Black,
    sum( Race = 'Asian' ) * 100 / NULLIF(COUNT(*), 0) Asian,
    sum(Race = 'White' ) * 100 / NULLIF(COUNT(*), 0) White,
    sum(Race = 'Hispanic' ) * 100 / NULLIF(COUNT(*), 0) Hispanic,
    sum(Race = 'Other' ) * 100 / NULLIF(COUNT(*), 0) Other
FROM
    diversity_dataset
GROUP BY `Engagement Score` with rollup
 ;

elseif engagementdevi='marital' or engagementdevi='MARITAL' then

    SELECT 
        COALESCE(`Engagement Score`, 'Total Company Distribution') AS engagement,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset 
    GROUP BY `Engagement Score` WITH ROLLUP
;


else 
		SELECT "invalid input" as message;
        end if ;
end $$
delimiter ;;




delimiter $$
create procedure tenure_devirsity(tenuredevi varchar(255))
begin

if tenuredevi='gender' or tenuredevi='GENDER' then
  SELECT 
         coalesce(tenure_months,"Total Company Distribution") tenure_months,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY tenure_months WITH ROLLUP
;

elseif tenuredevi='race' or tenuredevi='RACE' then



SELECT 
    coalesce(tenure_months,"Total Company Distribution") tenure ,
    sum( Race = 'Black' ) * 100 / NULLIF(COUNT(*), 0) Black,
    sum( Race = 'Asian' ) * 100 / NULLIF(COUNT(*), 0) Asian,
    sum(Race = 'White' ) * 100 / NULLIF(COUNT(*), 0) White,
    sum(Race = 'Hispanic' ) * 100 / NULLIF(COUNT(*), 0) Hispanic,
    sum(Race = 'Other' ) * 100 / NULLIF(COUNT(*), 0) Other
FROM
    diversity_dataset
GROUP BY tenure_months with rollup
 ;

elseif tenuredevi='marital' or tenuredevi='MARITAL' then

    SELECT 
        COALESCE(tenure_months, 'Total Company Distribution') AS tenure,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset 
    GROUP BY tenure_months WITH ROLLUP
;


else 
		SELECT "invalid input" as message;
        end if ;
end $$
delimiter ;;




delimiter $$
create procedure devirsity_attrition(attritiondevi varchar(255))
begin

if attritiondevi='gender' or attritiondevi='GENDER' then
  SELECT 
         coalesce(`attrition flag`,"Total Company Distribution") tenure_months,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY `attrition flag` WITH ROLLUP
;

elseif attritiondevi='race' or attritiondevi='RACE' then



SELECT 
    coalesce(`attrition flag`,"Total Company Distribution") tenure ,
    sum( Race = 'Black' ) * 100 / NULLIF(COUNT(*), 0) Black,
    sum( Race = 'Asian' ) * 100 / NULLIF(COUNT(*), 0) Asian,
    sum(Race = 'White' ) * 100 / NULLIF(COUNT(*), 0) White,
    sum(Race = 'Hispanic' ) * 100 / NULLIF(COUNT(*), 0) Hispanic,
    sum(Race = 'Other' ) * 100 / NULLIF(COUNT(*), 0) Other
FROM
    diversity_dataset
GROUP BY `attrition flag` with rollup
 ;

elseif attritiondevi='marital' or attritiondevi='MARITAL' then

    SELECT 
        COALESCE(`attrition flag`, 'Total Company Distribution') AS tenure,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset 
    GROUP BY `attrition flag` WITH ROLLUP
;


else 
		SELECT "invalid input" as message;
        end if ;
end $$
delimiter ;;

call diversity_attrition("marital")



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





































-- ********************************************************* use this a reference to enhance the attrition procedure*****************************************************
# this is really nice an i might extend my procedure to do this but for now i will just the simple one for now atleats when i have time 
-- i wil do this
DELIMITER //

CREATE PROCEDURE GetAttritionAnalysis(
    IN department_filter VARCHAR(255),
    IN jobrole_filter VARCHAR(255),
    IN satisfaction_filter INT
)
BEGIN
    WITH Engagementattrition AS (
        SELECT 
            survey.`Engagement Score`,
            COUNT(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS lefter_rate,
            COUNT(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS stayer_rate
        FROM second_project.employee_data_cleaned AS employee
        JOIN employee_engagement_survey_data AS survey
            ON employee.`Employee ID` = survey.`Employee ID`
        GROUP BY survey.`Engagement Score`
    ),
    CompanyAttrition AS (
        SELECT 
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS company_avg_attrition
        FROM second_project.employee_data_cleaned
    ),
    Department_attrition AS (
        SELECT `Department`,
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS lefter,
            SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS stayer
        FROM second_project.employee_data_cleaned
        GROUP BY Department
    ),
    jobrole_attrition AS (
        SELECT `Job Role`, 
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS jobrole_attrition_rate_left,
            SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(count(*), 0) AS jobrole_attrition_rate_stay
        FROM second_project.employee_data_cleaned
        GROUP BY `Job Role`
    ),
    Satisfaction_Score AS (
        SELECT `Satisfaction Score`,
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100 / NULLIF(count(*), 0) AS leftemployee_satisfaction,
            SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100 / NULLIF(count(*), 0) AS stayemployee_satisfaction
        FROM employee_survey_stagging sur
        JOIN second_project.employee_data_cleaned dat
            ON sur.`Employee ID` = dat.`Employee ID`
        GROUP BY `Satisfaction Score`
    )
    
    -- FINAL SELECT WITH FILTERING LOGIC
    SELECT *
    FROM Satisfaction_Score ss
    JOIN Department_attrition da ON 1=1
    JOIN jobrole_attrition ja ON 1=1
    WHERE 
        (department_filter IS NULL OR da.Department = department_filter)
        AND (jobrole_filter IS NULL OR ja.`Job Role` = jobrole_filter)
        AND (satisfaction_filter IS NULL OR ss.`Satisfaction Score` = satisfaction_filter);

END //

DELIMITER ;





















DELIMITER $$

CREATE PROCEDURE attrition_comparision(
    IN attrition VARCHAR(250),
    OUT Companyattrition DECIMAL(10,2)
)
BEGIN
    -- Calculate company-wide attrition and store it in the OUT variable
    SELECT COUNT(CASE WHEN `attrition flag` = 1 THEN `Employee Id` END) * 100.0 / NULLIF(COUNT(*), 0)
    INTO Companyattrition
    FROM second_project.employee_data_cleaned;

    -- Return results based on attrition type
    IF attrition = "Engagement rate" THEN
        SELECT 
            survey.`Engagement Score`,
            COUNT(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS lefter_rate,
            COUNT(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS stayer_rate,
            Companyattrition AS company_attrition
        FROM second_project.employee_data_cleaned AS employee
        JOIN employee_engagement_survey_data AS survey
            ON employee.`Employee ID` = survey.`Employee ID`
        GROUP BY survey.`Engagement Score`;

    ELSEIF attrition = "Department rate" THEN
        SELECT 
            `Department`,
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS lefter,
            SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS stayer,
            Companyattrition AS company_attrition
        FROM second_project.employee_data_cleaned
        GROUP BY Department;

    ELSEIF attrition = "Job role rate" THEN
        SELECT 
            `Job Role`, 
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS jobrole_attrition_rate_left,
            SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS jobrole_attrition_rate_stay,
            Companyattrition AS company_attrition
        FROM second_project.employee_data_cleaned
        GROUP BY `Job Role`;

    ELSEIF attrition = "Satisfaction Score" THEN
        SELECT 
            `Satisfaction Score`,
            SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(*), 0) AS leftemployee_satisfaction,
            SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(*), 0) AS stayemployee_satisfaction,
            Companyattrition AS company_attrition
        FROM employee_survey_stagging sur
        JOIN second_project.employee_data_cleaned dat
            ON sur.`Employee ID` = dat.`Employee ID`
        GROUP BY `Satisfaction Score`;

    ELSE  
        SELECT "Input invalid" AS message;
    END IF;

END $$

DELIMITER ;

