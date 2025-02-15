#goal = find category with the highest rejection and maybe do a correlation if does with highest correlation actually
			-- correlation with the high rejection
	-- this low experience ,education level,desired salary have some thing to do with rejection 
  -- What is the success rate of applicants based on their education level or experience and desired salary?
-- KINDA USELESS ANALYSIS becuase of the small data of jobtitle
 SELECT distinct * From recruitment_stagging;

#add jobrole for this
with education_level_job as (
SELECT  `Education level`,`Job Title`,
	count(case when Status = "Rejected" then `Applicant ID` end)*100/NULLIF(count(*), 0) rejected,
    count(case when Status = "Applied" then `Applicant ID` end)*100/NULLIF(count(*), 0) applied,
    count(case when Status = "Interviewing" then `Applicant ID` end)*100/NULLIF(count(*), 0)  interview,
      
    count(case when Status = "In Review" then `Applicant ID` end)*100/NULLIF(count(*), 0) in_review,
    count(case when Status = "Offered" then `Applicant ID` end)*100/NULLIF(count(*), 0) offered
 From recruitment_stagging
 group by `Job Title`,`Education level`
 ),overall as
 (select `Job TItle`,count(case when Status = "Rejected" then `Applicant ID` end)*100/NULLIF(count(*), 0) overall_rejected_jobtile,
		count(case when Status = "Interviewing" then `Applicant ID` end)*100/NULLIF(count(*), 0) overall_interview_jobtile ,
          count(case when Status = "Interviewing" then `Applicant ID` end) interview_count,
        count(case when Status = "Offered" then `Applicant ID` end)*100/NULLIF(count(*), 0) overall_offered_jobtile
 from recruitment_data
 group by `Job Title`
 )select a.`Education Level`,
		a.`Job Title`
		,a.interview
        ,o.overall_interview_jobtile 
 
 from education_level_job a
 join overall o
 
	on a.`Job Title`=o.`Job Title`
where interview >= 1 and a.`Job Title` = 'Psychologist, prison and probation services'
order by `Education level`
 ;

 
 #divide the overall to the actual count of status and group that by job roll because just dividng it by who comapany row is unfiar
 
 select   count(case when `Job Title` = 'Psychologist, prison and probation services' and Status = "Interviewing" then `Applicant ID` end) interview_count 
	from recruitment_stagging;
 
  select * from recruitment_stagging;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 #👍 good analysis but code be better
 #this anwser the question what is the education acceptance rate and wether having higher education = to more acceptance
	# but this is good but could be better since i has a probrom of some peuple just appleid and is still in applied and inreview
	# so maybe add some date on this to make this better and more understandble to see if the one in higher education applied way letter then
	# the other .this isto confirm if time of application is not  the fault of of some of them still being in applied and inreview since 'Master''s Degree'
	#have a weird data and also do one with years of experi
 with education_level_acceptance as (
SELECT  `Education level`,
	count(case when Status = "Rejected" then `Applicant ID` end)*100/NULLIF(count(*), 0) rejected,
    count(case when Status = "Applied" then `Applicant ID` end)*100/NULLIF(count(*), 0) applied,
    count(case when Status = "Interviewing" then `Applicant ID` end)*100/NULLIF(count(*), 0) interview,
    count(case when Status = "In Review" then `Applicant ID` end)*100/NULLIF(count(*), 0) in_review,
    count(case when Status = "Offered" then `Applicant ID` end)*100/NULLIF(count(*), 0) offered
 From recruitment_stagging
 group by `Education level`
 ),overall as
 (select count(case when Status = "Rejected" then `Applicant ID` end)*100/NULLIF(count(*), 0) overall_rejected,
		count(case when Status = "Interviewing" then `Applicant ID` end)*100/NULLIF(count(*), 0) overall_interviw,
        count(case when Status = "Offered" then `Applicant ID` end)*100/NULLIF(count(*), 0) overall_offered
 from recruitment_data
 )select * from education_level_acceptance
 join overall 
	on 1=1
 ;
 
 

 
 
 
 
 
 
 
 
 
 
 
 SELECT distinct `Years of Experience` From recruitment_stagging;
 

 #👍this anwser if years of experience have corelation in having hiring acceptance than other expirience 	
	-- cast count(*) to decimal since it does not equal to 100 means its round to the nearest number
    -- and code make it better
 with year_experience_acceptance as (
SELECT  `Years of Experience`,
	count(case when Status = "Rejected" then `Applicant ID` end)*100/count(*) rejected,
 #   count(case when Status = "Applied" then `Applicant ID` end) rejected_count,
    count(case when Status = "Applied" then `Applicant ID` end)*100/count(*) applied,
    count(case when Status = "Interviewing" then `Applicant ID` end)*100/count(*) interview,
   # count(case when Status = "Interviewing" then `Applicant ID` end) interview_count,
    count(case when Status = "In Review" then `Applicant ID` end)*100/count(*) in_review,
    count(case when Status = "Offered" then `Applicant ID` end)*100/count(*) offered
 #    count(case when Status = "Offered" then `Applicant ID` end) offered_vount
 From recruitment_stagging
 group by `Years of Experience`
 
 )select * from year_experience_acceptance
order by 1
 ;
 

 #🤢 true
 #this is useless to  
  with year_experience_acceptance as (
SELECT  `Years of Experience`,`Job Title`, 
	count(case when Status = "Rejected" then `Applicant ID` end)*100/count(*) rejected,
    count(case when Status = "Rejected" then `Applicant ID` end) rejected_count,
    count(`Job Title`) job_count
    #count(case when Status = "Applied" then `Applicant ID` end)*100/count(*) applied,
    #count(case when Status = "Interviewing" then `Applicant ID` end)*100/count(*) interview,
    #count(case when Status = "Interviewing" then `Applicant ID` end) interview_count,
    #count(case when Status = "In Review" then `Applicant ID` end)*100/count(*) in_review,
    #count(case when Status = "Offered" then `Applicant ID` end)*100/count(*) offered,
    # count(case when Status = "Offered" then `Applicant ID` end) offered_vount
 From recruitment_stagging 
 group by `Years of Experience`,`Job Title`
 ),overall as
 (select count(case when Status = "Rejected" then `Applicant ID` end)*100/count(*) overall_rejected,
count(case when Status = "Rejected" then `Applicant ID` end) con
		#count(case when Status = "Interviewing" then `Applicant ID` end)*100/count(*) overall_interviw,
       # count(case when Status = "Offered" then `Applicant ID` end)*100/count(*) overall_offered
 from recruitment_data
group by`Years of Experience`
 )select * from year_experience_acceptance
 join overall 
	on 1=1
where rejected > 5
order by 1
 ;
 
 
 
			-- 									*************************************DONE*******************************************************
