# analyze if the company is not baised like does some depaertmnt have more male or female or have more white than black
	-- the purpose is to improve the company equatibility or suggest it 

# just did this because i dont want to join to much
create table diversity_dataset as 
(
SELECT 
    a.`Employee ID`,
    a.ExitDate,
    a.Department,
    a.Gender,
    a.`Job Role`,
    a.Race,
    a.`Marital status`,
    a.`Performance Score`,
    a.`Current Employee Rating`,
    b.`Engagement Score`,
    b.`Satisfaction Score`,
    TIMESTAMPDIFF(year, a.StartDate, COALESCE(a.ExitDate, CURDATE()))tenure_year,
    a.`attrition flag`
    from employee_data_cleaned a
        JOIN
    employee_survey_stagging b ON a.`Employee ID` = b.`Employee ID`
);






# i want to analyze them one by one first
# do this for all the query after dont 				½W♣
#👍 this look at the devirsity of gender in deparment some deparment might be baised to some gender but it need to see attriton to confirm
	-- maybe improve this by race,retention or something else because kinda narrow still good
#stored
 WITH gender_distribution AS (
    SELECT 
         coalesce(Department,"Total Company Distribution") Department,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY Department WITH ROLLUP
)

SELECT 
    *
FROM gender_distribution;




 #👍`look at the race distribution in deparment because some deparment might be baised to some race but it need to see attriton to confirm
	-- maybe improve this by race,retention or something else because kinda narrow still good
#stored
 with department_race_distribution as 
(
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
 )SELECT 
    *
FROM
   department_race_distribution
 ;






 #👍`look at the race distribution in deparment some deparment might be baised to some maritial but it need to see attriton to confirm
	-- maybe improve this by race,retention or something else because kinda narrow still good
    -- STILL 	think this is not really usefull unless if married divored have a high attrition because the reason they could leave is their personal life 
		-- or poor lifeworkbalance
#stored
WITH department_marital AS (
    SELECT 
        COALESCE(Department, 'Total Company Distribution') AS Department,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset 
    GROUP BY Department WITH ROLLUP
)
SELECT * FROM department_marital;








#made this so that i can see what is the rate of diffirent diversity good if am on production so that i dont have to do it over and over again
	-- i just have to put a name and it will show
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


select * from diversity_dataset;




#👍``combined this with attriton to answer see if male and female engagement contribute to high attrition
		-- i coulk combined it with department but i dint see the reason todo that since most of the gender is equal to deparment except with one but i could tryx
#stored
WITH engagement_distribution AS (
    SELECT 
         coalesce(`Engagement Score`,"Total Company Distribution") enagagement,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY `Engagement Score` WITH ROLLUP
)
SELECT 
    *
FROM engagement_distribution;




 #👍``combined this with attriton to answer see if race engagement contribute to high attrition
	-- combine this with department to see if some department treat certain race badly or having poor management
#stored
 with engagement_race_distribution as 
(
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
 )SELECT 
    *
FROM
   engagement_race_distribution 
 ;


select * from diversity_dataset;



#👍 i wantto now if certian marittal have lower engagement that can be cause by pwersonal problem
	-- this isgood i dont have to combine with anything except attriton because this could cause loss of focus and cause stress and thus adding to attrition
#stored
WITH engagement_marital AS (
    SELECT 
        COALESCE(`Engagement Score`, 'Total Company Distribution') AS engagement,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset 
    GROUP BY `Engagement Score` WITH ROLLUP
)
SELECT * FROM engagement_marital;






#useless
#stored
WITH tenure_distribution AS (
    SELECT 
         coalesce(tenure_months,"Total Company Distribution") tenure_months,
        SUM(Gender = 'Female') * 100 / NULLIF(COUNT(*), 0) AS female,
        SUM(Gender = 'Male') * 100 / NULLIF(COUNT(*), 0) AS male
    FROM diversity_dataset
    GROUP BY tenure_months WITH ROLLUP
)
SELECT 
    *
FROM tenure_distribution;




 # 👍 look at race tenure if some race have low on the 4 to 6 year then thatsa  sign that they are being suppress or being with hold of oppurtinity to grow
	-- or some of them being in 0 to 1 and having low means either they are being discriminated but look at this with attriton and department to confirm
 #stored
 with tenure_race_distribution as 
(
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
 )SELECT 
    *
