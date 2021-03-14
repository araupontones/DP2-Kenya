

use "C:\Users\kkeck\Dropbox (OPML)\A2435 DP2\03 Workstreams\01 Quantitative Workstream\02 Midline\11 Survey\Kenya\00. Pilot\girlsurvey", clear
drop if interview_type==2

//Renaming variables for tasks 1 - 3 to match across all datasets, but keeping Task 4 and Task 5 separate for Kenya vs Ghana/Nigeria 
//because the comprehensions are different lengths and questions are different
	foreach var of varlist egrag_a1_r1__99 - egrag_b3_total {
		local name = reverse(subinstr(reverse("`var'"),"g","",1))
		rename `var' `name'
	}

	foreach var of varlist egrak_c4_r1__99 - egrak_c5_q5ans {
		local name = subinstr("`var'","k","",1)
		rename `var' `name'
		}


********************************
*** Sub-task 1: Letter Sound (Nigeria / Ghana) / Letter name (Kenya)
********************************

//1. Replacing all correct values to 1 and incorrect values to 0 (for Ghana and Kenya only, already done for Nigeria)
forvalues x=1 3 to 9 {

foreach var of varlist egra_a1_r`x'__1- egra_a1_r`x'__20 {

	recode `var' (1=0) (0=1) 
	label val `var' answer
	replace `var'=. if egra_a1_r1__99==1
	replace `var'=. if egra_a1_r1_out==99

}
}


//2. Replacing the first 10 letters to incorrect if early stop was selected
foreach var of varlist egra_a1_r1__1- egra_a1_r1__10 {
	replace `var'=0 if egra_a1_r1__98==1.00 
}

//3. Replacing the remaining 90 letters with missing if early stop was selected
foreach var of varlist egra_a1_r1__11- egra_a1_r1__20 {
	replace `var'=. if egra_a1_r1__98==1.00 
}

forvalues x=3 5 to 9 {
	foreach var of varlist egra_a1_r`x'__1- egra_a1_r`x'__20 {
		replace `var'=. if egra_a1_r1__98==1.00 
	}
}


//4. If time ran out - setting the remaining variables after the word the child stopped on 'not attempted' i.e. missing

rename egra_a1_r1_out egra_a1_r1_time 

forvalues x=1/19 {
	local i=`x'+1
	forvalues y = `i'/20 {
		replace egra_a1_r1__`y'=. if egra_a1_r1__95==1 & egra_a1_r1_time==(`x')
		replace egra_a1_r3__`y'=. if egra_a1_r3__95==1 & egra_a1_r3_time==(`x')
		replace egra_a1_r5__`y'=. if egra_a1_r5__95==1 & egra_a1_r5_time==(`x')
		replace egra_a1_r9__`y'=. if egra_a1_r9__95==1 & egra_a1_r9_time==(`x')
		}
}


//5. Renaming variables for sub-task 1 
//For ease of doing the analysis for all 3countries, I'm using prefix 'letter' for all countries
//If data is submitted, need to change to 'letter_sound' Nigeria and Ghana
rename (egra_a1_r1__1- egra_a1_r1__20 egra_a1_r3__1- egra_a1_r3__20 egra_a1_r5__1- egra_a1_r5__20 egra_a1_r7__1- egra_a1_r7__20 ///
		egra_a1_r9__1- egra_a1_r9__20) e1_letter# , addnumber
		

//6. Cleaning time remaining - replacing time remaining to 'zero' if time ranout was selected 
rename egra_a1_total letter_time_remain
label var letter_time_remain "Letter sound or name time remaining"

replace letter_time_remain=0 if egra_a1_r1__95==1 | egra_a1_r3__95==1 | egra_a1_r5__95==1 | egra_a1_r7__95==1 | egra_a1_r9__95==1 
replace letter_time_remain=. if egra_a1_r1__98==1 // replacing early stop observations to missing


//7. Calculating number of letter sounds / names read correctly 
egen letter_score=rowtotal(e1_letter*), miss
label var letter_score "Correct letter sound or name score"

//8. Calculate correct letter sounds per minute (clspm) or correct letter names per minute (clpm)
//Rename variable to clspm for Ghana and Nigeria if submitting data
gen clpm=letter_score/(60-letter_time_remain)*60			//need to multiply by 60 at the end to get letters per minute
replace clpm = 100 if clpm>100 & !missing(clpm)				//capping letter per minute score at 100 as per DLA guidance
label var clpm "Correct letter sounds or names per minute"

