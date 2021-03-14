/// indicators for data and field system



// cleans incosistencies from raw data and saves a clean version

	if c(username) == "Aarau" {
		
			global dofiles "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
		
	if c(username) == "Kkeck" {
		
			global dofiles "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
		
	do "$dofiles/globals.do"
	
	
*------------------------------------------------------------------------------

	cd "$clean"

********************************************************************************

***INDICATORS AT THE SCHOOL LEVEL

*******************************************************************************

* Girls
	use "$Qgirls/$Qgirls", clear
	
	
	
	sort school girl
	
	duplicates tag girl, gen(dupg)
	replace dupg = 0 if panel==0   
		
	gen newg = 1 if panel ==0  // count new girls to compare agains top up
	bys school: egen new_girls=sum(newg)
	
	gen learning = 1 if outcome==1
	bys school: egen Learn = sum(learning)
	drop learning
	
	gen absents = 1 if outcome==3
	bys school: egen Absent = sum(absents)
	drop absents
	
	gen transition = 1 if outcome==11
	bys school: egen Transit = sum(transition)
	drop transition
	
	bys school: gen GirlsAttempt = _N
	
	
	
	
	
	*attrition
	gen c =1 if outcome ==1 & newg==.	
	bys school: egen completed = sum(c)
	drop c
	
	*attrition - transition
	gen t = 1 if (outcome==1 | outcome==11) & newg==.
	bys school: egen completed_transition = sum(t)
	drop t
	
	bys school: keep if _n==1
	
	gen topup_rate =  new_girls/topup
	*replace topup_rate = 1 if topup_rate == .
	gen attrition = 1-(completed/size) 
	gen trans_attrit = 1 - (completed_transition/size)
		
	
	
	gen Attempted  = 1
	
	keep school dupg GirlsAttempt new_girls attrition topup_rate trans_attrit Attempted enumname Learn Absent Transit
	
	
	
	
	
	tempfile girls
	save `girls', replace
	
	
* SEGRA
	use "$Qseg/$Qseg", clear

	sort school girl
	
	duplicates tag girl, gen(dupseg)
	replace dupseg = 0 if panel==0   
		
	gen newg = 1 if panel ==0  // count new girls to compare agains top up
	bys school: egen SegNew=sum(newg)
	bys school: gen SegAttempt = _N
	bys school: keep if _n==1
	keep school dupseg SegAttempt SegNew

	tempfile seg
	save `seg', replace



*classroom observation
	use "$Qco/$Qco", clear
	
	
	label copy v1_out observation
	rename outcome observation
	label val observation observation
	
	sort Date Time
	
	duplicates tag school, gen(dupco)
	bys school: keep if _n==1
	order Date Time dupco
	
	label define observation 11 "Not attempted", add
	label define observation 99 "Missing school ID", add
	
	replace observation = 99 if school == .a
	
	tempfile obs
	save `obs', replace
	
*cohort tracking
	use "$Qct/$Qct", clear
	
	rename outcome cohort
	label copy outcome cohort
	label val cohort cohort
	
	sort Date Time
	
	duplicates tag school, gen(dupct)
	bys school: keep if _n==1
	order Date Time dupct	
	label define cohort 0 "Not attempted", add	
	label define cohort 99 "Missing school ID", add
	
	replace cohort = 99 if school == .a
	
	
	tempfile ct
	save `ct', replace
	
	
**head count
	use "$Qhc/$Qhc", clear
	
	label list outcome
	label copy outcome HeadCount
	rename outcome HeadCount
	label val HeadCount HeadCount
	
	
	
	sort Date Time
	
	duplicates tag school, gen(duphc)	
	bys school: keep if _n==1
	label define HeadCount 0 "Not attempted", add
	label define HeadCount 99 "Missing school ID", add
	
	replace HeadCount = 99 if school == .a
	
	
	tempfile hc
	save `hc', replace
	

**School Survey
	
	
	use "$Qss/$Qss", clear
	
	label copy outcome schoolS
	rename outcome schoolS
	label val schoolS schoolS
	
	
	sort Date Time
	
	duplicates tag school, gen(dupss)	
	bys school: keep if _n==1
	label define schoolS 0 "Not attempted", add
	label define schoolS 99 "Missing school ID", add
	
	replace schoolS = 99 if school == .a
	
	
	tempfile ss
	save `ss', replace
	

** Teacher Sampling

	use "$Qts/$Qts", clear
	
	label copy outcome teacher
	rename outcome teacher
	label val teacher teacher 
	
	duplicates tag school, gen(dupt)
	bys school: keep if _n==1
	label define teacher 0 "Not attempted", add	
	
	label define teacher 99 "Missing school ID", add
	
	replace teacher = 99 if school == .a
	
	tempfile t
	save `t', replace 
	


	use "$dashboard/schools", clear /// look up table of schools
	
	
	merge 1:m school using `obs', keepusing(observation dupco)

	replace observation = 11 if _merge!=3 & school!=.a
	replace dupco = 0 if dupco==.
	drop _merge 
	
	merge 1:m school using `ct', keepusing(cohort dupct)

	replace cohort = 0 if _merge!=3 & school!=.a
	replace dupct = 0 if dupct==.
	drop _merge 
	
	
	merge 1:m school using `hc', keepusing(HeadCount duphc)
	
	replace HeadCount = 0 if _merge!=3 & school!=.a
	replace duphc = 0 if duphc==.
	drop _merge 
	
	
	merge 1:1 school using `girls', keepusing(dupg GirlsAttempt new_girls attrition trans_attrit topup_rate Attempted enumname Learn Absent Transit)
	replace GirlsAttempt = 0 if _merge!=3 
	replace new_girls = 0 if _merge!=3
	replace dupg = 0 if dupg==.
	drop _merge 
	
	merge 1:1 school using `seg', keepusing(dupseg SegAttempt SegNew)
	replace SegAttempt = 0 if _merge!=3
	replace SegNew = 0 if _merge!=3
	replace dupseg = 0 if dupseg==.
	drop _merge 

	
	merge 1:m school using `ss', keepusing(dupss schoolS Date)
	replace schoolS = 0 if _merge!=3 & school!=.a
	replace dupss = 0 if dupss==.
	drop _merge 
	
	merge 1:m school using `t', keepusing(dupt teacher)
	replace teacher = 0 if _merge!=3 & school!=.a
	replace dupt = 0 if dupt==.
	drop _merge 
	

	
	
* last refreshed of dashboard:

* last run of dofile
	gen LastUpdate= "LAST REFRESH: `c(current_date)'  `c(current_time)' by `c(username)'"
	

* Days since survey started
	egen Day=group(Date)
	label var Day "Days since survey started"
		
	
	
	
* 	days to finish
	egen d=max(Day) //days since start in location
	egen c= sum(Approved) //total completed in location
	recode c (0=1) if c==0	
	gen daysToFinish=round(($samplesize- c)/(c/d))
	


	

* % Approved
	egen ap=sum(Approved)
	gen Per_Approved=ap/$samplesize
	
	
	gen a = "Yes" if Approved ==1
	replace a = "No" if Approved ==0 | Approved == . 
	
	drop Approved
	rename a Approved
	
	gen cohort_check=(GirlsAttempt >0  & cohort == 0)
	gen obs_check=(GirlsAttempt >0  & observation == 11)
	gen hc_cjecl =(GirlsAttempt >0  & HeadCount == 0)
	gen ss_check =(GirlsAttempt >0  & schoolS == 0)
	gen t_check =(GirlsAttempt >0  & teacher == 0)
	gen top_check = (GirlsAttempt >0  & topup-new_girls!=0)
	
	

*schoolid
	gen school_id = school
	label val school_id 
	
	


	br topup new_girls top_check
	
	rename county lga
	drop d c ap 
	replace Attempted  = 0 if Attempted == . 
	
	
		
	gen vischeck = Date!=""
	
//text for checks 
	count if dupco>0 
	if `r(N)'== 0 {
			gen text_DupCo=string(`r(N)') + " Duplicated IDs in class observation"
	}
	
	else {
		
		gen text_DupCo="*** " + string(`r(N)') + " Duplicated IDs in class observation"
	}

	                                     ***
	count if dupct>0 
	if `r(N)'== 0 {
			gen text_DupCt=string(`r(N)') + " Duplicated IDs in cohort tracker"
	}
	
	else {
		
		gen text_DupCt="*** " + string(`r(N)') + " Duplicated IDs in cohort tracker"
	}


		                                     ***

	
	count if duphc>0 
	if `r(N)'== 0 {
			gen text_Duphc=string(`r(N)') + " Duplicated IDs in head count"
	}
	
	else {
		
		gen text_Duphc="*** " + string(`r(N)') + " Duplicated IDs in in head count"
	}
	
	
		                                     ***

	count if dupg>0 
	if `r(N)'== 0 {
			gen text_Dupg=string(`r(N)') + " Duplicated IDs in girls questionnaire"
	}
	
	else {
		
		gen text_Dupg="*** " + string(`r(N)') + " Duplicated IDs in girls questionnaire"
	}
	
	
		                                     ***

	count if dupss>0 
	if `r(N)'== 0 {
			gen text_Dupss=string(`r(N)') + " Duplicated IDs in school survey"
	}
	
	else {
		
		gen text_Dupss="*** " + string(`r(N)') + " Duplicated IDs in school survey"
	}
	
	
		                                     ***

	count if dupt>0 
	if `r(N)'== 0 {
			gen text_Dupt=string(`r(N)') + " Duplicated IDs in teacher questionnaire"
	}
	
	else {
		
		gen text_Dupt="*** " + string(`r(N)') + " Duplicated IDs in teacher questionnaire"
	}
	
	count if dupseg>0 
	if `r(N)'== 0 {
			gen text_Dupseg=string(`r(N)') + " Duplicated IDs in Segra/segma"
	}
	
	else {
		
		gen text_Dupseg="*** " + string(`r(N)') + " Duplicated IDs in Segra/segma"
	}
	

	
	
	
	
	

export excel using "$dashboard/schools.xlsx", sheet("Schools") firstrow(var) replace



********************************************************************************

*Indicators for girls
********************************************************************************

*girl questionnaire

	use "$Qgirls/$Qgirls", clear
	
	
	label val girl 
	format girl %12.0g
	gen new_girl = "Yes" if panel == 0
	replace new_girl = "No" if panel == 1 
	keep outcome school girl girl_name new_girl county size panel enumname
	
	label copy outcome out_g
	
	rename outcome out_g
	label val out_g out_g
	label define out_g 0 "Not attempted", add
	
	sort school girl girl_name
		label val girl
		format girl %12.0g
		sort school girl girl_name
		
		bys school: replace girl = school *100 + size + (_N-_n +1) if panel ==0 // replace girl id for new girls
		bys school: replace girl = 9999*100 + _n if school ==.a & panel ==0 // for girls missing school id
	
	drop size panel 
	
	
	tempfile g
	save `g', replace
	
	
*segra questionnaire
	use "$Qseg/$Qseg", clear
	
	
	label val girl 
	format girl %12.0g
	gen SegNew = "Yes" if panel == 0
	replace SegNew = "No" if panel == 1 
	keep school girl girl_name SegNew 
	
	gen out_seg = 1
	label define out_seg 0 "Not attempted" 1 "Completed"
	label val out_seg out_seg
			
	
	tempfile seg
	save `seg', replace

	
	
*Cohort questionnaire

	use "$Qct/status.dta", clear
	
	keep girl girl_present girl_absent_long girl_enrolled girl_teach_conf girl_doing
	format girl %12.0g
	
	
	tempfile s
	save `s', replace 
	
	
	use "$lookup/girls_LU", clear
	
	merge 1:m girl using `g'
	*replace girl_new = "No" if _merge==1
	replace out_g = 0 if _merge==1
	replace new_girl = "No" if _merge ==1
	
	sort _merge
	
	gen name =girl_name if girl_name!=""
	levelsof girl, local(girls) 				    
		
			*girl name 
			foreach g in `girls' {  							
			
				local name: label girl `g'
				
				replace name = "`name'" if girl ==`g' & _merge==1
			}
			
			
	label val girl 
	
	
	drop _merge girl_name
	
	
	merge m:1 girl using `s', assert(1 3) nogen
	
	merge m:m girl using `seg' 
	
	
***create the checks for the outcome here---------- (as I did in line 216 for the completion of files)
	
	rename county lga

export excel using "$dashboard/Girls.xlsx", sheet("Girls") firstrow(var) replace

	
********************************************************************************


********************************************************************************


	





ex

/*
* Response rate
	
	gen rspRate=outcome==11
	

* Attrition
	gen attrition=outcome!=11
	
* gen concluida 
	gen Concluida = 0
	replace Concluida = 1 if outcome==11
	
*Approved and colcuida

	gen approved_concluida = (Concluida==1 & Approved==1)
	


	
		
				
	
	drop c drop d
	
*Interviews per day per interviewer
	
	bys Interviewer: egen a=sum(Concluida)  //interviews done by interiviewer
	bys Interviewer Date: gen d=_n // days worked by interviewer
	replace d = 0 if d>1 
	bys Interviewer: replace d= sum(d)
	gen intPerDay=a/d
	label var intPerDay "Avg. Interviews per day by interviewer"
	
	drop a d 
	
*SHIT HAPPENS


	gen shithappens = (start==2 & mode_Livro==1 & mode_Avisos==2 & inlist(mode_Sinais_num, 3,2))
	
	
*check edade
	gen edadecheck=edadeCheck!=.

*FULL SAMPLE FROM REFERENCE 
	
	merge m:1 hh_id using "$sample/MUVA City 2018 sampling frame_operational_2018_09_25", keepusing(desig_samp replace_samp seq city ea_id Bairo) nogen
	
	
	
	replace Bairro =Bairo if Bairro==.
	
	order city desig_samp replace_samp seq
	sort  city desig_samp replace_samp seq
	
	keep if desig_samp ==1
	drop desig_samp
	recode replace_samp (1=3) (0=1) 
	recode replace_samp (3=2)
	label define sampled 1 "SAMPLED" 2 "REPLACEMENT", modify
	label val replace_samp sampled
	
	rename replace_samp sampled
	
	
	*VISITED
	gen visited=interview__id!=""	
	gen todo = sampled - visited if sampled==1
	
	gen muestra=sampled
	recode muestra (2=0)
	
	*revisit
	gen Revisit = inlist(outcome,4,5,8) 
	*& sampled==1
	gen toReplace = !inlist(outcome, 4,5,8,11,.a) & interview__id!="" 
	*& sampled==1
	
	
	* fiter for approved 
	recode Approved (.=0)
	gen ApproveFilter="No"
	replace ApproveFilter="Yes" if Approved==1
	
	
	
 
*TEXT BOXES
*_____________________________________________________
 
* Not working hours 
	
	gen hour=substr(Time,1,2)
	destring hour, replace 
	
		
	gen NoWrkHr=1 if (hour<=6|hour>=20) & hour!=0
	recode NoWrkHr (.=0) 
	label var NoWrkHr "Interview conducted outside working hours"
	
	
	//text for outside working hours
	count if NoWrkHr>0 & Concluida==1
	if `r(N)'== 0 {
			gen Hourstxt=string(`r(N)') + " outside working hrs."
	}
	
	else {
		
		gen Hourstxt="*** " + string(`r(N)') + " outside working hrs."
	}
	
	drop hour
	
	
	
**duplicates in terms of hhid 
	
	duplicates tag hh_id, gen(duplicado)
	
	
	replace duplicado=1 if duplicado>0
	
	
	//text for duplicates
	count if duplicado>0 
	if `r(N)'== 0 {
			gen Duplicates=string(`r(N)') + " Duplicate HHID"
	}
	
	else {
		
		gen Duplicates="*** " + string(`r(N)') + " Duplicate HHID"
	}

	
	

	
**Missing Outcome 
	
	gen missOutcome = inlist(outcome,.,.a) & interview__id!=""
	
	//text for missing outcome 
	count if missOutcome>0 & interview__id!=""
	if `r(N)'== 0 {
			gen MissOuttxt=string(`r(N)') + " missing outcome"
	}
	
	else {
		
		gen MissOuttxt="*** " + string(`r(N)') + " missing outcome"
	}
	
*Duration 

//text for duration per question
	
	gen undertime=Duration<20 & Concluida==1
	count if undertime==1
	if `r(N)'== 0 {
			gen Durperqnntxt=string(`r(N)') + " < 20 minutes."
	}
	
	else {
		
		gen Durperqnntxt="*** " + string(`r(N)') + " < 20 minutes."
	}
	

*text shit happens

**Missing Outcome 
	
	
	
	//text for missing outcome 
	count if shithappens>0 & interview__id!=""
	if `r(N)'== 0 {
			gen shittxt=string(`r(N)') + " shit happens"
	}
	
	else {
		
		gen shittxt="*** " + string(`r(N)') + " shit happens"
	}

*Export indicators to dashboard file

#delim ;
	
	keep
	
	
	NoWrkHr Hourstxt duplicado LastUpdate daysToFinish intPerDay
	Duplicates lastAction missOutcome MissOuttxt outcome 
	Duration Durperqnntxt ApproveFilter Per_Approved rspRate
	attrition ea_id Approved city Bairro hh_id Date Time
	interview__id Interviewer undertime lit_level num_level
	link Concluida approved_concluida shithappens edadecheck
	shittxt sampled visited todo seq muestra Revisit toReplace
	 ;
	 
	 #delim cr
				
	
	
	export excel using "$dashboard/indicators.xlsx", sheet("All") firstrow(var) replace
	
	
	
	
	
	
	
	
	

*****CREATE TRACKING SHEETS FOR REPLACEMENTS_____________________________________________________ 


	merge m:1 hh_id using "$reference/sample_MUVA2018", keepusing(HouseholdHead endereco casa referencia respondent age sex) keep(3) nogen
	
	gen status="CONCLUIDA" if Concluida==1
	replace status ="REVISITAR" if Revisit==1
	replace status="REPLACE" if toReplace==1





		order city Bairro ea_id hh_id HouseholdHead endereco casa referencia respondent age sex seq status
	
				
				
		local valueCity: value label city 	              //label value of city
		
		qui levelsof city, local(Cities)    //local with bairos levels
		
		local f=0 								// local that starts a sequence for naming folder (first folder will be 01)
	
		foreach c in `Cities' {                 //foreach biaro in city
			local city: label `valueCity' `c' //name of bairo
			di "`0`f' `city****'" 
			local f=`f'+1						//add 1 every time so second folder is 02, third 03, etc.
			
			
			*count replacements 
			count if toReplace==1 & city==`c'
			local keep = `r(N)'
			di `keep'
				
			sort city sampled seq
			qui copy "$templates/masterTracking_replacements.xlsx" "$templates/0`f'. `city'/Replacements_`city'.xlsx", replace 		//copy the mastertracking file in the folder of the state and name it as the psu
			qui export excel city-status if city==`c' & seq<=`keep' & sampled==2 using "$templates/0`f'. `city'/Replacements_`city'.xlsx", sheetreplace firstrow(varl) sheet(Stata) 		//export variables to the templat
		
		}
			
				
		
		

	
