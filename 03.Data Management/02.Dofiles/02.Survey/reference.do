clear all
set more off






		if c(username) == "Aarau" {
		
			global dofiles "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
		
		if c(username) == "Kkeck" {
		
			global dofiles "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}

	
	do "$dofiles/globals.do"

		
		local sample_data "GirlTrack3"
		local reference_data "sampleDP2"
		
		import delimited using "$sample/`sample_data'.csv", clear
		
		
		
		
*1 CLean sample to be used as reference data for the survey
*_________________________________________________________________________________
*rename variables

	rename girl girl_name

*strings in capitals

	replace school = upper(school)
	
	replace girl_name= subinstr(girl_name,"'","",.)
	replace girl_name= subinstr(girl_name,`"""',"",.)
	replace girl_name= upper(girl_name)
	replace girl_name =  strtrim(girl_name)
	
	replace girl_name2 = upper(girl_name2)
	
	replace caregiver = upper(caregiver)
	replace caregiver= subinstr(caregiver,"'","",.)
	replace caregiver= strtrim(caregiver)
	
	replace school= subinstr(school,"/","",.)
	
	
	replace address = upper(address)
	
	replace county = upper(county)
	
	

*county

	sort county
	rename county c		
	encode c, gen(county)	
	rename c county_name	
	
	

*school_id 
	rename school_id school_id_bl
	label var school_id_bl "School ID at baseline"


	tempfile sample
	save `sample', replace 
	
	keep school county 

	bys county school: gen school_id =_n
	keep if school_id ==1
	sort county school	
	bys county: replace school_id = county*100+_n
	labmask school_id, values(school)	
	
	merge 1:m county school using `sample', nogen  // merge with sample 
	
	
	rename school school_name 
	rename school_id school 
	
	
	
*girl_id 
	rename girl_id girl_id_bl
	label var girl_id_bl "Girl ID at baseline"

	duplicates tag girl_name, gen(dup)	
	bys girl_name: replace girl_name = girl_name + " "+ string(_n) if dup>0 //ss doesnt accept duplicate names in single select questions
	drop dup
	
	
	
	sort school girl_id_bl
	
	by school: gen girl = string(_n) // id at baseline
	replace girl = "0"+girl if length(girl)==1
	replace girl = string(school) + girl 
	destring girl, replace 
	labmask girl,values(girl_name)
	label var girl "Girl ID midline"
	

	
	
		
*treatment

	rename treatment t
	gen treatment_name = "Treatment" if t ==1
	replace treatment_name = "Control" if t==0
	
	labmask t, values(treatment_name)
	
	

	rename t treatment 

	

*address

	
	rename contact1 contact

	*format contact3 %12.0g
	*rename contact3 contact2
	
*School size
	bys school: gen size=_N
	

	*subject
	gen s = "Maths" if subject ==1 
	replace s = "English" if subject ==2
	br s subject
	drop subject
	rename s subject


	save "$reference/`reference_data'.dta", replace

order size county school school_name girl girl_name girl_name2 address contact contact2 language age treatment_name
sort school girl
br school girl size 
br

********************************************************************************
		**reference for dashboard **
********************************************************************************

*1 Look up table for schools

	preserve
 
 //variables to check completion of tools
	
	
	gen Approved = 0 
	

	keep county Approved school size topup treatment
	
	bys school: keep if _n==1
	
	
		
	
	save "$lookup/schools_LU", replace 
	
	restore
	
*2 Look up table for girls
	
	keep county school girl
	
	save "$lookup/girls_LU", replace
	
 
 
 

ex
	