//I'm creating an additional version of 'clpm' where missing values are replaced with 0's
//When calculating an average score out of 100 across pupils, pupils with missing values would be excluded
//However, these are the weakest pupils and we expect them to improve over time (i.e. by midline / endline)
//So if we exlucde them from the average at BL, but not at ML/EL (because they don't score 'missing' at ML/EL), 
//we would inflate the BL average compared to the ML/EL average
gen clpm_full = clpm
recode clpm_full (.=0)
label var clpm_full "Correct letter sounds or names per minute missing recode to 0"

order letter_score clpm clpm_full, after(letter_time_remain)

//9. Renaming remaining variables
//Don't move this code earlier, it will mess with the calculation of the letter_score
rename egra_a1_r1__98 e1_letter_auto_stop 
label var e1_letter_auto_stop "Letter sound or name auto stop"

rename egra_a1_r1__99 e1_letter_not_attempted 
label var e1_letter_not_attempted "Letter sound or name not attempted"

**************************************
***Sub-task 2: Familiar Word Reading
**************************************

//1. Replacing all correct values to 1 and incorrect values to 0 (for Ghana and Kenya only, already done for Nigeria)

foreach var of varlist egra_a2_r1__1- egra_a2_r1__50 {
	recode `var' (1=0) (0=1) 
	label val `var' answer
	replace `var'=. if egra_a2_r1__99==1
}


//2. Replacing the first 5 words to incorrect if early stop was selected
foreach var of varlist egra_a2_r1__1- egra_a2_r1__5 {
	replace `var'=0 if egra_a2_r1__98==1
}


//3. Setting the remaining 45 words to 'not attempted or missing' if early stop was selected
foreach var of varlist egra_a2_r1__6 - egra_a2_r1__50 {
	replace `var'=. if egra_a2_r1__98==1
}




//4. If time ran out - setting the remaining variables after the word the child stopped on 'not attempted' i.e. missing
forvalues x=1/49 {
	local i=`x'+1
	forvalues y = `i'/50 {
		replace egra_a2_r1__`y'=. if egra_a2_r1__95==1 & egra_a2_r1_out==(`x')
		}
}



//5. Renaming variables for sub-task 2 
rename (egra_a2_r1__1 - egra_a2_r1__50) e1_fam_word#,addnumber


//6. Cleaning time remaining - replacing time remaining to 'zero' if time ranout was selected
rename egra_a2_total fam_word_time_remain 
label var fam_word_time_remain "Familiar words time remaining"
 
replace fam_word_time_remain=0 if egra_a2_r1__95==1
replace fam_word_time_remain = . if egra_a2_r1__98==1 // replacing early stop observations to missing


//7. Calculating number of words read correctly 
egen fam_word_score=rowtotal(e1_fam_word*),miss
label var fam_word_score "Correct familiar words score"


//8. Calculate correct words per minute
gen cwpm=fam_word_score/(60-fam_word_time_remain)*60		//*60 to get words per minute
replace cwpm = 100 if cwpm>100 & !missing(cwpm)				//capping letter per minute score at 100 as per DLA guidance
label var cwpm "Correct familiar words per minute"

gen cwpm_full = cwpm
recode cwpm_full (.=0)
label var cwpm_full "Correct familiar words per minute missing to 0"

order fam_word_score cwpm cwpm_full, after(fam_word_time_remain)

//9. Renaming remaining variables
rename egra_a2_r1__98 e1_fam_word_auto_stop
label var e1_fam_word_auto_stop "Familiar words auto stop"

rename egra_a2_r1__99 e1_fam_word_not_attempted
label var e1_fam_word_not_attempted "Familiar words not attempted"





************************************************
*** Sub-task 3: Invent word
************************************************

//1. Replacing all correct values to 1 and incorrect values to 0 (for Ghana and Kenya only, already done for Nigeria)

foreach var of varlist egra_b3_r1__1- egra_b3_r1__50 {
	recode `var' (1=0) (0=1) 
	label val `var' answer
	replace `var'=. if egra_b3_r1__99==1
}


//2. Replacing the first 5 words to incorrect if early stop was selected
foreach var of varlist egra_b3_r1__1- egra_b3_r1__5 {
	replace `var'=0 if egra_b3_r1__98==1
}


