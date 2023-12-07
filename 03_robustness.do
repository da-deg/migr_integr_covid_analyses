clear all
macro drop all
version 17.0
clear all
set linesize 120
set more off
capture log close



global root "/home/daniel/Dokumente/University/"

global WD "${root}/Papers/2021_integration_paper_PNAS/work/Analyses"
global INPUT "${root}/Datasets/20231121_ENTRA_SCIP/harmonized_data"									// input data path
global OUTPUT "${WD}/figures_tables"												// define the working directory (= root)

capture mkdir "${OUTPUT}"

cd ${WD}



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



reshape wide time_in_germany spendtime_rc unemployed pol_rc language lang_int_course, i(id) j(wave)
drop if panel==0
drop panel


*Poles MDM
kmatch md data time_in_germanyw1 time_in_germanyw2 age i.isced stay lang_int_course0 lang_int_course1 reas_economic reas_education reas_family reas_political if group==0, ematch(sex) att wgenerate(kmatch_md_pl) bwidth(cv) 
*Poles PS
kmatch ps data time_in_germanyw1 time_in_germanyw2 age i.isced stay lang_int_course0 lang_int_course1 reas_economic reas_education reas_family reas_political if group==0, ematch(sex) att wgenerate(kmatch_ps_pl) bwidth(cv) 
*Turks MDM
kmatch md data time_in_germanyw1 time_in_germanyw2 age i.isced stay lang_int_course0 lang_int_course1 reas_economic reas_education reas_family reas_political if group==1, ematch(sex) att wgenerate(kmatch_md_tr) bwidth(cv) 
*Turks PS
kmatch ps data time_in_germanyw1 time_in_germanyw2 age i.isced stay lang_int_course0 lang_int_course1 reas_economic reas_education reas_family reas_political if group==1, ematch(sex) att wgenerate(kmatch_ps_tr) bwidth(cv) 

/*
*Check whether results are affected by observations with very high weights: no, results remain the same. 
foreach x in kmatch_md_pl kmatch_ps_pl kmatch_md_tr kmatch_ps_tr{
  replace `x'=. if `x' > 10
}
*/

reshape long time_in_germany spendtime_rc unemployed pol_rc language lang_int_course, i(id) j(wave)


gen ATT = data*wave
xtset id
lab var language "German language skills"

