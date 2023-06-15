/*
program:    		01_sample_description.do
project:    		ENTRA SCIP Article
author:     		Daniel Degen
date:       		03. June 2023 (first version in 2021)
task:       		Sample Description

*/

*Task 0: setup
clear all
macro drop all

cd "/home/daniel/Dokumente/University/Papers/2021 integration papier PNAS/work/2023-05-06 Paper/Analyses/do-files"
capture log close
log using "analyses.log", replace


version 17.0
clear all
set linesize 120
set more off


cd "/home/daniel/Dokumente/University/Datasets/ENTRA_SCIP"										// change working directory (= root)
global WD "/home/daniel/Dokumente/University/Papers/2021 integration papier PNAS/work/2023-05-06 Paper"					// define the working directory (= root)
global INPUT "/home/daniel/Dokumente/University/Datasets/ENTRA_SCIP"									// input data path
global OUTPUT "/home/daniel/Dokumente/University/Papers/2021 integration papier PNAS/work/2023-05-06 Paper/Analyses/figures_tables"	// define the working directory (= root)



*Load Dataset
use "${INPUT}/03_output_data/entra-scip-final_sample.dta", clear


*Poles
summarize age time_in_germany sex time_between isced stay if group==0 & data==0 & wave==0 // SCIP Wave 1
summarize age time_in_germany sex time_between isced stay if group==0 & data==0 & wave==1 // SCIP Wave 2
summarize age time_in_germany sex time_between isced stay if group==0 & data==1 & wave==0 // ENTRA Wave 1
summarize age time_in_germany sex time_between isced stay if group==0 & data==1 & wave==1 // ENTRA Wave 2

*Turks
summarize age time_in_germany sex time_between isced stay if group==1 & data==0 & wave==0 // SCIP Wave 1
summarize age time_in_germany sex time_between isced stay if group==1 & data==0 & wave==1 // SCIP Wave 2
summarize age time_in_germany sex time_between isced stay if group==1 & data==1 & wave==0 // ENTRA Wave 1
summarize age time_in_germany sex time_between isced stay if group==1 & data==1 & wave==1 // ENTRA Wave 2