FROM
   tenure_race_distribution 
 ;





 -- -------------------------------------------------------------------------------------------------------------
 #!!! i dont seethe reason for this to be put in the anlysis but i will leave this here
#stored
WITH tenure_marital AS (
    SELECT 
        COALESCE(tenure_months, 'Total Company Distribution') AS tenure,
        SUM(`Marital status` = 'Married') * 100 / NULLIF(COUNT(*), 0) AS Married,
        SUM(`Marital status` = 'Widowed') * 100 / NULLIF(COUNT(*), 0) AS Widowed,
        SUM(`Marital status` = 'Single') * 100 / NULLIF(COUNT(*), 0) AS Single,
        SUM(`Marital status` = 'Divorced') * 100 / NULLIF(COUNT(*), 0) AS Divorced
    FROM diversity_dataset 
    GROUP BY tenure_months WITH ROLLUP
)
SELECT * FROM tenure_marital;
 #!!! i dont seethe reason for this to be put in the anlysis but i will leave this here
WITH tenure_marital AS (
    SELECT 
        COALESCE(`Marital status`, 'Total Company Distribution') AS marital,
        SUM(tenure_months = 0) * 100 / NULLIF(COUNT(*), 0) AS 0_year,
        SUM(tenure_months = 1) * 100 / NULLIF(COUNT(*), 0) AS 1_year,
        SUM(tenure_months = 2) * 100 / NULLIF(COUNT(*), 0) AS 2_year,
        SUM(tenure_months = 3) * 100 / NULLIF(COUNT(*), 0) AS 3_year,
        SUM(tenure_months = 4) * 100 / NULLIF(COUNT(*), 0) AS 4_year,
		SUM(tenure_months = 5) * 100 / NULLIF(COUNT(*), 0) AS 5_year,
        SUM(tenure_months = 6) * 100 / NULLIF(COUNT(*), 0) AS 6_year
    FROM diversity_dataset 
    GROUP BY `Marital status` WITH ROLLUP
)
SELECT * FROM tenure_marital;

-- -------------------------------------------------------------------------------------------------------------



# i want to figure out which department have the best retention  
# 👍 i can actual use this but need to refine this 
	-- this can be use to identify the reason why some department have more people in 5 to 6 year , i all ready know that the 
	-- highest people in lefter is only 4 years do their is definitelu have good retention for people with more years so i just need to know
		-- why yhey leave or they could be an organization that make it hard to be senior and not giving enough oppurtinity to the 4year below
   SELECT Department,tenure_year,
   count(tenure_year) count_of_6_to_5_year
    FROM diversity_dataset 
where tenure_year>4
    GROUP BY tenure_year,Department 
    order by tenure_year,Department ;



# anything with this have to type of analyze becuase one of them might be better for analyze than the other 
-- -------------------------------------------------------------------------------------------------------------
# now this look more use full 
#this could be good because i analysis attrition,race,departmnet a covariate 
#👍`this is good because this answer attrition,race,departmnet  at the same time and give an more refine and realistic answer
with race_distribution as 
(
SELECT Department,Race,
    sum( `attrition flag` = 1 ) * 100 / NULLIF(COUNT(*), 0) lefte,
    sum( `attrition flag` = 0 ) * 100 / NULLIF(COUNT(*), 0) stay

FROM
    diversity_dataset

GROUP BY Race,Department
order by Race,Department
 )SELECT 
    *
FROM
   race_distribution 
 ;




-- -------------------------------------------------------------------------------------------------------------



#✌might be good but meh
#stored
WITH tenure_distribution AS (
    SELECT 
         coalesce(Gender,"Total Company Distribution") tenure_months,
        SUM(`attrition flag` = 0) * 100 / NULLIF(COUNT(*), 0) AS lefter,
        SUM(`attrition flag` = 1) * 100 / NULLIF(COUNT(*), 0) AS stay
    FROM diversity_dataset
    GROUP BY Gender WITH ROLLUP
)

SELECT 
    *
