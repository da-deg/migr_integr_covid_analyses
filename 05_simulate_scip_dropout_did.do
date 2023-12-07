*Task 0: setup
clear all
macro drop all

global root ""

global WD "${root}/Papers/2021_integration_paper_PNAS/work/Analyses"
global INPUT "${root}/Datasets/20231121_ENTRA_SCIP/harmonized_data"									// input data path
global OUTPUT "${WD}/simulated_data"												// define the working directory (= root)

cd ${WD}
capture log close

version 17.0
clear all
set linesize 120
set more off



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
reshape wide time_in_germany spendtime_rc unemployed pol_rc language lang_int_course, i(id) j(wave)

logit panel i.sex c.age c.time_in_germany0 i.stay i.isced c.spendtime_rc0 i.unemployed0 c.language0 c.pol_rc0 lang_int_course0 reas_economic reas_education reas_family reas_political if group==1 & data==0
est store polesw2
predict prob_w2 if group==1

logit panel i.sex c.age c.time_in_germany0 i.stay i.isced c.spendtime_rc0 i.unemployed0 c.language0 c.pol_rc0 lang_int_course0 reas_economic reas_education reas_family reas_political if group==0 & data==0
est store turksw2
predict prob_w2t if group==0

replace prob_w2 = prob_w2t if group==0
drop prob_w2t 

lab def group 0 "Polish subsample" 1 "Turkish subsample", replace
lab val group group

esttab polesw2 turksw2 using "${WD}/figures_tables/SI Appendix Table S11_participationw2.xls", delimiter(;) ///
	varwidth(30) modelwidth(30) ///
	drop(0*) label nonumbers ///
	b(2) pr2(3) ///
	mtitles("Poles" "Turks") ///
	addnote("Logisitic regression models") ///
	replace

histogram prob_w2, by(group data, note("")) xtitle("Predicted probabilities to participate in wave 2") percent

graph export "${WD}/figures_tables/SI Appendix Fig S3.pdf", replace
graph export "${WD}/figures_tables/SI Appendix Fig S3.svg", replace
graph export "${WD}/figures_tables/SI Appendix Fig S3.png", replace width(6144) height(3072)


save "${OUTPUT}/entra_scip_simulated_datasets.dta", replace


*Simulate Datasets and calculate estimates

cap program drop onerep
program define onerep, rclass
 version 17
 clear 

use "${OUTPUT}/entra_scip_simulated_datasets.dta", clear

gen rand =runiform()
gen sample1= rand<prob_w2 
replace sample1=panel if data==0
drop rand
drop if sample1!=1

reshape long time_in_germany spendtime_rc unemployed pol_rc language lang_int_course, i(id) j(wave)

gen ATT = data*wave
xtset id
lab var language "German language skills"



foreach x in language spendtime_rc pol_rc unemployed{   

reg `x' ATT wave data sex age time_in_germany i.isced stay lang_int_course reas_economic reas_education reas_family reas_political a if group==0, cluster(id)
 return scalar pl_`x'_did = _b[ATT]
 return scalar pl_`x'_did_lb = _b[ATT] - invttail(_N,0.025) * _se[ATT]
 return scalar pl_`x'_did_ub = _b[ATT] + invttail(_N,0.025) * _se[ATT]

reg `x' ATT wave data sex age time_in_germany i.isced stay lang_int_course reas_economic reas_education reas_family reas_political a if group==1, cluster(id)
 return scalar tr_`x'_did = _b[ATT]
 return scalar tr_`x'_did_lb = _b[ATT] - invttail(_N,0.025) * _se[ATT]
 return scalar tr_`x'_did_ub = _b[ATT] + invttail(_N,0.025) * _se[ATT]
}





end




clear
set seed 9688907 
cd ${OUTPUT}
tempname did_eval 

postfile `did_eval' int(id_rep) ///
	pl_language_did pl_language_did_lb pl_language_did_ub  ///
	pl_spendtime_rc_did pl_spendtime_rc_did_lb pl_spendtime_rc_did_ub ///
	pl_pol_rc_did pl_pol_rc_did_lb pl_pol_rc_did_ub  ///
	pl_unemployed_did pl_unemployed_did_lb pl_unemployed_did_ub /// 
	tr_language_did tr_language_did_lb tr_language_did_ub  ///
	tr_spendtime_rc_did tr_spendtime_rc_did_lb tr_spendtime_rc_did_ub ///
	tr_pol_rc_did tr_pol_rc_did_lb tr_pol_rc_did_ub  ///
	tr_unemployed_did tr_unemployed_did_lb tr_unemployed_did_ub /// 
	using did_eval.dta , replace 
 
 quietly{
  local dts = 0
  noi _dots 0, title("Simulation running: 10,000 Iterations")
  forval i = 1/10000 {
    local dts = `dts' + 1 
    noi _dots `dts' 0
    capture onerep
    capture post `did_eval' (`i') ///
	(r(pl_language_did)) (r(pl_language_did_lb)) (r(pl_language_did_ub)) ///
	(r(pl_spendtime_rc_did)) (r(pl_spendtime_rc_did_lb)) (r(pl_spendtime_rc_did_ub)) ///
	(r(pl_pol_rc_did)) (r(pl_pol_rc_did_lb)) (r(pl_pol_rc_did_ub)) ///
	(r(pl_unemployed_did)) (r(pl_unemployed_did_lb)) (r(pl_unemployed_did_ub)) ///
	(r(tr_language_did)) (r(tr_language_did_lb)) (r(tr_language_did_ub)) ///
	(r(tr_spendtime_rc_did)) (r(tr_spendtime_rc_did_lb)) (r(tr_spendtime_rc_did_ub)) ///
	(r(tr_pol_rc_did)) (r(tr_pol_rc_did_lb)) (r(tr_pol_rc_did_ub)) ///
	(r(tr_unemployed_did)) (r(tr_unemployed_did_lb)) (r(tr_unemployed_did_ub)) 
    }
  }
 
postclose `did_eval'


   *forval z_y0 =  0 0.4 : 0.8 { // 4
    *forval z_y1 =  0 0.4 : 0.8 {
   *}
   *}



use "${OUTPUT}/did_eval", clear
save "${OUTPUT}/did_eval", replace



