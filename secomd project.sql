  -- fix the column names sep it by space 
							-- make header simpler like gender code
							-- replace blank space with null or fill them depending on the goal read it before doing this
                            -- because it might just be waste of time
                            -- creata table after done cleaning
select * from employee_data;

alter table employee_data -- should have not done this to the original next time create a new one first
rename column BusinessUnit to `Business Unit`,
rename column ADEmail to `Email`,
rename column EmployeeStatus to `Employee Status`,
rename column EmployeeClassificationType to `Employee Classification`,
rename column TerminationType to `Termination`,
rename column TerminationDescription to `Termination Description`,
rename column DepartmentType to `Department`,
rename column JobFunctionDescription to `Job Role`,
rename column GenderCode to `Gender`,
rename column LocationCode to `Location Code`,
rename column RaceDesc to `Race`,
rename column MaritalDesc to `Marital status`
; 

alter table employee_data
change FirstName `First Name` varchar(50),
change LastName `Last Name` varchar(50);

create table employee_data_staging as
with duplicate_cte as 
(
select * ,row_number() over(PARTITION BY `Employee ID`, `First Name`, `Last Name`, StartDate, ExitDate, Title, Supervisor, Email, `Business Unit`, `Employee Status`, EmployeeType, PayZone, `Employee Status`, Termination, `Termination Description`, Department, Division, DOB, State, `Job Role`, Gender, `Location Code`, Race, `Location Code`, `Performance Score`, `Current Employee Rating`) rownum
FROM employee_data )
select * from duplicate_cte
where rownum = 1; 

 
update employee_data_staging
set `StartDate`=str_to_date(`StartDate`,"%d-%b-%Y"); 

 alter table employee_data_staging
 modify `Started Date` date;
 
 update employee_data_staging     -- updating blank to null
 set `Termination Description` = null
 where `Termination Description`= "" ;  
 
update employee_data_staging
set `Exit Date`=str_to_date(`Exit Date`,"%d-%b-%Y"); 

alter table employee_data_staging
modify `Exit Date` date;

select * from employee_data_staging
;
 


							# apply to all
								-- check for duplicate
                                -- replace blank space with null or fill them
								-- before doing anything to fix think why would i do this is ,will this help with 
									-- analysing the data if not then dont bother
								-- read goal it before doing this
									-- because it might just be waste of time

select * from employee_engagement_survey_data			-- reformat the date--
 
;

update employee_engagement_survey_data				-- didnt really have to do this since its already in the right format
set `Survey Date`=str_to_date(`Survey Date`,"%d-%m-%Y");

alter table employee_engagement_survey_data
modify `Survey Date` date;

create table employee_survey_stagging as
with survey_cte as 
(
select *,row_number() over(partition by `Employee ID`, `Survey Date`, `Engagement Score`, `Satisfaction Score`, `Work-Life Balance Score` ) rownum
from employee_engagement_survey_data
)
select * from survey_cte
where rownum =1;

alter table employee_survey_stagging 
drop column rownum;

select * from employee_survey_stagging;






create table recruitment_stagging as
with recruitment_cte as
(
select *,row_number() over(partition by `Applicant ID`, `Application Date`, `First Name`, `Last Name`, Gender, `Date of Birth`, `Phone Number`, Email, Address, City, State, `Zip Code`, Country,`Education Level`, `Years of Experience`, `Desired Salary`, `Job Title`, Status) rownum
from recruitment_data 
)
select * from recruitment_cte
where rownum =1;

 alter TABLE recruitment_stagging
drop column rownum;

													-- change the ### in phone number to null
													-- seperate the main number from extention '(310-288-9663)x(946)' 
                                                    -- standardsize the phone number if its important if not just delete it 
														-- i dont really need the phone number so i will just delete it same with email 
                                                         -- but i will not delete for now because  i migth need it when i have an idea i will delete and am truly done
                                                    -- reformat the application date because the date birth is not needed in analysis
                                                    
select * from recruitment_stagging;
 
 update recruitment_stagging
 set `Application Date`=str_to_date(`Application Date`,"%d-%b-%Y");
 
 ALTER table recruitment_stagging
 MODIFY `Application Date` date;







select * from training_and_development_data				-- check if data is correct format
														-- i dont think i need to change the date since i might not use ut but just incase
;
create table training_and_development_stagging as
with training_cte as
(
select *,row_number() over(partition by `Employee ID`, `Training Date`, `Training Program Name`, `Training Type`,`Training Outcome`, Location, Trainer, `Training Duration(Days)`, `Training Cost`) rownum 
from training_and_development_data
)
select * from training_cte
where rownum =1;

 alter TABLE training_and_development_stagging
drop column rownum;
 
 update training_and_development_data
 set `Training Date`=str_to_date(`Training Date`,"%d-%b-%Y");
 
 ALTER table training_and_development_data
 MODIFY `Training Date` date;



select * from employee_data_staging;
select * from employee_survey_stagging;
