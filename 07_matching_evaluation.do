clear all
macro drop all
version 17.0
clear all
set linesize 120
set more off
capture log close



global root ""

global WD "${root}/Papers/2021_integration_paper_PNAS/work/Analyses"
global INPUT "${root}/Datasets/20231226_ENTRA_SCIP/harmonized_data"									// input data path
global OUTPUT "${WD}/figures_tables"												// define the working directory (= root)

capture mkdir "${OUTPUT}"

cd "${WD}"



*Define Figure Style
*Graph Settings
set scheme s2mono 
grstyle clear, erase
grstyle init
grstyle set plain
*grstyle set mesh, horizontal minor
grstyle color background white

*Symbol
grstyle set color gs10 black gs7 gs5
grstyle set symbol S D T O
grstyle set symbolsize large
grstyle color p1line gs10 
grstyle color p2line black 
grstyle color p3line gs7
grstyle color p4line gs5 

*Lines
grstyle set linewidth medthick
grstyle set lpattern solid solid solid solid

*Legend
grstyle set legend 5, box  // inside
graph set window fontface "Arial"


clear

use "${INPUT}/entra-scip-final_sample.dta"
/*
gen ATT = data*wave
lab var ATT "no controls"
gen ATT2 = ATT
lab var ATT2 "controls"
*/

*recode isced 0/2=0 3/6=1 7/9=2


gen time_in_germanyw1 = time_in_germany if wave==0
gen time_in_germanyw2 = time_in_germany if wave==1
sort id wave
replace time_in_germanyw1 = time_in_germanyw1[_n-1] if id==id[_n-1]
replace time_in_germanyw2 = time_in_germanyw2[_n+1] if id==id[_n+1]

lab var time_in_germanyw1 "Time living in Germany at wave 1"
lab var time_in_germanyw2 "Time living in Germany at wave 2"



reshape wide time_in_germany spendtime_rc unemployed pol_rc language, i(id) j(wave)
drop if panel==0
drop panel


*Poles MDM
kmatch md data time_in_germanyw1 time_in_germanyw2 sex age i.isced stay reas_economic reas_education reas_family reas_political if group==0, att bwidth(cv) 


kmatch summarize
mat M = r(M)
mat V = r(V)
coefplot matrix(M[,3]) matrix(M[,6]) || matrix(V[,3]) matrix(V[,6]) || , ///
bylabels("Std. mean difference" "Variance ratio") ///
noci byopts(xrescale) ///
xtitle("") ytitle("Variables") msymbol("X")
addplot 1: , xline(0) norescaling legend(order(1 "Raw" 2 "Matched")) 
addplot 2: , xline(1) norescaling 
graph export "${OUTPUT}/SI Appendix Fig S6.pdf", replace
graph export "${OUTPUT}/SI Appendix Fig S6.svg", replace
graph export "${OUTPUT}/SI Appendix Fig S6.png", replace width(6144) height(3072)


*Poles PS
kmatch ps data time_in_germanyw1 time_in_germanyw2 sex age i.isced stay reas_economic reas_education reas_family reas_political if group==0, att bwidth(cv) 
kmatch summarize
mat M = r(M)
mat V = r(V)
coefplot matrix(M[,3]) matrix(M[,6]) || matrix(V[,3]) matrix(V[,6]) || , ///
bylabels("Std. mean difference" "Variance ratio") ///
noci byopts(xrescale) ///
xtitle("") ytitle("Variables") msymbol("X")
addplot 1: , xline(0) norescaling legend(order(1 "Raw" 2 "Matched")) 
addplot 2: , xline(1) norescaling 
graph export "${OUTPUT}/SI Appendix Fig S7.pdf", replace
graph export "${OUTPUT}/SI Appendix Fig S7.svg", replace
graph export "${OUTPUT}/SI Appendix Fig S7.png", replace width(6144) height(3072)


*Turks MDM
kmatch md data time_in_germanyw1 time_in_germanyw2 sex age i.isced stay reas_economic reas_education reas_family reas_political if group==1, att bwidth(cv) 
kmatch summarize
mat M = r(M)
mat V = r(V)
coefplot matrix(M[,3]) matrix(M[,6]) || matrix(V[,3]) matrix(V[,6]) || , ///
bylabels("Std. mean difference" "Variance ratio") ///
noci byopts(xrescale) ///
xtitle("") ytitle("Variables") msymbol("X")
addplot 1: , xline(0) norescaling legend(order(1 "Raw" 2 "Matched")) 
addplot 2: , xline(1) norescaling 
graph export "${OUTPUT}/SI Appendix Fig S8.pdf", replace
graph export "${OUTPUT}/SI Appendix Fig S8.svg", replace
graph export "${OUTPUT}/SI Appendix Fig S8.png", replace width(6144) height(3072)


*Turks PS
kmatch ps data time_in_germanyw1 time_in_germanyw2 sex age i.isced stay reas_economic reas_education reas_family reas_political if group==1, att bwidth(cv) 
kmatch summarize
mat M = r(M)
mat V = r(V)
coefplot matrix(M[,3]) matrix(M[,6]) || matrix(V[,3]) matrix(V[,6]) || , ///
bylabels("Std. mean difference" "Variance ratio") ///
noci byopts(xrescale) ///
xtitle("") ytitle("Variables") msymbol("X")
addplot 1: , xline(0) norescaling legend(order(1 "Raw" 2 "Matched")) 
addplot 2: , xline(1) norescaling 
graph export "${OUTPUT}/SI Appendix Fig S9.pdf", replace
graph export "${OUTPUT}/SI Appendix Fig S9.svg", replace
graph export "${OUTPUT}/SI Appendix Fig S9.png", replace width(6144) height(3072)



