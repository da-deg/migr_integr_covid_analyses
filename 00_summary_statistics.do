/*
program:    		00_summary_statistics.do
project:    		ENTRA SCIP Article
author:     		Daniel Degen
date:       		03. June 2023 (first version in 2021)
task:       		Summary Statistics

*/

*Task 0: setup
clear all
macro drop all

cd "/home/daniel/Dokumente/University/Papers/2021 integration papier PNAS/work/2023-05-06 Paper/Analyses/do-files"
capture log close

version 17.0
clear all
set linesize 120
set more off


cd "/home/daniel/Dokumente/University/Datasets/ENTRA_SCIP"										// change working directory (= root)
global WD "/home/daniel/Dokumente/University/Papers/2021 integration papier PNAS/work/2023-05-06 Paper"					// define the working directory (= root)
global INPUT "/home/daniel/Dokumente/University/Datasets/ENTRA_SCIP_update"									// input data path
global OUTPUT "${WD}/Analyses_update/figures_tables"	// define the working directory (= root)

*Load Dataset
use "${INPUT}/03_output_data/entra-scip-final_sample.dta", clear

*Covariates
gen data_summary = 0 if wave==0 &data==0
replace data_summary = 1 if wave==0 &data==1

lab def data_summary 0 "SCIP" 1 "ENTRA"
lab val data_summary data_summary 

*Poles
estpost tabstat age sex isced stay time_in_germany time_between if wave==0 & group==0, by(data_summary) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/appendix_covariates_poles.xls", delimiter(;)  cells("mean (fmt(2)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace

*Turks
estpost tabstat age sex isced stay time_in_germany time_between if wave==0 & group==1, by(data_summary) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/appendix_covariates_turks.xls", delimiter(;) cells("mean (fmt(2)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace


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
esttab using "${OUTPUT}/appendix_dependent_vars_poles.xls", delimiter(;) cells("mean (fmt(2)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace

*Turks
estpost tabstat language spendtime_rc pol_rc unemployed if group==1, by(wave_data) statistics(mean p50 sd min max) columns(statistics)
esttab using "${OUTPUT}/appendix_dependent_vars_turks.xls", delimiter(;) cells("mean (fmt(2)) p50 (fmt(2)) sd (fmt(2)) min max (fmt(2))")  noobs nomtitle nonumber eqlabels(`e(labels)') varwidth(40) label replace
