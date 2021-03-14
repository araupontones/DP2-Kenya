set more off
clear all

// cleans incosistencies from raw data and saves a clean version

	if c(username) == "Aarau" {
		
			global dofiles "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"			
		}	
	
		if c(username) == "Kkeck" {
		
			global dofiles "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\03.Data Management\02.Dofiles/02.Survey"
				
		}
	
	do "$dofiles/globals.do"
	do "$dofiles/makedata.do"
		
*******************************************************************************	
*** make directories in clean folder (DONT TOUCH)*******************************
********************************************************************************

	$remove "$C/2.clean" $s
	$remove "$C/3.dashboard" $s
		
	cap mkdir "$C/2.clean"	
	cap mkdir "$C/3.dashboard"	
		
	local interviews: dir "$C/1.raw/" file "*dta", respectcase	
	
	foreach i in `interviews' {
		*di "`i'"
		
		if  regexm("`i'","$QN") == 1 {
		
			copy "$C/1.raw/`i'" "$C/2.clean/`i'"
			
		}
					
					
		}
		
	foreach q in $questionnaires {
	
	$remove "$C/2.clean/`q'" $s	
	cap mkdir "$C/2.clean/`q'"	
	}
	
	
							

cd "$clean"

********************************************************************************






* * * * * GIRLS:
use "$Qgirls", replace
*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------

//KK: adding girl IDs for first day when drop down didn't work
replace girl = 10114 if interview__id=="7777a9e868b544cd84840adc52735822"
replace girl = 10511 if interview__id=="1d01758a8c6a4861bb6682fc6a933efe"
replace girl = 40413 if interview__id=="a0a445fd790844dc86defd3e7bfe4de6"
replace girl = 40915 if interview__id=="410fb743ecce49b2878ffd609190a1e0"
replace girl = 46311 if interview__id=="97844f116039491ba1bb96f516af50fb"
replace school = 404 if interview__id=="950fa85b35414472851a298a00aa6b0c"
replace girl = 40401 if interview__id=="950fa85b35414472851a298a00aa6b0c"
replace girl = 46202 if interview__id=="7f50280d4df741ff97d1ba322c34e114"

//KK: adding girl IDs for interviewer who selected 'No' for panel question instead of 'yes'
replace girl = 45915 if interview__id=="4a53a7477cc548379a46d7df69caab08"
replace girl = 45916 if interview__id=="6275051947314b18b3eb911f2c34a882"
replace girl = 45914 if interview__id=="3043b2f8688f4651b4cc8048f4f1c8c4"
replace girl = 45906 if interview__id=="6261f02efc28440ba598e43f48b1dc09"
replace panel = 1 if inlist(interview__id,"4a53a7477cc548379a46d7df69caab08","6275051947314b18b3eb911f2c34a882", ///
		"3043b2f8688f4651b4cc8048f4f1c8c4","6261f02efc28440ba598e43f48b1dc09")




*OUTCOMES
*-------------------------------------------------------------------------------

replace outcome = 1 if interview__id=="3f7711318d164b33a3f02af1c9bfebf0"
replace outcome = 3 if interview__id=="987f86a183ba4f3ba6c976a70753c423" //girl was absent but 'completed' was selected
replace outcome = 3 if interview__id=="30ab709361f04a7991ef53ddb55d19f1" //girl was absent but 'completed' was selected
replace outcome = 3 if interview__id=="c98ea80c43a5416eb13cb7b63ac4dcac" //girl was absent but 'completed' was selected



*DROPS
*-------------------------------------------------------------------------------

replace drop = 1 if interview__id=="ee61c1bac74747c095beed45a4ac4b05" //two people entered interview for girl being absent
replace drop = 1 if interview__id=="9a04c3a666e94ef98efc25ebfc5a58ba" //wrong girl picked as absent
replace drop = 1 if interview__id=="46a47d3bb9ba41429a089b56de1e0df7" //two transition interviews entered for same girl



********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qgirls/$Qgirls", replace
*-------------------------------------------------------------------------------
********************************************************************************



* * * * * SEGRA SEGMA:
use "$Qseg", replace
*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------