gen a=0 // Hilfsvariable für Output
local i = 0
foreach x in language spendtime_rc pol_rc unemployed{   

local i = `i' +1
local panel : word `i' of `c(ALPHA)'
local j = `i' +0

reg `x' ATT data wave sex age time_in_germany i.isced lang_int_course stay reas_economic reas_education reas_family reas_political a if group==0, cluster(id)
est store didcontrols1

reg `x' ATT data wave i.a [pweight=kmatch_md_pl] if group==0, cluster(id)
est store kmatchmd1

reg `x' ATT data wave i.a [pweight=kmatch_ps_pl] if group==0, cluster(id)
est store kmatchps1

xtreg `x' ATT wave time_in_germany lang_int_course a if group==0, fe
est store fe1

local label : variable label `x'

coefplot didcontrols1 kmatchmd1 kmatchps1 fe1, ///
	keep(ATT) xline(0, lcolor(black)) ///
	xlab(-0.2(0.1)0.2) ciopts(recast(rcap)) ///
	title(`panel', pos(12) xoffset(-35) yoffset(-4) size(huge))  ///
	subtitle("`label'", size(large)) ///
	graphregion(fcolor(white) lcolor(white)) ///
	legend(order(2 "DiD - with controls" 4 "Mahalanobis dist. match." 6 "Propensity score match." 8 "Fixed effects") region(col(white)) size(vsmall))  ///
	format(%9.2f) mlabposition(12) mlabgap(*.5) msize(small) ///
	mlabel(cond(@pval<.001, string(@b,"%9.2f") + "***", cond(@pval<.01, string(@b,"%9.2f") + "**", cond(@pval<.05, string(@b,"%9.2f") + "*",string(@b,"%9.2f"))))) ///
	name(`x'1, replace) nodraw

esttab didcontrols1 kmatchmd1 kmatchps1 fe1 using "${OUTPUT}/SI Appendix Table S3 `j'_figure03_`panel'_table_poles_`label'.xls", delimiter(;) ///
	varwidth(30) modelwidth(40) ///
	mtitles("DiD" "Mahalanobis Dist. Match" "Propensity Score Matching" "Fixed-Effects") ///
	drop(a *0*) label nonumbers ///
	b(2) r2(3) ///
	replace

}

graph combine language1 spendtime_rc1 pol_rc1 unemployed1,  name(combined, replace) imargin(4 4 4 4) title(Polish subsample) note("Point estimates including 95% confidence intervals; stars indicate confidence intervals: *** 99.9%, ** 99%, * 95%", size(vsmall))
graph display combined, xsize(6) ysize(4) 
graph export "${OUTPUT}/figure03.pdf", replace
graph export "${OUTPUT}/figure03.svg", replace
graph export "${OUTPUT}/figure03.png", replace width(6144) height(4096)


local i = 0
foreach x in language spendtime_rc pol_rc unemployed{   

local i = `i' +1
local panel : word `i' of `c(ALPHA)'
local j = `i' +0


reg `x' ATT data wave sex age time_in_germany i.isced lang_int_course stay reas_economic reas_education reas_family reas_political a if group==1, cluster(id)
est store didcontrols2

reg `x' ATT data wave i.a [pweight=kmatch_md_tr] if group==1, cluster(id)
est store kmatchmd2

reg `x' ATT data wave i.a [pweight=kmatch_ps_tr] if group==1, cluster(id)
est store kmatchps2

xtreg `x' ATT wave time_in_germany lang_int_course a if group==1, fe
est store fe2

local label : variable label `x'

coefplot didcontrols2 kmatchmd2 kmatchps2 fe2, ///
	keep(ATT) xline(0, lcolor(black)) ///
	xlab(-0.2(0.2)0.6) ciopts(recast(rcap)) ///
	title(`panel', pos(12) xoffset(-35) yoffset(-4) size(huge))  ///
	subtitle("`label'", size(large)) ///
	graphregion(fcolor(white) lcolor(white)) ///
	legend(order(2 "DiD - with controls" 4 "Mahalanobis dist. match." 6 "Propensity score match." 8 "Fixed effects") region(col(white)) size(vsmall))  ///
	graphregion(fcolor(white) lcolor(white)) ///
	format(%9.2f) mlabposition(12) mlabgap(*0.5)  msize(small)  ///
	mlabel(cond(@pval<.001, string(@b,"%9.2f") + "***", cond(@pval<.01, string(@b,"%9.2f") + "**", cond(@pval<.05, string(@b,"%9.2f") + "*",string(@b,"%9.2f"))))) ///
	name(`x'2, replace) nodraw
	

esttab didcontrols2 kmatchmd2 kmatchps2 fe2 using "${OUTPUT}/SI Appendix Table S4 `j'_figure04_`panel'_table_turks_`label'.xls", delimiter(;) ///
	varwidth(30) modelwidth(30) ///
	mtitles("DiD" "Mahalanobis Dist. Match" "Propensity Score Matching" "Fixed-Effects") ///
	drop(a *0*) label nonumbers ///
	b(2) r2(3) ///
	replace

}

graph combine language2 spendtime_rc2 pol_rc2 unemployed2,  name(combined, replace)  imargin(4 4 4 4) title(Turkish subsample) note("Point estimates including 95% confidence intervals; stars indicate confidence intervals: *** 99.9%, ** 99%, * 95%", size(vsmall))
graph display combined, xsize(6) ysize(4) 
graph export "${OUTPUT}/figure04.pdf", replace
graph export "${OUTPUT}/figure04.svg", replace
graph export "${OUTPUT}/figure04.png", replace width(6144) height(4096)