//3. Setting the remaining 45 words to 'not attempted or missing' if early stop was selected
foreach var of varlist egra_b3_r1__6 - egra_b3_r1__50 {
	replace `var'=. if egra_b3_r1__98==1
}



//4. If time ran out - setting the remaining variables after the word the child stopped on 'not attempted' i.e. missing
forvalues x=1/49 {
	local i=`x'+1
	forvalues y = `i'/50 {
		replace egra_b3_r1__`y'=. if egra_b3_r1__95==1 & egra_b3_r1_out==(`x')
		}
}



//5. Renaming variables for sub-task 3 
rename (egra_b3_r1__1- egra_b3_r1__50) e1_invent_word#,addnumber


//6. Cleaning time remaining - replacing time remaining to 'zero' if time ranout was selected 
rename egra_b3_total invent_word_time_remain 
label var invent_word_time_remain "Nonwords time remaining"

replace invent_word_time_remain=0 if egra_b3_r1__95==1
replace invent_word_time_remain = . if egra_b3_r1__98==1 // replacing early stop observations to missing


//7. Calculating number of words read correctly 
egen invent_word_score=rowtotal(e1_invent_word*),miss
label var invent_word_score "Correct nonword score"


//8. Calculate correct words per minute
gen cnonwpm=invent_word_score/(60-invent_word_time_remain)*60	//*60 to get words per minute
replace cnonwpm = 100 if cnonwpm>100 & !missing(cnonwpm)				//capping letter per minute score at 100 as per DLA guidance
label var cnonwpm "Correct nonwords per minute"

gen cnonwpm_full = cnonwpm
recode cnonwpm_full (.=0)
label var cnonwpm_full "Correct non words per minute missing to 0"

order invent_word_score cnonwpm cnonwpm_full, after(invent_word_time_remain)

//9. Renaming remaining variables
rename egra_a3_r1__98 e1_invent_word_auto_stop
label var e1_invent_word_auto_stop "Nonwords auto stop"

rename egra_a3_r1__99 e1_invent_word_not_attempted
label var e1_invent_word_not_attempted "Nonwords not attempted"




***********************************************
*** Sub-task 4: Oral Reading Fluency - KENYA
***********************************************

//1. Replacing all correct values to 1 and incorrect values to 0 (for Ghana and Kenya only, already done for Nigeria)

forvalues x=1/7 {

	local i: word `x' of 30 71 7 35 29 31 34
	foreach var of varlist egrak_a4_r`x'__1- egrak_a4_r`x'__`i' {

		recode `var' (1=0) (0=1) 
		label val `var' answer
		replace `var'=. if egrak_a4_r1__99==1

}
}

//2. Replacing the first 16 words to incorrect if early stop was selected
foreach var of varlist egrak_a4_r1__1- egrak_a4_r1__16 {
	replace `var'=0 if egrak_a4_r1__98==1
}


//3. Setting the remaining words in the first section to 'not attempted or missing' if early stop was selected
//words in other sections are automatically set to missing
foreach var of varlist egrak_a4_r1__17 - egrak_a4_r1__30 {
	replace `var'=. if egrak_a4_r1__98==1
}

forvalues x=2/7 {

	local i: word `x' of 30 71 7 35 29 31 34
	foreach var of varlist egrak_a4_r`x'__1- egrak_a4_r`x'__`i' {
	
		replace `var'=. if egrak_a4_r1__98==1
}
}


//4. If time ran out - setting the remaining variables after the word the child stopped on 'not attempted' i.e. missing
forvalues x=1/7 {

	local i: word `x' of 29 70 6 34 28 30 33
	forvalues v = 1/`i' {
		local z = `i' + 1
		local w = `v' + 1
		forvalues y = `w'/`z' {
		replace egrak_a4_r`x'__`y'=. if egrak_a4_r`x'__95==1 & egrak_a4_r`x'_time==(`v')
		}
	}	
}


//5. Renaming variables for sub-task 4 
rename (egrak_a4_r1__1- egrak_a4_r1__30 egrak_a4_r2__1 - egrak_a4_r2__71 egrak_a4_r3__1 - egrak_a4_r3__7 egrak_a4_r4__1 - egrak_a4_r4__35 ///
		egrak_a4_r5__1- egrak_a4_r5__29 egrak_a4_r6__1 - egrak_a4_r6__31 egrak_a4_r7__1 - egrak_a4_r7__34) e1k_oral_read#,addnumber
		