//KK: one teacher has not been filling in girl IDs for 3 schools :(
replace girl = 40415 if interview__id=="450a6197accb463fb2cbbbe62a7c407b"
replace girl = 40401 if interview__id=="d700123259634961abf0a790a9331b7d"
replace girl = 40416 if interview__id=="b8b06e3708d9411ea35503f82d8b3196"
replace girl = 40421 if interview__id=="3909ea531f4f4f8091d8916801886233"
replace girl = 40419 if interview__id=="93f21137c3744d359de1c0effe3604be"
replace girl = 40402 if interview__id=="a56cb5f17674440bb7f6959e9b5c139c"
replace girl = 40418 if interview__id=="5aa871691e6d4c559b29ae4d28f4101a"
replace girl = 40405 if interview__id=="f20ba4a7a6684a599ed86c38a9d31510"
replace girl = 40417 if interview__id=="c13b148aa5c24fcf943955fc61283328"
replace girl = 40408 if interview__id=="a4718978e9b44b9491357d425f9aab3a"
replace girl = 40411 if interview__id=="7a9c810cb06b4674a25a504278fdf4b1"
replace girl = 40403 if interview__id=="ad58741381114ff68946b5282ad017aa"
replace girl = 40407 if interview__id=="fccee6de0c934741a319e0d1c6507176"
replace girl = 40414 if interview__id=="4f018a33529c4618ad34193078f24f77"
replace girl = 40404 if interview__id=="d007cc07914042729288e5c07d519d25"
replace girl = 40409 if interview__id=="7152887da105463888823ecf0c1244ac"
replace girl = 40420 if interview__id=="2f835c54ca7143e18e233d9bbcfc7b16"
replace girl = 40413 if interview__id=="a535cbf06d594bebae4e9ee8841fe377"
replace girl = 40410 if interview__id=="46cded13178142abab3ca959286d2bc5"
replace girl = 40406 if interview__id=="354b634f9e08409b80768f238e3f7fb7"

replace girl = 41512 if interview__id=="702c5999093b4ec38a4cd17fbce9fed4"
replace girl = 41506 if interview__id=="5818b3ae62234c12b884533376a6a0f6"
replace girl = 41509 if interview__id=="a5da558b2fb04c6fa115d188e4afe97d"
replace girl = 41516 if interview__id=="15d8190c38aa450abc056445f02b5979"
replace girl = 41517 if interview__id=="3ad0e26fdd4f4b98b13cad3f31f439f0"
replace girl = 41515 if interview__id=="4ca39de6d01749febc7c808ac92b1b56"
replace girl = 41514 if interview__id=="14687bc9f4bc4903861ac1bf50d4b15a"
replace girl = 41502 if interview__id=="a4b9041aae10422ea489acd68a75ea4a"
replace girl = 41520 if interview__id=="33095443fd944cb19df8d739f24a0676"
replace girl = 41503 if interview__id=="87faccd9007c435c84a89b2f94cfeb42"
replace girl = 41504 if interview__id=="2559b2b62de44e43a783041543676a16"
replace girl = 41519 if interview__id=="40ed8d276fdb422eb0068b73c467a1a6"
replace girl = 41508 if interview__id=="49a86c5c207d4f1ba7a0c133286532dd"

replace girl = 46307 if interview__id=="a23b979421194cad92df870922e4b69d"
replace girl = 46308 if interview__id=="13bbb16d5e4b4f8fad03383637e8af3d"
replace girl = 46304 if interview__id=="ba9ee79d3d554a03a61344a07c683f03"
replace girl = 46309 if interview__id=="278e3913f5764940b05e737131598870"
replace girl = 46302 if interview__id=="17ed4d835a6a4d67aff63d98c9dc191b"
replace girl = 46320 if interview__id=="76ee3df8d85e4f98adccc84bec34dfce"
replace girl = 46316 if interview__id=="a493fdd9dafc49efa4b7aaa47be70586"
replace girl = 46305 if interview__id=="ecf30f5357dd4182a32d33f29372fd07"
replace girl = 46312 if interview__id=="31a050c5933c469aa4518eb4166227d1"
replace girl = 46301 if interview__id=="2829b857b86c409c91bb7befb7297aed"
replace girl = 46303 if interview__id=="7f55147a2fef44c89c89c9ea0d49d5a2"
replace girl = 46318 if interview__id=="07a9ef7ffa0e40eeb51916bcb9222696"
replace girl = 46319 if interview__id=="afafca8081e049dba003927e47414e3b"
replace girl = 46321 if interview__id=="ee1bd9d2bc424df4b6e7cde733112908"
replace girl = 46303 if interview__id=="9aa6aec6409e4eeaa9c33fd4024c243d"
replace girl = 46314 if interview__id=="3b03bc86b31646c2ad44b0e6ea305cc8"
replace girl = 46315 if interview__id=="f994b54d05ae4f7d9fcab3e9f3748e5e"
replace girl = 46311 if interview__id=="67fa0c9bd35f40fca34ccea06e67d426"


//KK: wrong ID entered
replace girl = 46502 if interview__id=="a9b6bdb335d44cdab8b6343c0ea03886"
replace girl = 10110 if interview__id=="4fa3ad99209f4d92a3e3ee5b571bb26a"

*OUTCOMES
*-------------------------------------------------------------------------------






*DROPS
*-------------------------------------------------------------------------------

replace drop = 1 if interview__id=="a644001cf79f4d01a2a36d68d282c440"

********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qseg/$Qseg", replace
*-------------------------------------------------------------------------------
********************************************************************************






* * * * * CLASSROOM OBSERVATION:

use "$Qco", replace
*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------






*OUTCOMES
*-------------------------------------------------------------------------------

replace outcome = "outcome" if interview__id=="5ecde4911f804e6782ff9d5319c8013b"


//Hey! this is a note from Andres, to change the outcome you need to use its value lables
// look below!!

