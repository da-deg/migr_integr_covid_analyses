/*
program:    		02_analyses_main_models.do
project:    		ENTRA SCIP Article
author:     		Daniel Degen
date:       		03. June 2023 (first version in 2021)
task:       		Calculate Difference-in-Difference Models

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

gen ATT = data*wave
lab var ATT "no controls"
gen ATT2 = ATT
lab var ATT2 "controls"

* Calculate Difference-in-Difference Models

reg language ATT i.data i.wave if group==0, cluster(id)
est store language1

reg language ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store language2

reg pol_rc ATT i.data i.wave if group==0, cluster(id)
est store pol_rc1

reg pol_rc ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store pol_rc2
 
reg spendtime_rc ATT i.data i.wave if group==0, cluster(id)
est store spendtime_rc1

reg spendtime_rc ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store spendtime_rc2
 
reg unemployed ATT i.data i.wave if group==0, cluster(id)
est store unemployed1

reg unemployed ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==0, cluster(id)
est store unemployed2 

coefplot (language1 language2, asequation({bf:German Language Skills}) \ /// 
	spendtime_rc1 spendtime_rc2, asequation({bf:Time spent with Germans}) \ /// 
	pol_rc1 pol_rc2, asequation({bf:Interest in German politics}) \ /// 
	unemployed1 unemployed2, asequation({bf:Unemployment}))  ///
	, eqlabels(, asheadings ) /// 
	keep(*ATT*) xline(0) ///
	title("A", pos(12) xoffset(-58.5) yoffset(1.8) size(vhuge)) ///
	subtitle("Polish Subsample", size(large)) ///
	mcolor("black") ///
	msymbol(X) ///
	levels(99.9 99 95) ///
	ciopts(recast(rcap) lwidth(*1 *2 *4) pstyle("___")) /// 
	legend(region(col(white)) title("Confidence Intervals", size(small)) order(1 "99.9% (***)" 2 "99% (**)" 3 "95% (*)") rows(1) position(7)) ///
	xlab(-0.2 -0.1 0 0.1 0.2) xscale(range(-0.25 0.25)) ///
	ylab(,labcolor("black")) ///
	graphregion(fcolor(white) lcolor(white)) ///
	format(%9.2f) mlabposition(12) mlabgap(*0) ///
	mlabel(cond(@pval<.001, string(@b,"%9.2f") + "***", cond(@pval<.01, string(@b,"%9.2f") + "**", cond(@pval<.05, string(@b,"%9.2f") + "*",string(@b,"%9.2f"))))) ///
	name(g1, replace) ///	
	nodraw
*graph export "${OUTPUT}/result01_pol_did.pdf", replace	
*Subtitle: note("Coefficients are the difference of the change from Wave 1 to Wave 2" "between ENTRA and SCIP.") ///
/*
Orietniert am Beispiel Schmelz:
Differences in integration trajectories under pandemic and non-pandemic times for recent immigrants. Predictors indicate the difference in the slopes between the first and the second interview of being affected compared to being not affected by the pandemic for Polish (A) and Turkish (B) immigrants for four outcomes (language skills, time spent with Germans, political interest, and unemploymet). Shown are the coefficients and 95%, 99%, 99.5% CIs, estimated in ordinary least squares linear regressions with clustered standard errors on the individual level (SI Appendix, Tables S3 and S4). All models in essence contain the main effects of the panel wave and a variable indicating the dataset as well as the interaction effect of these variables. The first models are estimated without control variables (no controls), while the models below (controls) account for various factors (age, time in Germany, time between panel waves, education, sex, and whether the respondents stated that they want to stay in Germany). All control variables where measured in the first panel wave.
*/

	
reg language ATT i.data i.wave if group==1, cluster(id)
est store language3

reg language ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store language4

reg pol_rc ATT i.data i.wave if group==1, cluster(id)
est store pol_rc3

reg pol_rc ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store pol_rc4
 
reg spendtime_rc ATT i.data i.wave if group==1, cluster(id)
est store spendtime_rc3

reg spendtime_rc ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store spendtime_rc4
 
reg unemployed ATT i.data i.wave if group==1, cluster(id)
est store unemployed3 

reg unemployed ATT2 i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store unemployed4 
	
coefplot (language3 language4, asequation({bf:German Language Skills}) \ /// 
	spendtime_rc3 spendtime_rc4, asequation({bf:Time spent with Germans}) \ /// 
	pol_rc3 pol_rc4, asequation({bf:Interest in German politics}) \ /// 
	unemployed3 unemployed4, asequation({bf:Unemployment}))  ///
	, eqlabels(, asheadings ) /// 
	keep(*ATT*) xline(0) ///
	title("B", pos(12) xoffset(-58.5) yoffset(1.8) size(vhuge)) ///
	subtitle("Turkish Subsample", size(large)) ///
	mcolor("black") ///
	msymbol(X) ///
	levels(99.9 99 95) ///
	ciopts(recast(rcap) lwidth(*1 *2 *4) pstyle("___")) /// 
	legend(region(col(white)) title("Confidence Intervals", size(small)) order(1 "99.9% (***)" 2 "99% (**)" 3 "95% (*)") rows(1) position(7)) ///
	xlab(-0.2 -0.1 0 0.1 0.2) xscale(range(-0.25 0.25)) ///
	ylab(,labcolor("black")) ///
	graphregion(fcolor(white) lcolor(white)) ///
	format(%9.2f) mlabposition(12) mlabgap(*0) ///
	mlabel(cond(@pval<.001, string(@b,"%9.2f") + "***", cond(@pval<.01, string(@b,"%9.3f") + "**", cond(@pval<.05, string(@b,"%9.2f") + "*",string(@b,"%9.2f"))))) ///
	name(g2, replace) ///
	nodraw

graph combine g1 g2 ,  name(combined, replace) imargin(4 4 4 4) 
graph display combined, xsize(6) ysize(3) 
graph export "${OUTPUT}/figure02.pdf", replace

lab def data 1 "ENTRA (Ref: SCIP)", replace
lab def wave 1 "Wave 2 (Ref: Wave 1)", replace
lab var ATT "Interaction: data*wave"




reg language ATT i.data i.wave if group==1, cluster(id)
est store language3

reg language ATT i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store language4

reg pol_rc ATT i.data i.wave if group==1, cluster(id)
est store pol_rc3

reg pol_rc ATT i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store pol_rc4
 
reg spendtime_rc ATT i.data i.wave if group==1, cluster(id)
est store spendtime_rc3

reg spendtime_rc ATT i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store spendtime_rc4
 
reg unemployed ATT i.data i.wave if group==1, cluster(id)
est store unemployed3 

reg unemployed ATT i.data i.wave sex age time_in_germany i.isced stay if group==1, cluster(id)
est store unemployed4 


esttab language1 language2 spendtime_rc1 spendtime_rc2 pol_rc1 pol_rc2 unemployed1 unemployed2 using "${OUTPUT}/figure02_table_poles.xls", delimiter(;) ///
	varwidth(30) modelwidth(30) ///
	drop(0*) label nonumbers ///
	b(2) r2(3) ///
	mtitles("Language" "Language" "Social Int."  "Social Int." "Political Int." "Political Int." "Unemployed" "Unemployed") ///
	addnote("Linear regression models with cluster robust standard errors on the individual level") ///
	replace
	

*Turks
esttab language3 language4 spendtime_rc3 spendtime_rc4 pol_rc3 pol_rc4 unemployed3 unemployed4 using "${OUTPUT}/figure02_table_turks.xls", delimiter(;) ///
	varwidth(30) modelwidth(30) ///
	drop(0*) label nonumbers ///
	b(2) r2(3) ///
	mtitles("Language" "Language" "Social Int."  "Social Int." "Political Int." "Political Int." "Unemployed" "Unemployed") ///
	addnote("Linear regression models with cluster robust standard errors on the individual level") ///
	replace