FROM tenure_distribution;
-- -------------------------------------------------------------------------------------------------------------
#!!! already done this
#stored
WITH engagement_marital AS (
    SELECT 
        COALESCE(CAST(`Engagement Score` AS CHAR), 'Total Company Distribution') AS engagement,
        SUM(CASE WHEN `attrition flag` = 0 THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(COUNT(*), 0) AS lefter,
        SUM(CASE WHEN `attrition flag` = 1 THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(COUNT(*), 0) AS stay
    FROM diversity_dataset 
    GROUP BY `Engagement Score` WITH ROLLUP
)
SELECT * FROM engagement_marital;




#!!! already done this
#stored
WITH engagement_marital AS (
    SELECT 
        COALESCE(`Engagement Score`, 'Total Company Distribution') AS engagement,
        SUM(`attrition flag` = 0) * 100 / NULLIF(COUNT(*), 0) AS lefter,
        SUM(`attrition flag` = 1) * 100 / NULLIF(COUNT(*), 0) AS stay
    FROM diversity_dataset 
    GROUP BY `Engagement Score` WITH ROLLUP
)
SELECT * FROM engagement_marital;

-- -------------------------------------------------------------------------------------------------------------



#this is good because its a covariate that answer and give out a more refine answer and not just an isolated one 
#👍 this answer the question of distribution ofgender and how much left and stay but make it better because its a bit confusing
#stored
WITH Department_gender_attrition AS (SELECT Gender,Department,
        SUM(`attrition flag` = 0 ) * 100 / NULLIF(COUNT(*), 0) AS stay,
        SUM(`attrition flag` = 1 ) * 100 / NULLIF(COUNT(*), 0) AS lefter
    FROM diversity_dataset
    GROUP BY Department,Gender
)
SELECT 
    *
FROM Department_gender_attrition ;

# this data shows that there is a good employee retention in 5 to 6 year employee but zero retention for 4 year below 
#check other if they are correct
#check other if they are correct
#👍 good you can figure why who to focus on for retention and ask why the retntion for low tenure
#stored
WITH tenure_attrition AS (
    SELECT 
     COALESCE(tenure_months, 'Total Company Distribution') AS tenureattrition,
        SUM(`attrition flag` = 0 ) * 100 / COUNT(*) AS stay,
        SUM(`attrition flag` = 1 ) * 100 / COUNT(*) AS lefter
    FROM diversity_dataset
    GROUP BY tenure_months with rollup
)
SELECT 
    *
FROM tenure_attrition;

#!!! kinda useless
#stored
#shit code
WITH tenure_marital AS (
    SELECT 
        COALESCE(`attrition flag`, 'Total Company Distribution') AS marital,
        SUM(tenure_months = 0) * 100 / NULLIF(COUNT(*), 0) AS 0_year,
        SUM(tenure_months = 1) * 100 / NULLIF(COUNT(*), 0) AS 1_year,
        SUM(tenure_months = 2) * 100 / NULLIF(COUNT(*), 0) AS 2_year,
        SUM(tenure_months = 3) * 100 / NULLIF(COUNT(*), 0) AS 3_year,
        SUM(tenure_months = 4) * 100 / NULLIF(COUNT(*), 0) AS 4_year,
		SUM(tenure_months = 5) * 100 / NULLIF(COUNT(*), 0) AS 5_year,
        SUM(tenure_months = 6) * 100 / NULLIF(COUNT(*), 0) AS 6_year
    FROM diversity_dataset 
    GROUP BY `attrition flag` WITH ROLLUP
)
SELECT * FROM tenure_marital;


-- -------------------------------------------------------------------------------------------------------------



#using coalesce is wrong where unless i want to know the total of stayer and lever but what i want to know is
	#the attrition by department and the overall of the company

# ✌meh
	-- this could be use for analysing why some have low to zero attriton but other have high
SELECT `Job Role`,
	SUM(case when `attrition flag` = 1 then 1 else 0 end)/sum(case when `attrition flag` = 0 then 1 else 0 end) * 100 / COUNT(*) AS lefter,
    SUM(case when `attrition flag` = 1 then 1 else 0 end) con
FROM diversity_dataset
group by `Job role`; # try reding this but with window function



#wrong analysis but a good analysis and ha s potential, pretty creative
-- ***************************************************************************************************    
#take exitdate and calculate the time it take to fill the role or department by taking the
# trainig time and if they are accepted if not then dont count 
# i need to count the position not the employee and sum the vacancy and finding the ave

#👍👍 definitely add but the vacancy day is wrong but the department and jobrole and lefter is good can be use 
	-- because its use to know the attrition of jobrole in each department because some joob role is the same and if other department 
	-- have it higher than other then they can learn from the lower rated jobrole
with vancy as (
select ExitDate,`Job Role`,Department,
	(case when `Training Outcome` = "Completed" then `Training Date` end ) replacement
from training_and_development_stagging a
join diversity_dataset b
		on a.`Employee ID`=b.`Employee ID`
),vacancy as
(
select 	Department,`Job Role`,
	TIMESTAMPDIFF(day,`ExitDate`,replacement)  vacancy_day
    from  (select * from vancy where replacement and `ExitDate` is not null) as t
),vacancy_calculation as (
SELECT `Job Role`,
	SUM(case when `attrition flag` = 1 then 1 else 0 end)/count(*) * 100  AS lefter
FROM diversity_dataset
group by `Job role`
)
select a.Department,a.`Job Role`,a.vacancy_day,b.lefter from vacancy a 
join vacancy_calculation b
	on a.`Job Role`=b.`Job Role`
where vacancy_day > 1
;
    
-- ***************************************************************************************************    
    
    
    
#👍 this is like teh better cerion of the previus one but for department  since this count the open role but kinda meh so 
-- i wil think if this is usefull to add
with vancy as (
SELECT 
    ExitDate,
    `Job Role`,
    Department,
    (CASE
        WHEN `Training Outcome` = 'Completed' THEN `Training Date`
    END) replacement
FROM
    training_and_development_stagging a
        JOIN
        
        
    diversity_dataset b ON a.`Employee ID` = b.`Employee ID`
),vacancy as
(
SELECT 
    Department,
    `Job Role`,
    TIMESTAMPDIFF(DAY,
        `ExitDate`,
        replacement) vacancy_day
FROM
    (SELECT 
        *
    FROM
        vancy
    WHERE
        replacement AND `ExitDate` IS NOT NULL) AS t
        
)
SELECT 
    a.`Department`,b.`Job Role`,
    count(case when `attrition flag`=1 then a.`Job Role`end) / COUNT(a.`Job Role`) * 100 vacancy_rate
    ,count(a.`Job Role`) AS total_role,
   any_value(b.vacancy_day) as department_vacancy,
    count(case when `attrition flag`=1 then a.`Job Role` end) open_role
FROM
    diversity_dataset a
        JOIN
    vacancy b ON a.`Department` = b.`Department`
WHERE
    b.vacancy_day > 1
GROUP BY `Department`,b.`Job Role`
;


# ok do it again but this time di one with depaertment you get the open day by grouping by department and
	-- getting the earliest exist of tht department and getting the lastest training with complete
    
    
    # ok i will do this and just get the ave of days and dat will me my open day and i will do Job role in depaertment instead of just department
    #✌ kinda useless
    with cte_vacancy as (
    SELECT 
    `Job Role`,Department,
    min(CASE
        WHEN ExitDate is not null THEN `ExitDate`
    END) exited, max(CASE
        WHEN `Training Outcome` = 'Completed' THEN `Training Date`
    END) started
FROM
    training_and_development_stagging a
        JOIN
    diversity_dataset b ON a.`Employee ID` = b.`Employee ID`
    where ExitDate is not null and `Training Outcome` = "Completed"
group by `Job Role`,Department)
,open_day as
(
SELECT 
    Department,
    `Job Role`,
    TIMESTAMPDIFF(DAY,
        exited,
        started) vacancy_day
FROM
    (SELECT 
        *
    FROM
        cte_vacancy
 ) AS t
        )select *from open_day
      ;
    
 
 
 
 
 
 
 
 
 
 #use this to analyze the jobrole
 #✌ kinda useless 
select `Job Role`,
min(ExitDate),min(`Training Date`) from diversity_dataset a 
join training_and_development_stagging b 
	on a.`Employee ID`=b.`Employee ID`
where ExitDate
 is not null and `Training Outcome` = "Completed"
group by `Job Role`;
    
    
    
select Department,any_value(`Job Role`) from diversity_dataset a 

group by Department,`Job Role`;
        
    
    
# i will leave this for now because there is just good result comming its either false and nits not becase of me its becase the data set seem to be made up and the data is lacking
	# or uincorrect but i will go back on this andtry something else becauase it a great analysis illike it but the dataset is shit
    
SELECT 
    *
FROM
    training_and_development_stagging;


#anything with !! or meh  need to stay since the code is good but not good eniygh to look at


			-- 									*************************************DONE*******************************************************




