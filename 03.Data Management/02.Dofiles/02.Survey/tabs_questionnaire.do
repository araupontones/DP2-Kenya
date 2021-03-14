clear all
set more off







		if c(username) == "Aarau" {
		
			global dofiles "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
		
		if c(username) == "Kkeck" {
		
			global dofiles "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}

	
	do "$dofiles/globals.do"

		local reference_data "sampleDP2"
		
		use "$reference/`reference_data'", clear
		
		
		
		

		rename girl_name respondent
		gen rowcode = girl
		
		*rename girl hh_id //to make it consistent with the code below 
		
		
		
		*br city Bairo ea_id hh_id sampled
		
		
		

				
*1 Tab files for name of respondent 
*_________________________________________________________________________________
*clean

	replace respondent= subinstr(respondent,"Á","A",.) 
	replace respondent= subinstr(respondent,"É","E",.)
	replace respondent= subinstr(respondent,"Í","I",.)
	replace respondent= subinstr(respondent,"Ó","O",.)
	replace respondent= subinstr(respondent,"Ú","U",.)
	replace respondent= subinstr(respondent,".","",.)	
	replace respondent=itrim(respondent)


		
*a) convert names into ASCII codes
	
	*maximum length of name 
	qui gen lenght=length(respondent)	
	qui sum lenght
	
	
	
	*convert to numeric
	gen namenumber=""
	forvalues l=1(1)`r(max)' {   //for values up to the maximum length
		
		qui gen v`l' = substr(respondent,`l', 1) //separate each character from the name
		
		gen v`l'_`l'=0						//gen numeric value = 0 
		local code=65						//start the ascii code in 65. 65 is A
		foreach char in `c(ALPHA)' {
			qui replace v`l'_`l' = `code' if v`l'=="`char'" // replace the numeric value to the ascii code
			
			local code=`code'+1
			
		}
		qui tostring v`l'_`l' , replace				//string the ascii code
		qui replace v`l'_`l'=" " if v`l'_`l'=="0"
		 
		qui replace namenumber=namenumber+ v`l'_`l'  //bring all the ascii codes together
		
		
		drop v`l' v`l'_`l'
			
	}
	
	
	
	replace namenumber=trim(namenumber)
	*replace space by 32 according to the ascii system	
	replace namenumber=subinstr(namenumber," ", "32",.)
	replace lenght=length(namenumber)
	
	qui sum lenght
	qui local max=`r(max)'
	
	
	local col= ceil(`max'/8)
	
	* split string so survey solutions can read each column 
	local f = 1
	forvalues n=1(1)`col' {		
		gen namenumber`n'=substr(namenumber,`f',8)		
		local f =`f' +8
	}
	
	
	drop namenumber
	
	
*b) export name tab
	
	order rowcode namenumber*	
	br rowcode namenumber*	
	
	
	
	export delimited rowcode-namenumber`col' using "$CAPI/names.csv", replace delimiter(tab) nolabel
	
	
* end of 1-------------------------------------------------------------------------------
	

*2 CASCADING COMO BOX FOR SCHOOLS
*________________________________________________________________________________
	
	*a) keep list of schools by county
	preserve
	keep county school
	bys county school: keep if _n==1
	levelsof school, local(schools)
	local schoolab: value label school
	
	gen Name=""
	foreach s in `schools' {
		local SchoolName: label `schoolab' `s'
		replace Name="`SchoolName'" if school==`s'
		di "`SchoolName'"
	}
		
	
	order school Name county
	export delimited using "$CAPI/Schools.csv", replace delimiter(tab) nolabel novar
	*export delimited using "$CAPI/Schools.tab", replace delimiter(tab) nolabel novar

	restore
	
	
	*b) CASCADING COMBO OF girls
	
	
	preserve
	keep school girl
	bys school girl: keep if _n==1
	levelsof girl, local(girls)
	local girlslab: value label girl
	
	gen Name=""
	foreach g in `girls' {
		local girlname: label `girlslab' `g'
		replace Name="`girlname'" if girl==`g'
		di "`girlname'"
	}
		
	
	order girl Name school
	export delimited using "$CAPI/Girls.csv", replace delimiter(tab) nolabel novar
	restore
	
	/*c) assign lesson
	preserve
	keep county school treatment
	bys county school: keep if _n==1
	levelsof school, local(schools)
	local schoolab: value label school
	
	gen Name=""
	foreach s in `schools' {
		local SchoolName: label `schoolab' `s'
		replace Name="`SchoolName'" if school==`s'
		di "`SchoolName'"
	}
		
	gen subj = .
	replace subj = 1 if inlist(school,1993,1996,1995,1108,2996,2110,2994,2995,2991,2113,3996,3995,3126,3127,3135,3120,4993,4993,4991,4136,4995 ///
	,4132,5145,5992,5147,5148,6994,6993,7995,7992,7991,7994,7154,7160,7159,8992,8170,8993,8995,9175,9176,10993,10178,10994,10183,10185,10180, ///
	11991,11998,11190,11189,12198,12992,12199,13993,13991,14991,14993,15995,15218,15992,15212,15210,15993)
	replace subj = 2 if subj==.
	
	gen name = "Maths" if subj==1
	replace name = "English" if subj==2
	
	rename school rowcode
	drop county treatment Name name
	
	order rowcode subj
	export delimited using "$CAPI/Lessons.csv", replace delimiter(tab) nolabel 

	restore

*/
	

* end of 2----------------------------------------------------------------------
	

* end of 3----------------------------------------------------------------------

*	4) LOOK UP RESPONDENT 
	
	
	
	order rowcode age treatment 
	export delimited rowcode - treatment using "$CAPI/checks.csv", replace delimiter(tab) nolabel
	
	
* 	5) LOOK UP SCHOOLS 

	preserve
	replace rowcode = school 
	bys rowcode: keep if _n==1
	order rowcode size treatment
	
	export delimited rowcode - treatment using "$CAPI/Schoolchecks.csv", replace delimiter(tab) nolabel
	
	restore 
	
*6) LESSON

	preserve
	
	replace rowcode = school
	bys rowcode: keep if _n==1
	encode(subject), gen(subject2)
	recode subject2 (2=1) (1=2)
	
	order rowcode subject2
	export delimited rowcode - subject2 using "$CAPI/Lessons.csv", replace delimiter(tab) nolabel 
	
	restore

	
	order county school treatment non_formal size topup
	bys school: keep if _n==1
	sort county county2 school
	export excel county - topup using "$CAPI/tracking.xlsx", replace firstr(varl)
	
*5) team tab for assignments 

	*import excel "$data/Team.xlsx", sheet("Sheet1") firstrow clear
	
	*gen _quantity =-1
	
	*export delimited using "$CAPI_pilot/assignments.csv", replace delimiter(tab) nolabel
	
	*export delimited using "$CAPI_pilot/assignments.tab", replace delimiter(tab) nolabel
	

	
	

	
	