*Example if you want to replace to complete: replace outcome = 0 if interview__id=="5ecde4911f804e6782ff9d5319c8013b"
*Also remember that each quesitonnaire has a different value label system. To look at the value lables do:
* label list 

/*
these are the codes of this outcome

outcome:
           0 Completed
           4 No interview - no common language with respondent
           5 No interview - other reason
           8 Refusal - direct refusal
           9 Refusal - other reason
          10 Partially completed (revisit)

*/

*DROPS (replace drop = 1 if school==X)
*-------------------------------------------------------------------------------

replace drop = 1 if interview__id=="64ab7247f4434984a51e61b977f97895" //empty classroom observation



********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qco/$Qco", replace

*drop interviews from subfiles 

local files "rtrTraining.dta"

	foreach f in `files' {
	
		*di "`f'"
		cap qui use "`f'", clear
		
		if _rc == 601 {
			local nothing nothing
		}
		else {
			qui merge m:1 interview__key using "$Qco/$Qco", assert (2 3) keep(3) nogen
			qui save "$Qco/`f'", replace
		}
	}
	
	
*------------------------------------------------------------------------------







* * * * * COHORT TRACKING:

use "$Qct", replace


*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------






*OUTCOMES
*-------------------------------------------------------------------------------







*DROPS
*-------------------------------------------------------------------------------

//KK: deleting trial interview from me
replace drop = 1 if interview__id=="61f10a78a5874e9ebe6a0c8179b9e058"




********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qct/$Qct", replace

local files "attendance_topup.dta status.dta"

	foreach f in `files' {
	
		*di "`f'"
		cap qui use "`f'", clear
		
		if _rc == 601 {
			local nothing nothing
		}
		else {
			qui merge m:1 interview__key using "$Qct/$Qct", keep(3) nogen
			qui save "$Qct/`f'", replace
		}
	}
	
	


*------------------------------------------------------------------------------






* * * * * HEAD COUNT:

use "$Qhc", replace


*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------






*OUTCOMES
*-------------------------------------------------------------------------------







*DROPS
*-------------------------------------------------------------------------------





********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qhc/$Qhc", replace

local files "attendance.dta headcount.dta"

	foreach f in `files' {
	
		di "`f'"
		qui use "`f'", clear
		qui merge m:1 interview__key using "$Qhc/$Qhc", assert(2 3) keep(3) nogen
		qui save "$Qhc/`f'", replace
		
	}
	
	
	


*------------------------------------------------------------------------------






* * * * * SCHOOL SURVEY:

use "$Qss", replace


*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------

replace school = 105 if interview__id=="399c564615224d0da1a045d2146cc232"




*OUTCOMES
*-------------------------------------------------------------------------------







*DROPS
*-------------------------------------------------------------------------------

//KK: dropping trial interviews from me
replace drop = 1 if interview__id=="18ee74cc2b4d491d838deab53254f207"
replace drop = 1 if interview__id=="aae20965ff604346af135b227f7d1a99"
replace drop = 1 if interview__id=="5c0488340aab4d2a8e341fc14e81b6ec"



********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qss/$Qss", replace

local files "primary.dta"

	foreach f in `files' {
	
		*di "`f'"
		qui use "`f'", clear
		qui merge m:1 interview__key using "$Qss/$Qss", assert(1 3) keep(3) nogen
		save "$Qss/`f'", replace
		
	}
	
	


*------------------------------------------------------------------------------



* * * * * TEACHER SAMPLING:

use "$Qts", replace


*_______________________________________________________________________________

*IDS
*-------------------------------------------------------------------------------






*OUTCOMES
*-------------------------------------------------------------------------------







*DROPS
*-------------------------------------------------------------------------------





********************************************************************************
*------------------------------------------------------------------------------
drop if drop == 1



save "$Qts/$Qts", replace

local files "teachers.dta"

	foreach f in `files' {
	
		di "`f'"
		qui use "`f'", clear
		qui merge m:1 interview__key using "$Qts/$Qts", assert(2 3) keep(3) nogen
		save "$Qts/`f'", replace
		
	}
	
	


*------------------------------------------------------------------------------






* * * * APPROVE At THE SCHOOL LEVEL
**__________________________________________________________

	use "$lookup/schools_LU", clear
	
	
	
#delimit ;
	local approved ///
		404		///Bensophil
		511		///Got Ade
		433		///Mahiga
		522		///Makror
		442		///Ngong Forest
		465		///Wamo non-formal
		428		///Kiwanja
   
	;
	#delimit cr	

	
	foreach a in `approved' {
	
		replace Approved = 1 if school == `a'
	}
	
	gen approve_chk = Approved==1
	
save "$dashboard/schools" , replace


	
*_______________________________________________________________________________
*ERASE REDUNDANT FILES FROM THE CLEAN FOLDER

	local toerase: dir "$clean" file "*dta", respectcase
	
	foreach t in `toerase' {
	
		di "`t'"
		erase "`t'"
	
	}

*_______________________________________________________________________________

	do "$dofiles/dashboard.do"