//6. Calculate time remaining in seconds
gen orf_time_remain = (egrak_a4_read1*60) + (egrak_a4_read2) 
replace orf_time_remain=0 if egrak_a4_r1__95==1 | egrak_a4_r2__95==1 | egrak_a4_r3__95==1 | egrak_a4_r4__95==1 | egrak_a4_r5__95==1 ///
		| egrak_a4_r6__95==1 | egrak_a4_r7__95==1 // if time ran out is selected.
replace orf_time_remain=. if egrak_a4_r1__98==1 // replace time remaining to missing if early stop
label var orf_time_remain "Oral read time remaining"


//7. Calculating number of letter sounds / names read correctly 
egen orf_score=rowtotal(e1k_oral_read*), miss
label var orf_score "Correct oral reading score"


//9. Renaming remaining variables
rename egrak_a4_r1__98 e1_oral_read_auto_stop
label var e1_oral_read_auto_stop "Oral read auto stop"

rename egrak_a4_r1__99 e1_oral_read_not_attempted
label var e1_oral_read_not_attempted "Oral read not attempted"



***********************************************
*** Sub-task 4: Oral Reading Fluency - GHANA AND NIGERIA
***********************************************

//1. Replacing all correct values to 1 and incorrect values to 0 (for Ghana and Kenya only, already done for Nigeria)

forvalues x=1/9 {

	local i: word `x' of 38 32 49 9 3 27 39 16 25
	foreach var of varlist egrag_a4_r`x'__1- egrag_a4_r`x'__`i' {

		recode `var' (1=0) (0=1) 
		label val `var' answer
		replace `var'=. if egrag_a4_r1__99==1

}
}

//2. Replacing the first 14 words to incorrect if early stop was selected
foreach var of varlist egrag_a4_r1__1- egrag_a4_r1__14 {
	replace `var'=0 if egrag_a4_r1__98==1
}


//3. Setting the remaining words in the first section to 'not attempted or missing' if early stop was selected
//words in other sections are automatically set to missing
foreach var of varlist egrag_a4_r1__15 - egrag_a4_r1__38 {
	replace `var'=. if egrag_a4_r1__98==1
}

forvalues x=2/9 {

	local i: word `x' of 38 32 49 9 3 27 39 16 25
	foreach var of varlist egrag_a4_r`x'__1- egrag_a4_r`x'__`i' {
	
		replace `var'=. if egrag_a4_r1__98==1
}
}


//4. If time ran out - setting the remaining variables after the word the child stopped on 'not attempted' i.e. missing
forvalues x=1/9 {

	local i: word `x' of 37 31 48 8 2 26 38 15 24
	forvalues v = 1/`i' {
		local z = `v' + 1
		local w = `v' + 1
		forvalues y = `w'/`z' {
		replace egrag_a4_r`x'__`y'=. if egrag_a4_r`x'__95==1 & egrag_a4_r`x'_time==(`v')
		}
	}	
}


//5. Renaming variables for sub-task 4 
rename (egrag_a4_r1__1- egrag_a4_r1__38 egrag_a4_r2__1 - egrag_a4_r2__32 egrag_a4_r3__1 - egrag_a4_r3__49 egrag_a4_r4__1 - egrag_a4_r4__9 ///
		egrag_a4_r5__1- egrag_a4_r5__3 egrag_a4_r6__1 - egrag_a4_r6__27 egrag_a4_r7__1 - egrag_a4_r7__39 egrag_a4_r8__1 - egrag_a4_r8__16 ///
		egrag_a4_r9__1 - egrag_a4_r9__25) e1gn_oral_read#,addnumber
		

//6. Calculate time remaining in seconds
replace orf_time_remain = (egrag_a4_read1*60) + (egrag_a4_read2) if country==2 | country==3
replace orf_time_remain=0 if egrag_a4_r1__95==1 | egrag_a4_r2__95==1 | egrag_a4_r3__95==1 | egrag_a4_r4__95==1 | egrag_a4_r5__95==1 ///
		| egrag_a4_r6__95==1 | egrag_a4_r7__95==1 | egrag_a4_r8__95==1 | egrag_a4_r9__95==1 // if time ran out is selected.
replace orf_time_remain=. if egrag_a4_r1__98==1 // replace time remaining to missing if early stop


