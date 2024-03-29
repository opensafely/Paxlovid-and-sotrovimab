********************************************************************************
*
*	Do-file:		cox.do
*
*	Project:		sotrovimab-and-Paxlovid
*
*	Programmed by:	Bang Zheng
*
*	Data used:		output/main_mol.dta
*
*	Output:	        logs/cox_mol.log  output/mol/phtest.svg  output/mol/phtest_psw.svg
*
********************************************************************************
*
*	Purpose: This do-file implements stratified Cox regression, propensity score
*   weighted Cox, and subgroup analyses.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/cox_mol, replace t
clear

use ./output/main_mol.dta

*follow-up time and events*
stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
tab _t,m
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure==1,m col
tab _t drug if failure==1&end_date==covid_hospitalisation_outcome_da&end_date!=death_with_covid_on_the_death_ce,m col
tab _t drug if failure==1&end_date==death_with_covid_on_the_death_ce,m col
tab failure drug,m col
*check censor reasons*
tab _t drug if failure==0&_t<28&end_date==death_date,m col
tab _t drug if failure==0&_t<28&end_date==dereg_date,m col
tab _t drug if failure==0&_t<28&end_date==covid_hosp_date_day_cases,m col
tab _t drug if failure==0&_t<28&end_date==min(sotrovimab_covid_therapeutics,molnupiravir_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)&drug==1,m col
tab _t drug if failure==0&_t<28&end_date==min(sotrovimab_covid_therapeutics,paxlovid_covid_therapeutics,remdesivir_covid_therapeutics,casirivimab_covid_therapeutics)&drug==0,m col


*un-stratified Cox, with covariate adjustment, complete case*
stcox i.drug
stcox i.drug age i.sex
stcox i.drug age i.sex i.stp
*stp or region_covid_therapeutics? *
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro 
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* 
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex i.stp
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro 
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex i.stp
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro 
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*PH test*
*estat phtest,de

*un-stratified Cox, missing values as a separate category*
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* 
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease
*estat phtest,de

*stratified Cox, complete case*
stcox i.drug age i.sex, strata(stp)
*stcox i.drug age i.sex, strata(stp week_after_campaign)
*too few events to allow two-level stratification*
stcox i.drug age i.sex i.stp, strata(week_after_campaign)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(week_after_campaign)
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3, strata(week_after_campaign)
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex i.stp, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex i.stp, strata(week_after_campaign)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
*estat phtest,de
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*estat phtest,de

*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3, strata(week_after_campaign)
stcox i.drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: 5-year band*
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.stp i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3, strata(week_after_campaign)
stcox i.drug b7.age_5y_band i.stp i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*age: Restricted cubic spline*
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* i.b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
*estat phtest,de
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3, strata(week_after_campaign)
stcox i.drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(week_after_campaign)
*estat phtest,de



*propensity score weighted Cox*
do "analysis/ado/psmatch2.ado"
*age continuous, complete case*
psmatch2 drug age i.sex i.stp, logit
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp ) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro ) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*estat phtest,de

*age continuous, missing values as a separate categorye*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
histogram _pscore, by(drug, col(1))
graph export ./output/psgraph_mol.svg, as(svg) replace
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*estat phtest,de

*age: 5-year band, complete case*
psmatch2 drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de 
*teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline*) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White b5.imd i.vaccination_g3 calendar_day_spline* b1.bmi_g3 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*estat phtest,de

*age: 5-year band, missing values as a separate categorye*
psmatch2 drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug b7.age_5y_band i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*estat phtest,de

*age spline, missing values as a separate categorye*
psmatch2 drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

psmatch2 drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*estat phtest,de


