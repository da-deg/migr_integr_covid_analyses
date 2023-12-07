clear all
macro drop all
version 17.0
clear all
set linesize 120
set more off
capture log close


global root "/home/daniel/Dokumente/University/"
global WD "${root}/Papers/2021_integration_paper_PNAS/work/Analyses/simulated_data"
global OUTPUT "${root}Papers/2021_integration_paper_PNAS/work/Analyses/figures_tables"

capture mkdir "${OUTPUT}"

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


use "${WD}/did_eval", clear



*Make the graphics a bit easier to draw
local i=1
foreach x in language spendtime_rc pol_rc unemployed{
  rename pl_`x'_did pl`i'
  rename pl_`x'_did_lb pl_lb`i'
  rename pl_`x'_did_ub pl_ub`i'
  
  rename tr_`x'_did tr`i'
  rename tr_`x'_did_lb tr_lb`i'
  rename tr_`x'_did_ub tr_ub`i'
  local i = `i'+1
}

reshape long pl pl_lb pl_ub tr tr_lb tr_ub, i(id_rep) j(dimension)

*1: did; 2: mdm; 3: psm; 4: fe
lab def dimension 1 "German language skills" 2 "Time spent with Germans" 3 "Interest in German politics" 4 "Unemployment"
lab val dimension dimension



*Poles
sort pl
bysort dimension (pl): gen order_pl = _n
replace order_pl=order_pl*(-1) + 10001 if dimension==3 | dimension==4


gen a = -.0306582 if dimension ==1 
replace a = -.1310946 if dimension ==2
replace a = .0539131 if dimension ==3
replace a =  .0362729  if dimension ==4

twoway 	(scatter order_pl pl, by(dimension, legend(off) title("Polish subsample") note("")) msize(0.5pt) ) ///
	(line order_pl a, by(dimension)) ///
	(rcap pl_lb pl_ub order_pl, by(dimension) horizontal color(gs10) acolor(%1)) ///
	, xline(0) legend(off) xtitle("Estimated effect size") ytitle("Estimations ordered by effect size") ylab(0 2500 "2,500" 5000 "5,000" 7500 "7,500" 10000 "10,000",angle(0))  title("") 

graph export "${OUTPUT}/SI Appendix Fig S4.pdf", replace
graph export "${OUTPUT}/SI Appendix Fig S4.svg", replace
graph export "${OUTPUT}/SI Appendix Fig S4.png", replace width(6144) height(4096)




*Turks

sort tr
bysort dimension (tr): gen order_tr = _n
replace order_tr=order_tr*(-1) + 10001 if dimension==3 | dimension==4



capture drop a
gen a = -.0728374 if dimension ==1 
replace a = -.0828191 if dimension ==2
replace a = .0449198 if dimension ==3
replace a =  .1370672  if dimension ==4

twoway 	(scatter order_tr tr, by(dimension, legend(off) title("Turkish subsample") note("")) msize(0.5pt) ) ///
	(line order_tr a, by(dimension)) ///
	(rcap tr_lb tr_ub order_tr, by(dimension) horizontal color(gs10) acolor(%1)) ///
	, xline(0) legend(off) xtitle("Estimated effect size") ytitle("Estimations ordered by effect size") ylab(0 2500 "2,500" 5000 "5,000" 7500 "7,500" 10000 "10,000",angle(0))  title("") 

graph export "${OUTPUT}/SI Appendix Fig S5.pdf", replace
graph export "${OUTPUT}/SI Appendix Fig S5.svg", replace
graph export "${OUTPUT}/SI Appendix Fig S5.png", replace width(6144) height(4096)



