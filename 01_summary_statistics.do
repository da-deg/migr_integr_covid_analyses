clear all
macro drop all
version 17.0
clear all
set linesize 120
set more off
capture log close



global root ""

global WD "${root}/Papers/2021_integration_paper_PNAS/work/Analyses"
global INPUT "${root}/Datasets/20231121_ENTRA_SCIP/harmonized_data"									// input data path
global OUTPUT "${WD}/figures_tables"												// define the working directory (= root)

cd "${WD}"

capture mkdir "${OUTPUT}"

capture log close




*Load Dataset
use "${INPUT}/entra-scip-final_sample.dta", clear

drop if panel==0

*Covariates
gen data_summary = 0 if wave==0 &data==0
replace data_summary = 1 if wave==0 &data==1

lab def data_summary 0 "SCIP" 1 "ENTRA"
lab val data_summary data_summary 

tab isced, gen(educ)
lab var educ1 "Education: Low"
lab var educ2 "Education: Medium"
lab var educ3 "Education: High"

gen time_in_germanyw1 = time_in_germany if wave==0
gen time_in_germanyw2 = time_in_germany if wave==1
sort id wave
replace time_in_germanyw1 = time_in_germanyw1[_n-1] if id==id[_n-1]
replace time_in_germanyw2 = time_in_germanyw2[_n+1] if id==id[_n+1]

lab var time_in_germanyw1 "Time living in Germany at wave 1"
lab var time_in_germanyw2 "Time living in Germany at wave 2"

gen lang_int_coursew1 = lang_int_course==1 & wave==0
gen lang_int_coursew2 = lang_int_course==1 & wave==1
sort id wave
replace lang_int_coursew1 = lang_int_coursew1[_n-1] if id==id[_n-1]
replace lang_int_coursew2 = lang_int_coursew2[_n+1] if id==id[_n+1]

lab var lang_int_coursew1 "Lang. or integr. course wave 1"
lab var lang_int_coursew2 "Lang. or integr. course wave 2"

*Poles
estpost tabstat sex age time_in_germanyw1 time_in_germanyw2 educ1 educ2 educ3 lang_int_coursew1 lang_int_coursew2 stay reas_economic reas_education reas_family reas_political if wave==0 & group==0, by(data_summary) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/SI Appendix Table S14 covariates_poles.xls", delimiter(;)  cells("mean (fmt(5)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace

*Turks
estpost tabstat sex age time_in_germanyw1 time_in_germanyw2 educ1 educ2 educ3 lang_int_coursew1 lang_int_coursew2 stay reas_economic reas_education reas_family reas_political if wave==0 & group==1, by(data_summary) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/SI Appendix Table S14 covariates_turks.xls", delimiter(;) cells("mean (fmt(5)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace


drop data_summary
gen wave_data = 0 if wave==0 & data==0
replace wave_data = 1 if wave==1 & data==0
replace wave_data = 2 if wave==0 & data==1
replace wave_data = 3 if wave==1 & data==1
lab def wave_data 0 "SCIP Wave 1" 1 "SCIP Wave 2" 2 "ENTRA Wave 1" 3 "ENTRA Wave 2"
lab val wave_data wave_data 

*Dependent Variables

*Poles
estpost tabstat language spendtime_rc pol_rc unemployed if group==0, by(wave_data) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/SI Appendix Table S13 depdendent_vars_poles.xls", delimiter(;) cells("mean (fmt(5)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace

*Turks
estpost tabstat language spendtime_rc pol_rc unemployed if group==1, by(wave_data) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/SI Appendix Table S13 depdendent_vars_turks.xls", delimiter(;) cells("mean (fmt(5)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace
