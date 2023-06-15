/*
program:    		03_robustness.do
project:    		ENTRA SCIP Article
author:     		Daniel Degen
date:       		03. June 2023 (first version in 2021)
task:       		Robustness Checks (using other models)

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




*Load Dataset
use "${INPUT}/03_output_data/entra-scip-final_sample.dta", clear
/*
gen ATT = data*wave
lab var ATT "no controls"
gen ATT2 = ATT
lab var ATT2 "controls"
*/

*recode isced 0/2=0 3/6=1 7/9=2
reshape wide time_in_germany spendtime_rc unemployed pol_rc language int_year int_month migr_year migr_month, i(id) j(wave)



*Poles MDM
kmatch md data  time_between age time_in_germany0 i.isced stay if group==0, ematch(sex) att wgenerate(kmatch_md_pl) bwidth(cv) 
*Poles PS
kmatch ps data  time_between age time_in_germany0 i.isced stay if group==0, ematch(sex) att wgenerate(kmatch_ps_pl) bwidth(cv) 
*Turks MDM
kmatch md data  time_between age time_in_germany0 i.isced stay if group==1, ematch(sex) att wgenerate(kmatch_md_tr) bwidth(cv) 
*Turks PS
kmatch ps data  time_between age time_in_germany0 i.isced stay if group==1, ematch(sex) att wgenerate(kmatch_ps_tr) bwidth(cv) 


reshape long time_in_germany spendtime_rc unemployed pol_rc language, i(id) j(wave)


gen ATT = data*wave
xtset id


gen a=0 // Hilfsvariable für Output
local i = 0
foreach x in language spendtime_rc pol_rc unemployed{   

local i = `i' +1
local panel : word `i' of `c(ALPHA)'


reg `x' ATT wave data sex age time_in_germany i.isced stay a if group==0, cluster(id)
est store didcontrols1

reg `x' ATT wave data i.a [pweight=kmatch_md_pl] if group==0, cluster(id)
est store kmatchmd1

reg `x' ATT wave data i.a [pweight=kmatch_ps_pl] if group==0, cluster(id)
est store kmatchps1

xtreg `x' ATT wave time_in_germany a if group==0, fe
est store fe1

local label : variable label `x'

coefplot didcontrols1 kmatchmd1 kmatchps1 fe1, ///
	keep(ATT) xline(0, lcolor(black)) ///
	xlab(-0.2(0.1)0.2) ciopts(recast(rcap)) ///
	title(`panel', pos(12) xoffset(-35) yoffset(-4) size(huge))  ///
	subtitle("`label'", size(large)) ///
	graphregion(fcolor(white) lcolor(white)) ///
	legend(order(2 "DiD - with controls" 4 "Mahalanobis Dist. Match." 6 "Propensity Score Match." 8 "Fixed-Effects") region(col(white)) size(vsmall))  ///
	format(%9.2f) mlabposition(12) mlabgap(*0) msize(small) ///
	mlabel(cond(@pval<.001, string(@b,"%9.2f") + "***", cond(@pval<.01, string(@b,"%9.2f") + "**", cond(@pval<.05, string(@b,"%9.2f") + "*",string(@b,"%9.2f"))))) ///
	name(`x'1, replace) nodraw

esttab didcontrols1 kmatchmd1 kmatchps1 fe1 using "${OUTPUT}/figure03_table_poles_`label'.xls", delimiter(;) ///
	varwidth(30) modelwidth(40) ///
	mtitles("DiD" "Mahalanobis Dist. Match" "Propensity Score Matching" "Fixed-Effects") ///
	drop(a *0*) label nonumbers ///
	b(2) r2(3) ///
	replace

}

graph combine language1 spendtime_rc1 pol_rc1 unemployed1,  name(combined, replace) imargin(4 4 4 4) title(Polish Subsample)
graph display combined, xsize(6) ysize(4) 
graph export "${OUTPUT}/figure03.pdf", replace



local i = 0
foreach x in language spendtime_rc pol_rc unemployed{   

local i = `i' +1
local panel : word `i' of `c(ALPHA)'

reg `x' ATT wave data sex age time_in_germany i.isced stay a if group==1, cluster(id)
est store didcontrols2

reg `x' ATT wave data i.a [pweight=kmatch_md_tr] if group==1, cluster(id)
est store kmatchmd2

reg `x' ATT wave data i.a [pweight=kmatch_ps_tr] if group==1, cluster(id)
est store kmatchps2

xtreg `x' ATT wave time_in_germany a if group==1, fe
est store fe2

local label : variable label `x'

coefplot didcontrols2 kmatchmd2 kmatchps2 fe2, ///
	keep(ATT) xline(0, lcolor(black)) ///
	xlab(-0.2(0.1)0.5) ciopts(recast(rcap)) ///
	title(`panel', pos(12) xoffset(-35) yoffset(-4) size(huge))  ///
	subtitle("`label'", size(large)) ///
	graphregion(fcolor(white) lcolor(white)) ///
	legend(order(2 "DiD - with controls" 4 "Mahalanobis Dist. Match." 6 "Propensity Score Match." 8 "Fixed-Effects") region(col(white)) size(vsmall))  ///
	format(%9.2f) mlabposition(12) mlabgap(*0) msize(small) ///
	mlabel(cond(@pval<.001, string(@b,"%9.2f") + "***", cond(@pval<.01, string(@b,"%9.2f") + "**", cond(@pval<.05, string(@b,"%9.2f") + "*",string(@b,"%9.2f"))))) ///
	name(`x'2, replace) nodraw
	
	
esttab didcontrols2 kmatchmd2 kmatchps2 fe2 using "${OUTPUT}/figure04_table_turks_`label'.xls", delimiter(;) ///
	varwidth(30) modelwidth(30) ///
	mtitles("DiD" "Mahalanobis Dist. Match" "Propensity Score Matching" "Fixed-Effects") ///
	drop(a *0*) label nonumbers ///
	b(2) r2(3) ///
	replace

}

graph combine language2 spendtime_rc2 pol_rc2 unemployed2,  name(combined, replace)  imargin(4 4 4 4) title(Turkish Subsample)
graph display combined, xsize(6) ysize(4) 
graph export "${OUTPUT}/figure04.pdf", replace