*secondary outcomes*
*all-cause hosp/death*
*follow-up time and events*
stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure_allcause==1,m col
tab _t drug if failure_allcause==1&end_date_allcause==hospitalisation_outcome_date&end_date_allcause!=death_date,m col
tab _t drug if failure_allcause==1&end_date_allcause==death_date,m col
tab failure_allcause drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
*PSW age continuous, missing values as a separate categorye*
psmatch2 drug age i.sex i.stp  if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_allcause) (drug age i.sex i.stp ) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro   if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_allcause) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  ) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_allcause) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* ) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_allcause) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*PSW age spline, missing values as a separate categorye*
psmatch2 drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_allcause) (drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug


*2m covid hosp/death*
*follow-up time and events*
stset end_date_2m if start_date<=mdy(11,1,2022),  origin(start_date) failure(failure_2m==1)
tab _t,m
tab _t drug,m col
by drug, sort: sum _t ,de
tab _t drug if failure_2m==1,m col
tab _t drug if failure_2m==1&end_date_2m==covid_hospitalisation_outcome_da&end_date_2m!=death_with_covid_on_the_death_ce,m col
tab _t drug if failure_2m==1&end_date_2m==death_with_covid_on_the_death_ce,m col
tab failure_2m drug if _st==1,m col
*stratified Cox, missing values as a separate category*
stcox i.drug age i.sex, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug b7.age_5y_band i.sex, strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug b7.age_5y_band i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age_spline* i.sex, strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age_spline* i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
*PSW age continuous, missing values as a separate categorye*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_2m) (drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date_2m [pwei=psweight],  origin(start_date) failure(failure_2m==1)
stcox i.drug
*PSW age spline, missing values as a separate categorye*
psmatch2 drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_2m) (drug age_spline* i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date_2m [pwei=psweight],  origin(start_date) failure(failure_2m==1)
stcox i.drug




*sensitivity analysis*
stset end_date ,  origin(start_date) failure(failure==1)
*additionally adjusting for days between test positive and treatment initiation, and days/months between last vaccination date and treatment initiation; *
stcox i.drug age i.sex i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
*excluding patients with treatment records of both mol and Pax, or with treatment records of any other therapies*
stcox i.drug age i.sex if (molnupiravir_covid_therapeutics==.|paxlovid_covid_therapeutics==.|molnupiravir_covid_therapeutics>start_date_29|paxlovid_covid_therapeutics>start_date_29)&sotrovimab_covid_therapeutics>start_date_29&remdesivir_covid_therapeutics>start_date_29&casirivimab_covid_therapeutics>start_date_29, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if (molnupiravir_covid_therapeutics==.|paxlovid_covid_therapeutics==.|molnupiravir_covid_therapeutics>start_date_29|paxlovid_covid_therapeutics>start_date_29)&sotrovimab_covid_therapeutics>start_date_29&remdesivir_covid_therapeutics>start_date_29&casirivimab_covid_therapeutics>start_date_29, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if (molnupiravir_covid_therapeutics==.|paxlovid_covid_therapeutics==.|molnupiravir_covid_therapeutics>start_date_29|paxlovid_covid_therapeutics>start_date_29)&sotrovimab_covid_therapeutics>start_date_29&remdesivir_covid_therapeutics>start_date_29&casirivimab_covid_therapeutics>start_date_29, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (molnupiravir_covid_therapeutics==.|paxlovid_covid_therapeutics==.|molnupiravir_covid_therapeutics>start_date_29|paxlovid_covid_therapeutics>start_date_29)&sotrovimab_covid_therapeutics>start_date_29&remdesivir_covid_therapeutics>start_date_29&casirivimab_covid_therapeutics>start_date_29, strata(stp)
*excluding patients who were identified to be pregnant at treatment initiation*
*stcox i.drug age i.sex if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if pregnancy!=1, strata(stp)
*additionally adjusting for rural-urban classification, other comorbidities (dementia, autism, learning disabilities, severe mental illness), and care home residency and housebound status *
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.rural_urban_with_missing autism_nhsd care_home_primis dementia_nhsd housebound_opensafely learning_disability_primis serious_mental_illness_nhsd, strata(stp)
*excluding patients who did not have a positive SARS-CoV-2 test record before treatment or initiated treatment after 5 days since positive SARS-CoV-2 test*
tab failure drug if d_postest_treat>=0&d_postest_treat<=5,m col
stcox i.drug age i.sex if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat>=0&d_postest_treat<=5, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*create a 1-day lag in the follow-up start date *
stset end_date ,  origin(start_date) failure(failure==1)
tab failure drug if _t>=2,m col
stcox i.drug age i.sex if _t>=2, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if _t>=2, strata(stp) 
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if _t>=2, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _t>=2, strata(stp)
*create a 2-day lag in the follow-up start date *
tab failure drug if _t>=3,m col
stcox i.drug age i.sex if _t>=3, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if _t>=3, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if _t>=3, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _t>=3, strata(stp)
*use older version of codelist for solid_cancer and immunosupression*
stcox i.drug age i.sex , strata(stp)
stcox i.drug age i.sex  solid_cancer haema_disease   imid immunosupression   rare_neuro  , strata(stp) 
stcox i.drug age i.sex  solid_cancer haema_disease   imid immunosupression   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* , strata(stp)
stcox i.drug age i.sex  solid_cancer haema_disease   imid immunosupression   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
*stratify by stp*
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*exclude missing high_risk_group_new*
stset end_date ,  origin(start_date) failure(failure==1)
tab failure drug if high_risk_group_new==1,m col
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if high_risk_group_new==1, strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if high_risk_group_new==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*exclude 1-year drug interactions*
stset end_date ,  origin(start_date) failure(failure==1)
tab failure drug if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25)),m col
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25)), strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25)), logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

