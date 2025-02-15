#i want to find the rate of training outcome of programs 
#i craeted my own question on this bacause the data does not allowe me to calculate what is need to  calculate 


#👍 this analyze the accetance rate of trainig program not really that usefull 
-- but i wanted to see if some training program have a higher failed or complete
with training as 
(
select `Training Program Name`,
		count(case when `Training Outcome` = "Failed" then `Employee ID` end)*100/NULLIF(count(*), 0) failed,
        count(case when `Training Outcome` = 'Completed' then `Employee ID` end)*100/NULLIF(count(*), 0) completed,
        count(case when `Training Outcome` = 'Passed' then `Employee ID` end)*100/NULLIF(count(*), 0) passed,
        count(case when `Training Outcome` = 'Incomplete' then `Employee ID` end)*100/NULLIF(count(*), 0) incomplte
  from training_and_development_stagging 
  group by `Training Program Name`
),company as 
(
select count(case when `Training Outcome` = "Failed" then `Employee ID` end)*100/NULLIF(count(*), 0) company_failed,
        count(case when `Training Outcome` = 'Completed' then `Employee ID` end)*100/NULLIF(count(*), 0) company_completed,
        count(case when `Training Outcome` = 'Passed' then `Employee ID` end)*100/NULLIF(count(*), 0) company_passed,
        count(case when `Training Outcome` = 'Incomplete' then `Employee ID` end)*100/NULLIF(count(*), 0) company_incomplte
  from training_and_development_stagging
  )select * from training
  join company
	on 1=1;
  



SELECT *
FROM training_and_development_stagging
 ;

#the couse of training to see what to improve
	-- but this could be better by adding it with training outcome to see if the money is being spend wisely and 
		-- if failed is spendingalot of money then thier migth be a problem with the trainer or somthing else(investigate)
with training as 
(
select `Training Program Name`,SUM(CAST(`Training Cost` AS SIGNED)) outcome_cost
  from training_and_development_stagging 
  group by `Training Program Name`
),company as 
(
select SUM(CAST(`Training Cost` AS SIGNED)) as company_cost
  from training_and_development_stagging
  )select * from training
  cross join company
	;
  




#👍this is good but group it by program
with training_outcome_cost as 
(
select `Training Outcome`,SUM(CAST(`Training Cost` AS SIGNED)) outcome_cost
  from training_and_development_stagging 
  group by `Training Outcome`
),company as 
(
select SUM(CAST(`Training Cost` AS SIGNED)) as company_cost
  from training_and_development_stagging
  )select * from training_outcome_cost
  cross join company
	;
  





			-- 							*************************************DONE*******************************************************






























































