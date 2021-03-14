clear all
set more off

// unzip downloads, appends them and fetch interviews diagnostics 



	
	if c(username) == "Aarau" {
		
			global dofiles "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
		
	if c(username) == "Kkeck" {
		
			global dofiles "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
	
	do "$dofiles/globals.do"
	
	
	
	
		
*1) UNZIP INTERVIEWS 	
***___________________________________________________________________________

 

*REMOVE and create C directory

		cap $remove "$C" $s	  //remove directory
		cap mkdir "$C"		//create directory
		
		cap mkdir "$raw"		//create raw irectory
		
		


*UNZIP VERSIONS
	
	local versions: dir "$downloads" file "*.zip", respectcase
	
	
	
	foreach v in `versions' {
*		di "`v'"
		local version = subinstr("`v'", "_STATA_All.zip", "", 1) //name of the version
*		di "`version'"
		
		$remove "$raw/`version'" $s	  //remove directory
		cap mkdir "$raw/`version'"		//create directory
		
		qui cd "$raw/`version'"
		*qui unzipfile "$downloads/`v'", replace  //unzip files by version
		shell "C:\Program Files\7-Zip\7zG.exe" e -y "${downloads}/`v'"
			
		
	}
	
	

	

* APPEND VERSIONS 
	local versions: dir "$raw" dir "*", respectcase // local with all the folders in raw
	
	local loop = 1
	foreach v in `versions' {
*		di  "`v'"
	
		local modules: dir "$raw/`v'" file "*.dta", respectcase //local with files of each folder
		foreach m in `modules' {
*			di "`m'"
		
			if `loop' == 1 {
		
				use "$raw/`v'/`m'", clear
				
				
				if `c(N)'>0 {
					gen version = "`v'"
					qui save "$raw/`m'", replace
				}
				
			}
			
			else {
				
				use "$raw/`v'/`m'", clear
				
				if `c(N)'>0 {
					gen version = "`v'"
					cap append using "$raw/`m'"
					qui save "$raw/`m'", replace
					
				}	
		
			}
		
		*end of modules________________________________________________________
		}
		
		
		

*end of versions__________________________________________________________________________		
	local loop=`loop' + 1
	}
	
	
	cd "$raw"
	
*2) CREATE INDICATORS FOR FIELD AND DATA MANAGEMENT 
**______________________________________________________________________________

	
*duration
	use "$diagnostics", clear
	
	
	
	
	rename interview__duration Duration
	
	
	replace Duration=substr(Duration,4,11)  //keep only hours and minutes
	split Duration, destring p(:)  //split and destring
	gen Duration4= Duration1*60 + Duration2 //convert Duration to total minutes
	drop Duration Duration1 Duration2 Duration3
	rename Duration4 Duration
	label var Duration "Duration of interview in minutes"
	
	rename interview__status lastAction
	label var lastAction "Last Action in Server"
	
	rename responsible Interviewer
	
	
	
	
	keep Duration lastAction Interviewer interview__key   //keep only relevant variables
	
	
	
	tempfile duration
	save `duration', replace 
	

*Date and last action 
	
	use "$actions", clear 
	rename date Date
	rename time Time
	
	sort interview__id Date Time	
	bys interview__id: keep if _n==_N
	label var Date "Date of interview's last action"
	label var Time "Time of interview's last action"
	
	
	*Clock
	replace Time=substr(Time,1,5)
	
	keep interview__key Date Time 
	
	merge 1:1 interview__key using `duration', assert(3) nogen   //merge with diagnostics info
	
	


	tempfile actions
	save `actions', replace 
	


	
*create indicators by instrument 
	foreach i in $questionnaires {
		
		use `actions', clear  // use actions data 
		*di "`i'"
		qui merge 1:1 interview__key using "`i'", assert(1 3) keep(3) nogen //merge with each instrument
		
		** Approved 
	
		*gen Approved = 0
		*label var Approved "Approved interview"
	
		** drop (interviews to be dropped)

		gen drop = 0 
		label var drop  "Interview to be dropped"
		
		** link to questionnaire

		gen link = "$website" + interview__id
		
		order school Duration lastAction Interviewer Date Time link  drop
		
		
		if "`i'" == "$Qgirls" {   // correct outcome of the girl questionnaire to manage versions
			
			label copy v1_out outcome 
			rename v1_out outcome 
			label val outcome outcome 
			
			recode outcome (96=4) (97=5)
	
			label define outcome 4 "Refusal first visit", add
			label define outcome 5 "Other reasons first visit", add
			label define outcome 6 "Partially completed visit 2", add
			label define outcome 7 "Refusal visit 2", add
			label define outcome 8 "Not available after 3 attempts", add
			label define outcome 9 "No contact number available", add
			label define outcome 10 "Other reason visit 2", add
			label define outcome 11 "Transition complelted", add
	
			recode v2_out (2=6) (96=7) (4=8) (5=9) (97=10) (1=11)
	
			replace outcome = v2_out if v2_out!=.
			
			*gen girl_name =""
			qui levelsof girl, local(girls) 				    
		
			*girl name 
			foreach g in `girls' {  							
			
				local name: label girl `g'
				*di "`name'"
				qui replace girl_name = "`name'" if girl ==`g'
			}
			
			*replace girl_name = girl_new if girl==.
		 
		 *Id for new girls
		 
		 merge m:1 school using "$lookup/schools_LU", keep(1 3) keepusing(size topup) nogen
	
		sort school girl girl_name
		label val girl
		format girl %12.0g
		sort school girl girl_name
		
		bys school: replace girl = school *100 + size + (_N-_n +1) if panel ==0 // replace girl id for new girls
		bys school: replace girl = 9999*100 + _n if school ==.a & panel ==0 // for girls missing school id
		 
		}
		
		if "`i'" == "$Qco" {
			rename v1_out outcome
			
		}
		
		if "`i'" == "$Qseg" {
		
		 merge m:1 school using "$lookup/schools_LU", keep(1 3) keepusing(size topup) nogen

		sort school girl girl_name
		label val girl
		format girl %12.0g
		sort school girl girl_name
		
		bys school: replace girl = school *100 + size + (_N-_n +1) if panel ==0 // replace girl id for new girls
		bys school: replace girl = 9999*100 + _n if school ==.a & panel ==0 // for girls missing school id
	
		}
		
		di as text "making data for `i'" 
		
		*Save raw data 
		qui save "`i'", replace 
	
	
	}
	
	
	
	use "$Qgirls", clear
	
	
			
	ex
	
	*label val girl
	*format girl %12.0g
		
		*replace girl_name = girl_new if girl==.
		
		*sort school girl 
		*bys school: gen n = school *100 +_n
		*labmask n, values(girl_name)
		*drop
		*ex
	
	
	
	
	
	
	