//7. Calculating number of letter sounds / names read correctly 
egen temp = rowtotal(e1gn_oral_read*), miss
replace orf_score = temp if country==2 | country==3
drop temp


//9. Renaming remaining variables
replace e1_oral_read_auto_stop = egrag_a4_r1__98 if country==2 | country==3
drop egrag_a4_r1__98

replace e1_oral_read_not_attempted = egrag_a4_r1__99 if country==2 | country==3
drop egrag_a4_r1__99



//ALL COUNTRIES
//8. Calculate correct words per minute
gen orf = orf_score/(240 - orf_time_remain)*60
replace orf = 100 if orf>100 & !missing(orf)				//capping letter per minute score at 100 as per DLA guidance
label var orf "Correct oral reading words per minute"

gen orf_full = orf
recode orf_full (.=0)
label var orf_full "Correct oral reading words per minute missing to 0"

order e1_oral_read_auto_stop e1_oral_read_not_attempted orf_time_remain orf_score orf orf_full, after(egrak_a4_read2)



********************************************
*** Sub-task 5: Reading comprehension
*******************************************

//KENYA
//1. Renaming variables
rename (egrak_a5_q1 - egrak_a5_q5) e1k_read_comp#, addnumber

//2. Recoding '-1 no response' to missing
foreach var of varlist e1k_read_comp* {
	recode `var' (-1=.)
	}

//3. Calculating total score 
egen read_comp_score_k = rowtotal(e1k_read_comp*), miss
label var read_comp_score_k "Reading comprehension score out of 12 Kenya"


//GHANA AND NIGERIA
//1. Renaming variables
rename (egrag_a5_q1 - egrag_a5_q5) e1gn_read_comp#, addnumber


//2. Recoding '-1 no response' to missing
foreach var of varlist e1gn_read_comp* {
	recode `var' (-1=.)
	}

//3. Calculating total score 
egen read_comp_score_gn = rowtotal(e1gn_read_comp*), miss
label var read_comp_score_gn "Reading comprehension score out of 11 Ghana Nigeria"


//ALL COUNTRIES
//4. Calculating percentage score out of 100
gen read_comp = read_comp_score_k/12*100 if country==1
replace read_comp = read_comp_score_gn/11*100 if country==2 
label var read_comp "Reading comprehension percentage score"

gen read_comp_full = read_comp
recode read_comp_full (.=0)
label var read_comp_full "Reading comprehension percentage missing to 0"

order e1k_read_comp* read_comp_score_k e1gn_read_comp* read_comp_score_gn read_comp read_comp_full, after(orf_full)



********************************************
***		APPEND NIGERIA DATA
********************************************

append using "$outputs\egra_nigeria"
recode country (.=3)

/*
	encode county, gen(county2) label(county)
	drop county
	rename county2 county
*/
	
/*	
	label define lga 16 "Kajiado" 17 "Kiambu" 18 "Machakos" 19 "Nairobi" 20 "Wajir" 21 "Central Gonja" 22 "East Gonja" ///
				23 "Karaga" 24 "Sagnarigu" 25 "Savelugu" 26 "Tamale Metro" 27 "Tolon" 28 "West Mamprusi" 29 "Yendi", modify
	forvalues i=1/5 {
		local a = `i' + 15
		replace lga = `a' if county==`i' & country==1
		}
	forvalues i=1/9 {
		local a = `i' + 20
		replace lga = `a' if district==`i' & country==2
		}
	drop county district
	order lga, after(country)
*/

********************************************
***		SUMMARY SCORES
********************************************

	egen egra_total = rowtotal(clpm_full cwpm_full cnonwpm_full orf_full read_comp_full)
	replace egra_total = egra_total/5
	label var egra_total "Total percentage missing to 0"

//adding in segra task1 
	egen eng_total_v1 = rowtotal(clpm_full cwpm_full cnonwpm_full orf_full read_comp_full segra1_percent)
	replace eng_total_v1 = eng_total_v1/6
	label var eng_total_v1 "Total percentage EGRA and SEGRA task1"
	replace eng_total_v1 = egra_total if country==3

//adding in segra task3
	egen eng_total_v2 = rowtotal(clpm_full cwpm_full cnonwpm_full orf_full read_comp_full segra1_percent segra3_percent)
	replace eng_total_v2 = eng_total_v2/7
	label var eng_total_v2 "Total percentage EGRA and SEGRA task1 and task3"
	replace eng_total_v2 = egra_total if country==3

