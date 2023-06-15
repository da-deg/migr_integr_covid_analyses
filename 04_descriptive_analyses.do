/*
program:    		04_descriptive_analyses.do
project:    		ENTRA SCIP Article
author:     		Daniel Degen
date:       		03. June 2023 (first version in 2021)
task:       		Descriptive Change between panel waves and between datasets

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

*Define Figure Style
*Graph Settings
set scheme s2mono 
grstyle clear, erase
grstyle init
grstyle set plain
grstyle set mesh, horizontal minor
grstyle color background white

*Symbol
grstyle set color gs7 black gs5 gs10
grstyle set symbol S D T O
grstyle set symbolsize large
grstyle color p1line gs7 
grstyle color p2line black 
grstyle color p3line gs5
grstyle color p4line gs10

*Lines
grstyle set linewidth medthick
grstyle set lpattern solid solid solid solid

*Legend
grstyle set legend 5, box  // inside
graph set window fontface "Arial"




*Load Dataset
use "${INPUT}/03_output_data/entra-scip-final_sample.dta", clear



gen ATT = data*wave
lab var ATT "no controls"
gen ATT2 = ATT
lab var ATT2 "controls"

* Calculate Difference-in-Difference Models

*Poles
reg language i.data##i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store language1
margins wave#data 
marginsplot, ///
	title("A", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Language Skills") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(language1, replace) nodraw


reg spendtime_rc i.data##i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store spendtime_rc1
margins wave#data 
marginsplot, ///
	title("B", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Time spent with Germans") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(spendtime_rc1, replace) nodraw


reg pol_rc i.data##i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store pol_rc1
margins wave#data 
marginsplot, ///
	title("C", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Interest in German politics") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(pol_rc1, replace) nodraw


reg unemployed i.data##i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store unemployed1
margins wave#data 
marginsplot, ///
	title("D", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Unemployment") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(unemployed1, replace) nodraw


*Turks

reg language i.data##i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store language2
margins wave#data 
marginsplot, ///
	title("A", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Language Skills") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(language2, replace) nodraw


reg spendtime_rc i.data##i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store spendtime_rc2
margins wave#data 
marginsplot, ///
	title("B", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Time spent with Germans") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(spendtime_rc2, replace) nodraw


reg pol_rc i.data##i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store pol_rc2
margins wave#data 
marginsplot, ///
	title("C", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Interest in German politics") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(pol_rc2, replace) nodraw


reg unemployed i.data##i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store unemployed2
margins wave#data 
marginsplot, ///
	title("D", pos(12) xoffset(-30) yoffset(-4) size(huge)) ///
	ytitle("") subtitle("Unemployment") ///
	legend(region(col(white)) size(vsmall)) ///
	plotopts(msize(medium)) ///
	name(unemployed2, replace) nodraw




graph combine language1 spendtime_rc1 pol_rc1 unemployed1, name(combined1, replace) imargin(4 4 4 4) title(Polish Subsample)
graph display combined1, xsize(6) ysize(4) 
graph export "${OUTPUT}/figure05.pdf", replace

graph combine language2 spendtime_rc2 pol_rc2 unemployed2, name(combined2, replace) imargin(4 4 4 4) title(Turkish Subsample)
graph display combined2, xsize(6) ysize(4) 
graph export "${OUTPUT}/figure06.pdf", replace
