clear all
set more off




* * * THIS DOFILE CONTAINS ALL THE GLOBALS USED FOR DP-2 midline
*_______________________________________________________________________________________

* 							INSTRUCTIONS									*



* Change all the globals accordingly

* myfolder1: root path of DP-2 survey folder
* 


* r1Clean: folder where the clean data from ROUND 1 is stored
* r1Indicators: folder where indicarors from round 1 is stored 

* referencelisting: folder where the reference data from listing is stored
* reference: Folder where the reference data is stored
* templates: Folder where tracking sheets are stored

* data : folder where data is exported from dofiles
* sample: folder with sample frame and sample

	
	*global myfolder "C:\Users/aarau/Dropbox (OPML)/98. MUVA/A 0583 MUVA SURVEY/09. Analysis/01. Data/02. Clean"
	
	
	if c(username) == "Aarau" {
		
		global myfolder "C:\Users\aarau\Dropbox (OPML)\A4235 Dicovery Project-2 (DP-2) Evaluation\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya"
		*global myfolder2 ""
		
	}
	
	
	if c(username) == "Kkeck" {
		
		global myfolder "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya"
		*global myfolder2 ""
		
	}

	
	
global website = "https://nigdp2.mysurvey.solutions/Interview/Review/"	
	
//global desktop (main folder of the survey)
	
	global C = "C:/DP2Kenya"
	
		global raw "$C/1.raw"
		global clean "$C/2.clean"
		global dashboard "$C/3.dashboard"
	
	
//QUESITONNAIRES AND SERVER
	
	
	global diagnostics "interview__diagnostics"
	global actions  "interview__actions"
	
	global Qgirls "girlsurvey"
	global Qco "CONM" // classroom observation
	global Qct "cohort_tracking" // cohort tracking 
	global Qhc "hc" // head count
	global Qss "SSKM" //school survey
	global Qts "teachsamp" // teacher sampling
	global Qseg "seg" //segra segma
	
	global questionnaires $Qgirls $Qco $Qct $Qhc $Qss $Qts $Qseg
	
	


	
	
	*DATA
	global data "$myfolder/03.Data Management\01.Data"	
		global sample "$data/01.Sample"
	
	
		global reference "$data/02.Reference"
			global lookup  "$reference/01.Lookup"   // folder with checks for the dashboard
	
		global field "$data/03.Field"
			global downloads "$field/00.Downloads"
	
	
	

	
	
	*CAPI
	global CAPI "$myfolder/01.CAPI"
		global CAPI_pilot "$CAPI/pilot"
	
	*TRACKING SHEETS 
	
	global templates "$myfolder/02.Tracking sheets"

	
	

// to remove
	
	if c(os)=="Windows" {
			global remove "capture !rmdir"
			global s " /s /q"
		}
		
		if c(os)=="MacOSX" {
			global remove "shell rm -rf"
			global s 
		}

		
	
//sample size

	global samplesize= 127
	
	
	
	