stset end_date ,  origin(start_date) failure(failure==1)
tab failure drug if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25))&(drugs_consider_risk>start_date|drugs_consider_risk<(start_date-365.25)),m col
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25))&(drugs_consider_risk>start_date|drugs_consider_risk<(start_date-365.25)), strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25))&(drugs_consider_risk>start_date|drugs_consider_risk<(start_date-365.25)), logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*ATT weight*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1,_pscore/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*estat phtest,de
*exclude all patients in the non-overlapping parts of the PS distribution*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
sum _pscore if drug==0,de
gen _pscore_mol_min=r(min)
gen _pscore_mol_max=r(max)
sum _pscore if drug==1,de
gen _pscore_pax_min=r(min)
gen _pscore_pax_max=r(max)
stset end_date if (drug==0&_pscore>=_pscore_pax_min&_pscore<=_pscore_pax_max)|(drug==1&_pscore>=_pscore_mol_min&_pscore<=_pscore_mol_max) [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
drop _pscore_mol_min _pscore_mol_max _pscore_pax_min _pscore_pax_max
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*ATE with "Crump" trimming*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date if _pscore>0.05 & _pscore<0.95 [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug 
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
*ATE with "Sturmer" trimming*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
sum _pscore if drug==0,de
gen _pscore_mol_99=r(p99)
sum _pscore if drug==1,de
gen _pscore_pax_1=r(p1)
stset end_date if _pscore>_pscore_pax_1 & _pscore<_pscore_mol_99 [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug 
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
drop _pscore_pax_1 _pscore_mol_99
*ATE with "Sturmer" trimming 2*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
sum _pscore if drug==0,de
gen _pscore_mol_95=r(p95)
sum _pscore if drug==1,de
gen _pscore_pax_5=r(p5)
stset end_date if _pscore>_pscore_pax_5 & _pscore<_pscore_mol_95 [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug 
*psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
*drop psweight
*gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
*sum psweight,de
*by drug, sort: sum _pscore ,de
*stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
*stcox i.drug
*descriptives by PS*
gen ps=0 if _pscore<=_pscore_pax_5
replace ps=1 if _pscore>=_pscore_mol_95
by ps,sort: sum age,de
by ps,sort: sum bmi,de
by ps,sort: sum d_postest_treat ,de
by ps,sort: sum week_after_campaign,de
by ps,sort: sum week_after_vaccinate,de
tab ps sex,row chi
tab ps ethnicity,row chi
tab ps White,row chi
tab ps imd,row chi
tab ps rural_urban,row chi
tab ps region_nhs,row chi
tab stp if ps==0
tab stp if ps==1
tab ps downs_syndrome ,row chi
tab ps solid_cancer_new ,row chi
tab ps haema_disease ,row chi
tab ps renal_disease ,row chi
tab ps liver_disease ,row chi
tab ps imid ,row chi
tab ps immunosupression_new ,row chi
tab ps hiv_aids ,row chi
tab ps solid_organ_new ,row chi
tab ps rare_neuro ,row chi
tab ps autism_nhsd ,row chi
tab ps care_home_primis ,row chi
tab ps dementia_nhsd ,row chi
tab ps housebound_opensafely ,row chi
tab ps learning_disability_primis ,row chi
tab ps serious_mental_illness_nhsd ,row chi
tab ps bmi_g3 ,row chi
tab ps diabetes ,row chi
tab ps chronic_cardiac_disease ,row chi
tab ps hypertension ,row chi
tab ps chronic_respiratory_disease ,row chi
tab ps vaccination_status ,row chi
tab ps pre_infection,row chi
tab ps drugs_consider_risk_contra,row chi
*descriptives by PS and drug*
gen ps_pax=ps if drug==1
gen ps_mol=ps if drug==0
by ps_pax ,sort: sum age,de
by ps_pax,sort: sum bmi,de
by ps_pax,sort: sum d_postest_treat ,de
by ps_pax,sort: sum week_after_campaign,de
by ps_pax,sort: sum week_after_vaccinate,de
tab ps_pax sex,row chi
tab ps_pax ethnicity,row chi
tab ps_pax White,row chi
tab ps_pax imd,row chi
tab ps_pax rural_urban,row chi
tab ps_pax region_nhs,row chi
tab stp if ps_pax==0
tab stp if ps_pax==1
tab ps_pax downs_syndrome ,row chi
tab ps_pax solid_cancer_new ,row chi
tab ps_pax haema_disease ,row chi
tab ps_pax renal_disease ,row chi
tab ps_pax liver_disease ,row chi
tab ps_pax imid ,row chi
tab ps_pax immunosupression_new ,row chi
tab ps_pax hiv_aids ,row chi
tab ps_pax solid_organ_new ,row chi
tab ps_pax rare_neuro ,row chi
tab ps_pax autism_nhsd ,row chi
tab ps_pax care_home_primis ,row chi
tab ps_pax dementia_nhsd ,row chi
tab ps_pax housebound_opensafely ,row chi
tab ps_pax learning_disability_primis ,row chi
tab ps_pax serious_mental_illness_nhsd ,row chi
tab ps_pax bmi_g3 ,row chi
tab ps_pax diabetes ,row chi
tab ps_pax chronic_cardiac_disease ,row chi
tab ps_pax hypertension ,row chi
tab ps_pax chronic_respiratory_disease ,row chi
tab ps_pax vaccination_status ,row chi
tab ps_pax pre_infection,row chi
tab ps_pax drugs_consider_risk_contra,row chi
by ps_mol ,sort: sum age,de
by ps_mol,sort: sum bmi,de
by ps_mol,sort: sum d_postest_treat ,de
by ps_mol,sort: sum week_after_campaign,de
by ps_mol,sort: sum week_after_vaccinate,de
tab ps_mol sex,row chi
tab ps_mol ethnicity,row chi
tab ps_mol White,row chi
tab ps_mol imd,row chi
tab ps_mol rural_urban,row chi
tab ps_mol region_nhs,row chi
tab stp if ps_mol==0
tab stp if ps_mol==1
tab ps_mol downs_syndrome ,row chi
tab ps_mol solid_cancer_new ,row chi
tab ps_mol haema_disease ,row chi
tab ps_mol renal_disease ,row chi
tab ps_mol liver_disease ,row chi
tab ps_mol imid ,row chi
tab ps_mol immunosupression_new ,row chi
tab ps_mol hiv_aids ,row chi
tab ps_mol solid_organ_new ,row chi
tab ps_mol rare_neuro ,row chi
tab ps_mol autism_nhsd ,row chi
tab ps_mol care_home_primis ,row chi
tab ps_mol dementia_nhsd ,row chi
tab ps_mol housebound_opensafely ,row chi
tab ps_mol learning_disability_primis ,row chi
tab ps_mol serious_mental_illness_nhsd ,row chi
tab ps_mol bmi_g3 ,row chi
tab ps_mol diabetes ,row chi
tab ps_mol chronic_cardiac_disease ,row chi
tab ps_mol hypertension ,row chi
tab ps_mol chronic_respiratory_disease ,row chi
tab ps_mol vaccination_status ,row chi
tab ps_mol pre_infection,row chi
tab ps_mol drugs_consider_risk_contra,row chi
drop _pscore_pax_5 _pscore_mol_95 ps ps_pax ps_mol
*ATE additionally adjust for region*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug i.stp
*ATE only age and sex*
psmatch2 drug age i.sex  , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug
stcox i.drug i.stp
*ATE in restricted regions*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if stp==1|stp==2|stp==6|stp==7|stp==9, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox i.drug

*cause-specific analysis*
gen failure_covid=(failure_allcause==1&(covid_hospitalisation_outcome_da==end_date_allcause|death_with_covid_on_the_death_ce==end_date_allcause))
gen failure_other=(failure_allcause==1&(covid_hospitalisation_outcome_da!=end_date_allcause&death_with_covid_on_the_death_ce!=end_date_allcause))
tab failure_covid failure_other,m
stset end_date_allcause ,  origin(start_date) failure(failure_covid==1)
stcox i.drug age i.sex, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline*, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_covid) (drug age i.sex i.stp downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_covid==1)
stcox i.drug

stset end_date_allcause ,  origin(start_date) failure(failure_other==1)
stcox i.drug age i.sex, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro , strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline*, strata(stp)
stcox i.drug age i.sex downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
psmatch2 drug age i.sex i.stp downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure_other) (drug age i.sex i.stp downs_syndrome solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease) if _pscore!=.
*tebalance summarize
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_other==1)
stcox i.drug


*sensitivity analysis-all cause*
stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
*additionally adjusting for days between test positive and treatment initiation, and days/months between last vaccination date and treatment initiation; *
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.d_postest_treat_missing i.month_after_vaccinate_missing, strata(stp)
*excluding patients with treatment records of both mol and Pax, or with treatment records of any other therapies*
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (molnupiravir_covid_therapeutics==.|paxlovid_covid_therapeutics==.|molnupiravir_covid_therapeutics>start_date_29|paxlovid_covid_therapeutics>start_date_29)&sotrovimab_covid_therapeutics>start_date_29&remdesivir_covid_therapeutics>start_date_29&casirivimab_covid_therapeutics>start_date_29, strata(stp)
*excluding patients who were identified to be pregnant at treatment initiation*
*stcox i.drug age i.sex if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if pregnancy!=1, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if pregnancy!=1, strata(stp)
*additionally adjusting for rural-urban classification, other comorbidities (dementia, autism, learning disabilities, severe mental illness), and care home residency and housebound status *
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.rural_urban_with_missing autism_nhsd care_home_primis dementia_nhsd housebound_opensafely learning_disability_primis serious_mental_illness_nhsd, strata(stp)
*excluding patients who did not have a positive SARS-CoV-2 test record before treatment or initiated treatment after 5 days since positive SARS-CoV-2 test*
tab failure_allcause drug if d_postest_treat>=0&d_postest_treat<=5,m col
stcox i.drug age i.sex if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat>=0&d_postest_treat<=5, strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat>=0&d_postest_treat<=5, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*create a 1-day lag in the follow-up start date *
stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
tab failure_allcause drug if _t>=2,m col
stcox i.drug age i.sex if _t>=2, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if _t>=2, strata(stp) 
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if _t>=2, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _t>=2, strata(stp)
*create a 2-day lag in the follow-up start date *
tab failure_allcause drug if _t>=3,m col
stcox i.drug age i.sex if _t>=3, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  if _t>=3, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* if _t>=3, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _t>=3, strata(stp)
*use older version of codelist for solid_cancer and immunosupression*
stcox i.drug age i.sex , strata(stp)
stcox i.drug age i.sex  solid_cancer haema_disease   imid immunosupression   rare_neuro  , strata(stp) 
stcox i.drug age i.sex  solid_cancer haema_disease   imid immunosupression   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* , strata(stp)
stcox i.drug age i.sex  solid_cancer haema_disease   imid immunosupression   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
*stratify by stp*
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*exclude missing high_risk_group_new*
stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
tab failure_allcause drug if high_risk_group_new==1,m col
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if high_risk_group_new==1, strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if high_risk_group_new==1, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*exclude 1-year drug interactions*
stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
tab failure_allcause drug if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25)),m col
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25)), strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25)), logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug

stset end_date_allcause ,  origin(start_date) failure(failure_allcause==1)
tab failure_allcause drug if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25))&(drugs_consider_risk>start_date|drugs_consider_risk<(start_date-365.25)),m col
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25))&(drugs_consider_risk>start_date|drugs_consider_risk<(start_date-365.25)), strata(stp)
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if (drugs_do_not_use>start_date|drugs_do_not_use<(start_date-365.25))&(drugs_consider_risk>start_date|drugs_consider_risk<(start_date-365.25)), logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*ATT weight*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, logit
drop psweight
gen psweight=cond( drug ==1,1,_pscore/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*estat phtest,de
*exclude all patients in the non-overlapping parts of the PS distribution*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit common
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
sum _pscore if drug==0,de
gen _pscore_mol_min=r(min)
gen _pscore_mol_max=r(max)
sum _pscore if drug==1,de
gen _pscore_pax_min=r(min)
gen _pscore_pax_max=r(max)
stset end_date_allcause if (drug==0&_pscore>=_pscore_pax_min&_pscore<=_pscore_pax_max)|(drug==1&_pscore>=_pscore_mol_min&_pscore<=_pscore_mol_max) [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
drop _pscore_mol_min _pscore_mol_max _pscore_pax_min _pscore_pax_max
*ATE with "Crump" trimming*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause if _pscore>0.05 & _pscore<0.95 [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug 
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
*ATE with "Sturmer" trimming*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
sum _pscore if drug==0,de
gen _pscore_mol_99=r(p99)
sum _pscore if drug==1,de
gen _pscore_pax_1=r(p1)
stset end_date_allcause if _pscore>_pscore_pax_1 & _pscore<_pscore_mol_99 [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug 
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
drop _pscore_pax_1 _pscore_mol_99
*ATE with "Sturmer" trimming 2*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
sum _pscore if drug==0,de
gen _pscore_mol_95=r(p95)
sum _pscore if drug==1,de
gen _pscore_pax_5=r(p5)
stset end_date_allcause if _pscore>_pscore_pax_5 & _pscore<_pscore_mol_95 [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug 
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if _st==1, logit 
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug
drop _pscore_pax_5 _pscore_mol_95
*ATE additionally adjust for region*
psmatch2 drug age i.sex i.stp  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date_allcause [pwei=psweight],  origin(start_date) failure(failure_allcause==1)
stcox i.drug i.stp



*subgroup analysis*
stset end_date ,  origin(start_date) failure(failure==1)
stcox i.drug##i.sex age  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if sex==0, strata(stp)
stcox i.drug age  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if sex==1, strata(stp)

stcox i.drug##i.age_group3 i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)

stcox i.drug##i.age_50 i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)

stcox i.drug##i.age_55 i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_55==0, strata(stp)
stcox i.drug i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_55==1, strata(stp)

stcox i.drug##i.age_60 i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_60==0, strata(stp)
stcox i.drug i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if age_60==1, strata(stp)

stcox i.drug##i.White age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if White==1, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if White==0, strata(stp)

stcox i.drug##i.solid_cancer_new age i.sex   haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex   haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if solid_cancer_new==1, strata(stp)
stcox i.drug age i.sex   haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if solid_cancer_new==0, strata(stp)
stcox i.drug##i.haema_disease age i.sex  solid_cancer_new    imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new    imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if haema_disease==1, strata(stp)
stcox i.drug age i.sex  solid_cancer_new    imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if haema_disease==0, strata(stp)
stcox i.drug##i.imid age i.sex  solid_cancer_new haema_disease    immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease    immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if imid==1, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease    immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if imid==0, strata(stp)
stcox i.drug##i.immunosupression_new age i.sex  solid_cancer_new haema_disease   imid   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if immunosupression_new==1, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if immunosupression_new==0, strata(stp)
stcox i.drug##i.rare_neuro age i.sex  solid_cancer_new haema_disease   imid immunosupression_new    b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease , strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new    b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if rare_neuro==0, strata(stp)

stcox i.drug##i.bmi_g3 age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_g3==1, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_g3==2, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_g3==3, strata(stp)

stcox i.drug##i.bmi_25 age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_25==0, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_25==1, strata(stp)

stcox i.drug##i.bmi_30 age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline*  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_30==0, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if bmi_30==1, strata(stp)

stcox i.drug##i.diabetes age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing  chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing chronic_cardiac_disease hypertension chronic_respiratory_disease if diabetes ==0, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing chronic_cardiac_disease hypertension chronic_respiratory_disease if diabetes ==1, strata(stp)

stcox i.drug##i.chronic_cardiac_disease age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes  hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes  hypertension chronic_respiratory_disease if chronic_cardiac_disease==0, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes  hypertension chronic_respiratory_disease if chronic_cardiac_disease==1, strata(stp)

stcox i.drug##i.hypertension age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease if hypertension==0, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease  chronic_respiratory_disease if hypertension==1, strata(stp)

stcox i.drug##i.chronic_respiratory_disease age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension , strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension if chronic_respiratory_disease==0, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension if chronic_respiratory_disease==1, strata(stp)

stcox i.drug##i.vaccination_g3 age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing  calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing  calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_g3==1, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing  calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_g3==2, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing  calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_3==0, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing  calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if vaccination_status==0, strata(stp)

stcox i.drug##i.d_postest_treat_g2 age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease, strata(stp)
stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat_g2==0, strata(stp)
*stcox i.drug age i.sex  solid_cancer_new haema_disease   imid immunosupression_new   rare_neuro  b1.White_with_missing b5.imd_with_missing i.vaccination_g3 calendar_day_spline* b1.bmi_g3_with_missing diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease if d_postest_treat_g2==1, strata(stp)

*use minimal-adjusted model*
stcox i.drug##i.sex age , strata(stp)
stcox i.drug age if sex==0, strata(stp)
stcox i.drug age if sex==1, strata(stp)

stcox i.drug##i.age_group3 i.sex , strata(stp)
stcox i.drug i.sex  if age_group3==0, strata(stp)
stcox i.drug i.sex if age_group3==1, strata(stp)
stcox i.drug i.sex if age_group3==2, strata(stp)

stcox i.drug##i.age_50 i.sex , strata(stp)
stcox i.drug i.sex  if age_50==0, strata(stp)
stcox i.drug i.sex  if age_50==1, strata(stp)

stcox i.drug##i.age_55 i.sex , strata(stp)
stcox i.drug i.sex  if age_55==0, strata(stp)
stcox i.drug i.sex if age_55==1, strata(stp)

stcox i.drug##i.age_60 i.sex , strata(stp)
stcox i.drug i.sex if age_60==0, strata(stp)
stcox i.drug i.sex if age_60==1, strata(stp)

stcox i.drug##i.White age i.sex , strata(stp)
stcox i.drug age i.sex if White==1, strata(stp)
stcox i.drug age i.sex if White==0, strata(stp)

stcox i.drug##i.solid_cancer_new age i.sex , strata(stp)
stcox i.drug age i.sex if solid_cancer_new==1, strata(stp)
stcox i.drug age i.sex if solid_cancer_new==0, strata(stp)
stcox i.drug##i.haema_disease age i.sex , strata(stp)
stcox i.drug age i.sex if haema_disease==1, strata(stp)
stcox i.drug age i.sex if haema_disease==0, strata(stp)
stcox i.drug##i.imid age i.sex , strata(stp)
stcox i.drug age i.sex  if imid==1, strata(stp)
stcox i.drug age i.sex  if imid==0, strata(stp)
stcox i.drug##i.immunosupression_new age i.sex , strata(stp)
stcox i.drug##i.rare_neuro age i.sex , strata(stp)

stcox i.drug##i.bmi_g3 age i.sex , strata(stp)
stcox i.drug age i.sex  if bmi_g3==1, strata(stp)
stcox i.drug age i.sex if bmi_g3==2, strata(stp)
stcox i.drug age i.sex if bmi_g3==3, strata(stp)

stcox i.drug##i.bmi_25 age i.sex , strata(stp)
stcox i.drug age i.sex if bmi_25==0, strata(stp)
stcox i.drug age i.sex if bmi_25==1, strata(stp)

stcox i.drug##i.bmi_30 age i.sex , strata(stp)
stcox i.drug age i.sex if bmi_30==0, strata(stp)
stcox i.drug age i.sex if bmi_30==1, strata(stp)

stcox i.drug##i.diabetes age i.sex , strata(stp)
stcox i.drug age i.sex if diabetes ==0, strata(stp)
stcox i.drug age i.sex if diabetes ==1, strata(stp)

stcox i.drug##i.chronic_cardiac_disease age i.sex , strata(stp)
stcox i.drug age i.sex  if chronic_cardiac_disease==0, strata(stp)
stcox i.drug age i.sex  if chronic_cardiac_disease==1, strata(stp)

stcox i.drug##i.hypertension age i.sex , strata(stp)
stcox i.drug age i.sex if hypertension==0, strata(stp)
stcox i.drug age i.sex  if hypertension==1, strata(stp)

stcox i.drug##i.chronic_respiratory_disease age i.sex  , strata(stp)
stcox i.drug age i.sex  if chronic_respiratory_disease==0, strata(stp)
stcox i.drug age i.sex  if chronic_respiratory_disease==1, strata(stp)

stcox i.drug##i.vaccination_g3 age i.sex , strata(stp)
stcox i.drug age i.sex  if vaccination_g3==1, strata(stp)
stcox i.drug age i.sex  if vaccination_g3==2, strata(stp)
*stcox i.drug age i.sex  if vaccination_3==0, strata(stp)
*stcox i.drug age i.sex if vaccination_status==0, strata(stp)

stcox i.drug##i.d_postest_treat_g2 age i.sex , strata(stp)
stcox i.drug age i.sex if d_postest_treat_g2==0, strata(stp)
stcox i.drug age i.sex if d_postest_treat_g2==1, strata(stp)



*safety outcome*
*death not due to covid*
by drug, sort: count if death_date!=.
by drug, sort: count if death_with_covid_on_the_death_ce!=.
by drug, sort: count if death_with_covid_on_the_death_ce==.&death_date!=.
gen death_without_covid=death_date if death_with_covid_on_the_death_ce==.&death_date!=.

log close
