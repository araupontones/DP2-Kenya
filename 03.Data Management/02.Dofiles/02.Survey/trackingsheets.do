
clear all
set more off


********************************************************************************
/*
** Description:

	Creator: Andres Arau Jan 2018
	Input: Reference data DP2
	Output: Tracking sheets at the school levels with confirmed girls infomation
*/

*********	
local sample ON // change this when resample is needed  (swith to OFF When you dont want to sample again and ON viceversa)

** When ON: the dofile will resample and new tracking sheets will be created
** Ehen OFF: The dofile wont resample and the tracking sheets will remain
**********

********************************************************************************


***********				SET PATH & FILE NAMES			************************
********************************************************************************

		if c(username) == "Aarau" {
		
			global dofiles "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/01.Pilot"
				
		}
	
	

	
	local reference_data "sampleDP2"

********************************************************************************

*Use refernce data (clean it) in reference dofile
**Export template to folders by county

*Structure data to be exported



*cd "$clean"




	use "$reference/`reference_data'", clear
	

*clean

	gen gID = girl
	gen sID = school
	
	label val gID
	label val sID
	
	sort school girl
	
	
//1. ORDER AS THE TRACKING SHEETS


*create subject 	

*******************************************************************************
* DATA FOR MAIL MERGE 
********************************************************************************
	preserve
	
	order sID county school_name gID girl_name caregiver address contact contact2 age language treatment_name subject
	rename girl_name girl_name_   // including "_" to prepare for reshaping
	rename girl_name2 girl_name2_
	rename name1 name_
	rename name2 name2_
	rename contact contact_
	rename contact2 contact2_
	rename relationship1 rel_
	*rename relationship2 rel2_
	rename language lang
	
	keep  county girl_name_ girl_name2_ caregiver gID sID county_name school_name treatment_name size topup subject  // keep variables that we'll use in mail merge
	sort sID
	bys sID: gen seq=_n // this is j in reshape
	reshape wide girl_name_ girl_name2_ caregiver gID, i(sID) j(seq)	
	export excel using "$templates/mailmerge.xlsx", replace firstrow(varl) sheet("MailMerge") 
	
	restore
	
	preserve
	
	order sID county school_name gID girl_name caregiver address contact contact2 age language treatment_name topup	contact contact2 name1 name2 relationship1 relationship2
	rename girl_name girl_name_   // including "_" to prepare for reshaping
	rename girl_name2 girl_name2_
	rename name1 name_
	rename name2 name2_
	rename contact contact_
	rename contact2 contact2_
	rename relationship1 rel_
	*rename relationship2 rel2_
	rename language lang
	
	keep  county girl_name_ caregiver gID sID county_name school_name treatment_name contact_ contact2_ name_ name2_ rel_ lang   // keep variables that we'll use in mail merge
	sort sID
	bys sID: gen seq=_n // this is j in reshape
	reshape wide girl_name_ caregiver gID contact_ contact2_ name_ name2_ rel_ lang, i(sID) j(seq)	
	export excel using "$templates/mailmerge_contacts.xlsx", replace firstrow(varl) sheet("MailMerge") 
	
	
	
	

ex


*****CREATE TRACKING SHEETS_____________________________________________________

order county school_name sID gID girl_name caregiver address contact contact2 age language treatment_name size
di "$templates"
		

	
		
		local valueLoc: value label county		//label value of county
		levelsof county, local(countys) 				    // all values of county
		*set trace on
		foreach l in `countys'{  							// foreach county
			local county: label `valueLoc' `l' 		//name of the county
			di "`county' *** `l'"
		
			capture !rmdir "$templates/0`l'. `county'"  /s /q	// create a folder and name it as the county
			capture mkdir "$templates/0`l'. `county'"
			
			*di "$templates/0`l'. `county'"
		
		
			local valueSchool: value label school 	              //label value of bairos
			qui levelsof school if county==`l', local(schools)    //local with bairos levels
		
			di `schools'
			local f=0 								// local that starts a sequence for naming folder (first folder will be 01)
			foreach s in `schools' {                 //foreach biaro in city
				di `s'
				local school: label `valueSchool' `s' //name of bairo
				di "`0`f' `school****'" 
				local f=`f'+1	// add 1 every time so second folder is 02, third 03, etc
				
				*capture !rmdir "$templates/0`l'. `county'/0`f'. `school'"  /s /q	// create a folder and for each district in state
				*capture mkdir "$templates/0`l'. `county'/0`f'. `school'"
				
				qui copy "$templates/masterTracking.xlsx" "$templates\0`l'. `county'/0`f'. `school'.xlsx", replace 		//copy the mastertracking file in the folder of the state and name it as the psu
				qui export excel county-size if county==`l' & school==`s' using "$templates\0`l'. `county'/0`f'. `school'.xlsx", sheetreplace firstrow(varl) sheet(Stata) 	
			
			
			
			}
		}
			
		
		
			  
		
ex

	


*******************************************************************************
* MAP
********************************************************************************

	
		keep if selected==1
		order ea_id Bairo hh_id Latitude Longitude quintile EligeResp sex age city
		recode Latitude Longitude (.a=.)
		rename EligeResp respondent
	
		qui export excel ea_id - city using "$templates/mymaps.xlsx", sheet("coordinates") first(var) replace
		save "$reference/sample_pretest", replace 
	
	
	} //closes sampling 


	

	
	