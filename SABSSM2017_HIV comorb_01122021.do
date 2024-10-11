*Stata version 15.1
*** 
************************************************************************
* PART 0: TABLE OF CONTENTS
************************************************************************
clear

* start log 
*capture log close
*log using 


* Project: [Multimorbidity in South Africa - SABSSM 2017]
* Creator: [Rifqah Roomaney, rifqah.roomaney@mrc.ac.za, 10/09/2021] 
* Purpose of do-file: Data analysis of SABSSM 2017 - HIV comorbidities
/*
	Outline
	Part 1: Housekeeping & Introduction
	
*/
************************************************************************
* PART 1: HOUSEKEEPING & INTRODUCTION
************************************************************************
*set more off, permanently //This gives all the output at once without having to click "more"

*Setting file path
global BASE "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS"

* SOURCE FILES DIRECTORIES
global SABSSM2017 "SABSSM\Dataset\2017\SABSSM2017_Combined.dta"

use "$BASE/$SABSSM2017", clear

********************************
use "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS\1 My project\Data\SABSSM2017_mm_01122021.dta"
svyset psu[pweight=csweight], strata(stratum) vce(linearized) singleunit(certainty) 

**Create two age categories for under 50s and over 50s
tab age
recode age (15/49= 1 "Under 50s") (50/107=2 "50+"),generate(age50)  //create age groups

**Drop if person does not have HIV
tab hiv
keep if hiv==1    
**Note: 24 141 obs deleted, 3755 remain  

tab age50

tab mm_index
label define Multimorbidity 0 "HIV only" 1 "Comorbid", replace

save "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS\1 My project\Data\SABSSM2017_HIVonly_05122021.dta", replace


**Descriptive stats by age (Table 1)
use "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS\1 My project\Data\SABSSM2017_HIVonly_05122021.dta"

histogram age, normal
summarize age, detail
summarize age if age50==1, detail
summarize age if age50==2, detail

tab gender
tab gender age50, col chi

tab race
tab race age50, col chi

tab stratum
tab stratum age50, col chi


tab urban
tab urban age50, col chi

tab educat
tab educat age50, col chi

tab employed
tab employed age50, col chi

**Number of diseases(Table 2)
tab index

recode index(1=1) (2=2) (3=3) (4=4) (5=4) (6=4), gen(index2) 	// Index numbers are small so we collapse one group


svy linearized : proportion index2
svy linearized : proportion index2, over(age50)


**Prevalence of HIV comorbidity (Table 3)


svy linearized : proportion mm_index
svy linearized : proportion mm_index, over(age50)


* What are the comorbidities by age? (Table 4)

svy linearized : proportion SELFHYPERTENSION
svy linearized : proportion SELFHYPERTENSION, over(age_10)
svy linearized : proportion SELFHYPERTENSION, over(age50)
svy linearized : proportion SELFHYPERTENSION, over(gender)




svy linearized : proportion SELFDIAB
svy linearized : proportion SELFDIAB, over(age_10)
svy linearized : proportion SELFDIAB, over(age50)
svy linearized : proportion SELFDIAB, over(gender)





svy linearized : proportion SELFTB
svy linearized : proportion SELFTB, over(age_10)
svy linearized : proportion SELFTB, over(age50)
svy linearized : proportion SELFTB, over(gender)



svy linearized : proportion SELFCANCER
svy linearized : proportion SELFCANCER, over(age_10)
svy linearized : proportion SELFCANCER, over(age50)
svy linearized : proportion SELFCANCER, over(gender)


svy linearized : proportion SELFHIV
svy linearized : proportion SELFHIV, over(age_10)
svy linearized : proportion SELFHIV, over(age50)

svy linearized : proportion SELFHEART
svy linearized : proportion SELFHEART, over(age_10)
svy linearized : proportion SELFHEART, over(age50)
svy linearized : proportion SELFHEART, over(gender)

*regression (factors associated with having a comorbidity)
svy: logistic mm_index age50
svy: logistic mm_index gender
svy: logistic mm_index urban
svy: logistic mm_index i.educat
svy: logistic mm_index employed
svy: logistic mm_index CURRALC


logistic mm_index age50 gender  urban i.educat employed  CURRALC 
svy: logistic mm_index age50 gender  urban i.educat employed  CURRALC 
svylogitgof    
                  
**Model checking:
logistic mm_index age50 gender  urban i.educat employed  CURRALC 
capture drop p stdres
predict p
predict stdres, rstand
scatter stdres p, mlabel(id) ylab(-4(2) 16) yline(0)

list id mm_index age50 gender urban educat  employed  CURRALC   if (stdres >4 & stdres <.)

scatter stdres id, mlab(id) ylab(-4(2) 16) yline(0)
predict dv, dev
scatter dv p, mlab(id) yline(0)
scatter dv id, mlab(id)
predict hat, hat
scatter hat p, mlab(id)  yline(0)
scatter hat id, mlab(id)

predict dx2, dx2
predict dd, dd
scatter dx2 id, mlab(id)
scatter dd id, mlab(id)

predict dbeta, dbeta
scatter dbeta id, mlab(id)

qnorm stdres


*drop influentials
drop if (stdres >4 & stdres <.)
logistic mm_index age50 gender  urban i.educat employed  CURRALC 

predict p1
predict stdres1, rstand
scatter stdres1 p1, mlabel(id) ylab(-4(2) 16) yline(0) 
qnorm stdres1

scatter stdres1 id, mlab(id) ylab(-4(2) 16) yline(0)
predict dv1, dev
scatter dv1 p1, mlab(id) yline(0)
scatter dv1 id, mlab(id)
predict hat1, hat
scatter hat1 p, mlab(id)  yline(0)
scatter hat id, mlab(id)

predict dx2, dx2
predict dd, dd
scatter dx2 id, mlab(id)
scatter dd id, mlab(id)

predict dbeta1, dbeta
scatter dbeta1 id, mlab(id)
