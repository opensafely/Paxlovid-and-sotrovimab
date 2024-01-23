********************************************************************************
*
*	Do-file:		data_preparation_and_descriptives.do
*
*	Project:		sotrovimab-and-Paxlovid
*
*	Programmed by:	Bang Zheng
*
*	Data used:		output/input.csv
*
*	Data created:	output/main.dta  (main analysis dataset)
*
*	Other output:	logs/data_preparation.log
*
********************************************************************************
*
*	Purpose: This do-file creates the variables required for the 
*			 main analysis and saves into Stata dataset, and describes 
*            variables by drug groups.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/data_preparation_feasibility, replace t
clear

* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
*describe
keep if covid_test_positive_date!=""
*  Convert strings to dates  *
foreach var of varlist     covid_test_positive_date covid_test_positive_date2 covid_hosp_not_pri_admission covid_hosp_not_pri_admission2 covid_hosp_admission covid_hosp_admission2 ///
		sotrovimab_GP paxlovid_GP molnupiravir_GP remdesivir_GP ///
		date_treated_GP sotrovimab_covid_therapeutics_o paxlovid_covid_therapeutics_o molnupiravir_covid_therapeutics_ remdesivir_covid_therapeutics_o casirivimab_covid_therapeutics_o ///
		date_treated_out death_with_covid_date death_date all_hosp_admission all_hosp_admission2 date_treated date_treated_hosp {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f de
  }
}

gen infect_month=month(covid_test_positive_date)
tab infect_month
gen infect_month2=month(covid_test_positive_date2)
tab infect_month2
tab region_nhs,m
tab region_nhs infect_month, row
tab region_nhs infect_month2, row
tab stp,m
tab stp infect_month, row
tab stp infect_month2, row

gen sotro_month_o=month(sotrovimab_covid_therapeutics_o)
gen pax_month_o=month(paxlovid_covid_therapeutics_o)
gen mol_month_o=month(molnupiravir_covid_therapeutics_)
gen rem_month_o=month(remdesivir_covid_therapeutics_o)
gen treated_month_o=month(date_treated_out)
tab sotro_month_o
tab pax_month_o
tab mol_month_o
tab rem_month_o
tab treated_month_o
tab region_nhs sotro_month_o, row
tab region_nhs pax_month_o, row
tab region_nhs mol_month_o, row
tab region_nhs rem_month_o, row
tab region_nhs treated_month_o, row
tab stp treated_month_o,row

gen sotro_month_GP=month(sotrovimab_GP)
gen pax_month_GP=month(paxlovid_GP)
gen mol_month_GP=month(molnupiravir_GP)
gen rem_month_GP=month(remdesivir_GP)
gen treated_month_GP=month(date_treated_GP)
tab sotro_month_GP
tab pax_month_GP
tab mol_month_GP
tab rem_month_GP
tab treated_month_GP
tab region_nhs sotro_month_GP, row
tab region_nhs pax_month_GP, row
tab region_nhs mol_month_GP, row
tab region_nhs rem_month_GP, row
tab region_nhs treated_month_GP, row
tab stp treated_month_GP,row

gen sotro_month=min(sotro_month_o,sotro_month_GP)
gen pax_month=min(pax_month_o,pax_month_GP)
gen mol_month=min(mol_month_o,mol_month_GP)
gen rem_month=min(rem_month_o,rem_month_GP)
gen treated_month=min(treated_month_o,treated_month_GP)
tab sotro_month
tab pax_month
tab mol_month
tab rem_month
tab treated_month
tab region_nhs sotro_month, row
tab region_nhs pax_month, row
tab region_nhs mol_month, row
tab region_nhs rem_month, row
tab region_nhs treated_month, row
tab stp treated_month,row

gen covid_hosp_not_pri_month=month(covid_hosp_not_pri_admission)
tab covid_hosp_not_pri_month
tab region_nhs covid_hosp_not_pri_month,row
tab stp covid_hosp_not_pri_month,row
gen covid_hosp_month=month(covid_hosp_admission)
tab covid_hosp_month
tab region_nhs covid_hosp_month,row
tab stp covid_hosp_month,row
gen all_hosp_admission_month=month(all_hosp_admission)
tab all_hosp_admission_month
tab region_nhs all_hosp_admission_month,row
tab stp all_hosp_admission_month,row
gen all_hosp_admission_month2=month(all_hosp_admission2)
tab all_hosp_admission_month2
tab region_nhs all_hosp_admission_month2,row
tab stp all_hosp_admission_month2,row

gen death_with_covid_month=month(death_with_covid_date)
tab death_with_covid_month
tab region_nhs death_with_covid_month,row
tab stp death_with_covid_month,row

gen death_month=month(death_date)
tab death_month
tab region_nhs death_month,row
tab stp death_month,row


clear

* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
*describe
keep if date_treated_GP!="" | date_treated_out!=""
*  Convert strings to dates  *
foreach var of varlist      covid_test_positive_date covid_test_positive_date2 	sotrovimab_GP paxlovid_GP molnupiravir_GP remdesivir_GP ///
		date_treated_GP sotrovimab_covid_therapeutics_o paxlovid_covid_therapeutics_o molnupiravir_covid_therapeutics_ remdesivir_covid_therapeutics_o casirivimab_covid_therapeutics_o ///
		date_treated_out {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f de
  }
}
gen infect_month=month(covid_test_positive_date)
tab infect_month
gen infect_month2=month(covid_test_positive_date2)
tab infect_month2
tab region_nhs,m
tab region_nhs infect_month, row
tab region_nhs infect_month2, row
tab stp,m
tab stp infect_month, row
tab stp infect_month2, row

gen sotro_month_o=month(sotrovimab_covid_therapeutics_o)
gen pax_month_o=month(paxlovid_covid_therapeutics_o)
gen mol_month_o=month(molnupiravir_covid_therapeutics_)
gen rem_month_o=month(remdesivir_covid_therapeutics_o)
gen treated_month_o=month(date_treated_out)
tab sotro_month_o
tab pax_month_o
tab mol_month_o
tab rem_month_o
tab treated_month_o
tab region_nhs sotro_month_o, row
tab region_nhs pax_month_o, row
tab region_nhs mol_month_o, row
tab region_nhs rem_month_o, row
tab region_nhs treated_month_o, row
tab stp treated_month_o,row

gen sotro_month_GP=month(sotrovimab_GP)
gen pax_month_GP=month(paxlovid_GP)
gen mol_month_GP=month(molnupiravir_GP)
gen rem_month_GP=month(remdesivir_GP)
gen treated_month_GP=month(date_treated_GP)
tab sotro_month_GP
tab pax_month_GP
tab mol_month_GP
tab rem_month_GP
tab treated_month_GP
tab region_nhs sotro_month_GP, row
tab region_nhs pax_month_GP, row
tab region_nhs mol_month_GP, row
tab region_nhs rem_month_GP, row
tab region_nhs treated_month_GP, row
tab stp treated_month_GP,row

gen sotro_month=min(sotro_month_o,sotro_month_GP)
gen pax_month=min(pax_month_o,pax_month_GP)
gen mol_month=min(mol_month_o,mol_month_GP)
gen rem_month=min(rem_month_o,rem_month_GP)
gen treated_month=min(treated_month_o,treated_month_GP)
tab sotro_month
tab pax_month
tab mol_month
tab rem_month
tab treated_month
tab region_nhs sotro_month, row
tab region_nhs pax_month, row
tab region_nhs mol_month, row
tab region_nhs rem_month, row
tab region_nhs treated_month, row
tab stp treated_month,row

by treated_month, sort: count if infect_month==treated_month|infect_month==(treated_month-1)

clear

* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
*describe
keep if date_treated!="" | date_treated_hosp!=""
*  Convert strings to dates  *
foreach var of varlist		date_treated date_treated_hosp {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f de
  }
}

gen treated_month=month(date_treated)
tab treated_month
tab region_nhs treated_month, row
tab stp treated_month,row

gen treated_month_hosp=month(date_treated_hosp)
tab treated_month_hosp
tab region_nhs treated_month_hosp, row
tab stp treated_month_hosp,row

clear


* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
*describe
keep if all_hosp_admission!=""
*  Convert strings to dates  *
foreach var of varlist      covid_test_positive_date covid_test_positive_date2 covid_hosp_not_pri_admission covid_hosp_not_pri_admission2 covid_hosp_admission covid_hosp_admission2 ///
		 all_hosp_admission all_hosp_admission2 {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f de
  }
}

gen covid_hosp_not_pri_month=month(covid_hosp_not_pri_admission)
tab covid_hosp_not_pri_month
tab region_nhs covid_hosp_not_pri_month,row
tab stp covid_hosp_not_pri_month,row
gen covid_hosp_month=month(covid_hosp_admission)
tab covid_hosp_month
tab region_nhs covid_hosp_month,row
tab stp covid_hosp_month,row
gen all_hosp_admission_month=month(all_hosp_admission)
tab all_hosp_admission_month
tab region_nhs all_hosp_admission_month,row
tab stp all_hosp_admission_month,row
gen all_hosp_admission_month2=month(all_hosp_admission2)
tab all_hosp_admission_month2
tab region_nhs all_hosp_admission_month2,row
tab stp all_hosp_admission_month2,row

gen infect_month=month(covid_test_positive_date)
by covid_hosp_not_pri_month, sort: count if infect_month==covid_hosp_not_pri_month|infect_month==(covid_hosp_not_pri_month-1)


clear

* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
*describe
keep if death_date!=""
*  Convert strings to dates  *
foreach var of varlist  death_with_covid_date death_date  {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f de
  }
}

gen death_with_covid_month=month(death_with_covid_date)
tab death_with_covid_month
tab region_nhs death_with_covid_month,row
tab stp death_with_covid_month,row

gen death_month=month(death_date)
tab death_month
tab region_nhs death_month,row
tab stp death_month,row



clear

*high-risk cohort*
* import dataset
import delimited ./output/input_feasibility.csv, delimiter(comma) varnames(1) case(preserve) 
drop if cancer_opensafely_snomed_new==""&immunosuppresant_drugs_nhsd==""&oral_steroid_drugs_nhsd==""&immunosupression_nhsd_new==""&solid_organ_transplant_nhsd_new==""&downs_syndrome_nhsd==""&haematological_disease_nhsd==""&ckd_stage_5_nhsd==""&liver_disease_nhsd==""&hiv_aids_nhsd==""&multiple_sclerosis_nhsd==""&motor_neurone_disease_nhsd==""&myasthenia_gravis_nhsd==""&huntingtons_disease_nhsd=="" 

foreach var of varlist covid_test_positive_date covid_test_positive_date2 covid_hosp_not_pri_admission covid_hosp_not_pri_admission2 covid_hosp_admission covid_hosp_admission2 ///
		sotrovimab_GP paxlovid_GP molnupiravir_GP remdesivir_GP ///
		date_treated_GP sotrovimab_covid_therapeutics_o paxlovid_covid_therapeutics_o molnupiravir_covid_therapeutics_ remdesivir_covid_therapeutics_o casirivimab_covid_therapeutics_o ///
		date_treated_out death_with_covid_date death_date all_hosp_admission all_hosp_admission2 date_treated date_treated_hosp   ///
	   cancer_opensafely_snomed_new   immunosuppresant_drugs_nhsd ///
	   oral_steroid_drugs_nhsd  immunosupression_nhsd_new   solid_organ_transplant_nhsd_new  haematological_malignancies_snom haematological_malignancies_icd1 ///
	   downs_syndrome_nhsd haematological_disease_nhsd ckd_stage_5_nhsd liver_disease_nhsd hiv_aids_nhsd  ///
	   multiple_sclerosis_nhsd motor_neurone_disease_nhsd myasthenia_gravis_nhsd huntingtons_disease_nhsd  liver_disease_nhsd_icd10  {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  }
}

*10 high risk groups: downs_syndrome, solid_cancer, haematological_disease, renal_disease, liver_disease, imid, 
*immunosupression, hiv_aids, solid_organ_transplant, rare_neurological_conditions, high_risk_group_combined	
replace oral_steroid_drugs_nhsd=. if oral_steroid_drug_nhsd_3m_count < 2 & oral_steroid_drug_nhsd_12m_count < 4
gen imid_nhsd=min(oral_steroid_drugs_nhsd, immunosuppresant_drugs_nhsd)
gen rare_neuro_nhsd = min(multiple_sclerosis_nhsd, motor_neurone_disease_nhsd, myasthenia_gravis_nhsd, huntingtons_disease_nhsd)
*high risk group only based on codelists*
gen downs_syndrome=(downs_syndrome_nhsd!=.)
gen solid_cancer_new=(cancer_opensafely_snomed_new!=.)
tab solid_cancer_new
gen haema_disease=( haematological_disease_nhsd !=.)
tab haema_disease
gen renal_disease=( ckd_stage_5_nhsd !=.)
gen liver_disease=( liver_disease_nhsd !=.)
gen imid=( imid_nhsd !=.)
tab imid
gen immunosupression_new=( immunosupression_nhsd_new!=.)
tab immunosupression_new
gen hiv_aids=( hiv_aids_nhsd !=.)
tab hiv_aids
gen solid_organ_new=( solid_organ_transplant_nhsd_new!=.)
tab solid_organ_new
gen rare_neuro=( rare_neuro_nhsd !=.)
gen high_risk_group_new=(( downs_syndrome + solid_cancer_new + haema_disease + renal_disease + liver_disease + imid + immunosupression_new + hiv_aids + solid_organ_new + rare_neuro )>0)
tab high_risk_group_new,m
keep if high_risk_group_new==1
count 


gen infect_month=month(covid_test_positive_date)
tab infect_month
gen infect_month2=month(covid_test_positive_date2)
tab infect_month2
tab region_nhs,m
tab region_nhs infect_month, row
tab region_nhs infect_month2, row
tab stp,m
tab stp infect_month, row
tab stp infect_month2, row

gen sotro_month_o=month(sotrovimab_covid_therapeutics_o)
gen pax_month_o=month(paxlovid_covid_therapeutics_o)
gen mol_month_o=month(molnupiravir_covid_therapeutics_)
gen rem_month_o=month(remdesivir_covid_therapeutics_o)
gen treated_month_o=month(date_treated_out)
tab sotro_month_o
tab pax_month_o
tab mol_month_o
tab rem_month_o
tab treated_month_o
tab region_nhs sotro_month_o, row
tab region_nhs pax_month_o, row
tab region_nhs mol_month_o, row
tab region_nhs rem_month_o, row
tab region_nhs treated_month_o, row
tab stp treated_month_o,row

gen sotro_month_GP=month(sotrovimab_GP)
gen pax_month_GP=month(paxlovid_GP)
gen mol_month_GP=month(molnupiravir_GP)
gen rem_month_GP=month(remdesivir_GP)
gen treated_month_GP=month(date_treated_GP)
tab sotro_month_GP
tab pax_month_GP
tab mol_month_GP
tab rem_month_GP
tab treated_month_GP
tab region_nhs sotro_month_GP, row
tab region_nhs pax_month_GP, row
tab region_nhs mol_month_GP, row
tab region_nhs rem_month_GP, row
tab region_nhs treated_month_GP, row
tab stp treated_month_GP,row

gen sotro_month=min(sotro_month_o,sotro_month_GP)
gen pax_month=min(pax_month_o,pax_month_GP)
gen mol_month=min(mol_month_o,mol_month_GP)
gen rem_month=min(rem_month_o,rem_month_GP)
gen treated_month=min(treated_month_o,treated_month_GP)
tab sotro_month
tab pax_month
tab mol_month
tab rem_month
tab treated_month
tab region_nhs sotro_month, row
tab region_nhs pax_month, row
tab region_nhs mol_month, row
tab region_nhs rem_month, row
tab region_nhs treated_month, row
tab stp treated_month,row

gen covid_hosp_not_pri_month=month(covid_hosp_not_pri_admission)
tab covid_hosp_not_pri_month
tab region_nhs covid_hosp_not_pri_month,row
tab stp covid_hosp_not_pri_month,row
gen covid_hosp_month=month(covid_hosp_admission)
tab covid_hosp_month
tab region_nhs covid_hosp_month,row
tab stp covid_hosp_month,row
gen all_hosp_admission_month=month(all_hosp_admission)
tab all_hosp_admission_month
tab region_nhs all_hosp_admission_month,row
tab stp all_hosp_admission_month,row
gen all_hosp_admission_month2=month(all_hosp_admission2)
tab all_hosp_admission_month2
tab region_nhs all_hosp_admission_month2,row
tab stp all_hosp_admission_month2,row

gen death_with_covid_month=month(death_with_covid_date)
tab death_with_covid_month
tab region_nhs death_with_covid_month,row
tab stp death_with_covid_month,row

gen death_month=month(death_date)
tab death_month
tab region_nhs death_month,row
tab stp death_month,row

gen treated_month_onset=month(date_treated)
tab treated_month_onset
tab region_nhs treated_month_onset, row
tab stp treated_month_onset,row

gen treated_month_hosp=month(date_treated_hosp)
tab treated_month_hosp
tab region_nhs treated_month_hosp, row
tab stp treated_month_hosp,row



log close
exit, clear









*codebook
keep if date_treated!=""|date_treated_hosp!=""|all_hosp_admission!=""

*  Convert strings to dates  *
foreach var of varlist  sotrovimab_covid_therapeutics molnupiravir_covid_therapeutics paxlovid_covid_therapeutics remdesivir_covid_therapeutics	///
        casirivimab_covid_therapeutics tocilizumab_covid_therapeutics sarilumab_covid_therapeutics baricitinib_covid_hosp date_treated  ///
        sotrovimab_covid_hosp paxlovid_covid_hosp molnupiravir_covid_hosp remdesivir_covid_hosp casirivimab_covid_hosp tocilizumab_covid_hosp sarilumab_covid_hosp ///
		date_treated_hosp start_date death_with_covid_date death_with_covid_underly_date death_date covid_hosp_not_pri_admission covid_hosp_not_pri_discharge ///
		covid_hosp_not_pri_admission2 covid_hosp_not_pri_discharge2 covid_hosp_admission covid_hosp_discharge covid_hosp_admission2 covid_hosp_discharge2 ///
		all_hosp_admission all_hosp_discharge all_hosp_admission2 all_hosp_discharge2 all_hosp_admission_onset covid_hosp_admission_onset covid_hosp_not_pri_onset ///
		all_hosp_admission_hosp covid_hosp_admission_hosp covid_hosp_not_pri_hosp covid_test_positive_date covid_test_positive_date2 covid_test_positive_onset ///
		covid_test_positive_hosp covid_test_positive_all_hosp covid_test_positive_all_hosp2 covid_test_positive_covid_hosp covid_test_positive_covid_hosp2 ///
		covid_test_positive_not_pri covid_test_positive_not_pri2 {
  capture confirm string variable `var'
  if _rc==0 {
  rename `var' a
  gen `var' = date(a, "YMD")
  drop a
  format %td `var'
  sum `var',f
  }
}

tab covid_therapeutics
tab registered_treated
tab covid_therapeutics_hosp
tab registered_treated_hosp
tab covid_therapeutics if date_treated>=mdy(12,16,2021)
tab covid_therapeutics_hosp if date_treated_hosp>=mdy(12,16,2021)

tab high_risk_cohort_covid_therapeut
tab high_risk_cohort_covid_therapeut if covid_therapeutics!=""
tab high_risk_cohort_covid_therapeut if covid_therapeutics_hosp!=""

*check hosp records*
gen treated_onset=(date_treated!=.)
gen treated_hosp=(date_treated_hosp!=.)
count if treated_onset==1&((date_treated>=covid_hosp_not_pri_admission&date_treated<=covid_hosp_not_pri_discharge)|(date_treated>=covid_hosp_not_pri_admission2&date_treated<=covid_hosp_not_pri_discharge2))
count if treated_onset==1&((date_treated>=covid_hosp_admission&date_treated<=covid_hosp_discharge)|(date_treated>=covid_hosp_admission2&date_treated<=covid_hosp_discharge2))
count if treated_onset==1&((date_treated>=all_hosp_admission&date_treated<=all_hosp_discharge)|(date_treated>=all_hosp_admission2&date_treated<=all_hosp_discharge2))
count if treated_onset==1&(((date_treated+1)>=covid_hosp_not_pri_admission&(date_treated-1)<=covid_hosp_not_pri_discharge)|((date_treated+1)>=covid_hosp_not_pri_admission2&(date_treated-1)<=covid_hosp_not_pri_discharge2))
count if treated_onset==1&(((date_treated+3)>=covid_hosp_not_pri_admission&(date_treated-3)<=covid_hosp_not_pri_discharge)|((date_treated+3)>=covid_hosp_not_pri_admission2&(date_treated-3)<=covid_hosp_not_pri_discharge2))
count if treated_onset==1&(((date_treated+1)>=covid_hosp_admission&(date_treated-1)<=covid_hosp_discharge)|((date_treated+1)>=covid_hosp_admission2&(date_treated-1)<=covid_hosp_discharge2))
count if treated_onset==1&(((date_treated+3)>=covid_hosp_admission&(date_treated-3)<=covid_hosp_discharge)|((date_treated+3)>=covid_hosp_admission2&(date_treated-3)<=covid_hosp_discharge2))
count if treated_onset==1&all_hosp_admission_onset!=.
count if treated_onset==1&covid_hosp_admission_onset!=.
count if treated_onset==1&covid_hosp_not_pri_onset!=.
count if treated_hosp==1&((date_treated_hosp>=covid_hosp_not_pri_admission&date_treated_hosp<=covid_hosp_not_pri_discharge)|(date_treated_hosp>=covid_hosp_not_pri_admission2&date_treated_hosp<=covid_hosp_not_pri_discharge2))
count if treated_hosp==1&((date_treated_hosp>=covid_hosp_admission&date_treated_hosp<=covid_hosp_discharge)|(date_treated_hosp>=covid_hosp_admission2&date_treated_hosp<=covid_hosp_discharge2))
count if treated_hosp==1&((date_treated_hosp>=all_hosp_admission&date_treated_hosp<=all_hosp_discharge)|(date_treated_hosp>=all_hosp_admission2&date_treated_hosp<=all_hosp_discharge2))
count if treated_hosp==1&(((date_treated_hosp+1)>=covid_hosp_not_pri_admission&(date_treated_hosp-1)<=covid_hosp_not_pri_discharge)|((date_treated_hosp+1)>=covid_hosp_not_pri_admission2&(date_treated_hosp-1)<=covid_hosp_not_pri_discharge2))
count if treated_hosp==1&(((date_treated_hosp+3)>=covid_hosp_not_pri_admission&(date_treated_hosp-3)<=covid_hosp_not_pri_discharge)|((date_treated_hosp+3)>=covid_hosp_not_pri_admission2&(date_treated_hosp-3)<=covid_hosp_not_pri_discharge2))
count if treated_hosp==1&(((date_treated_hosp+1)>=covid_hosp_admission&(date_treated_hosp-1)<=covid_hosp_discharge)|((date_treated_hosp+1)>=covid_hosp_admission2&(date_treated_hosp-1)<=covid_hosp_discharge2))
count if treated_hosp==1&(((date_treated_hosp+3)>=covid_hosp_admission&(date_treated_hosp-3)<=covid_hosp_discharge)|((date_treated_hosp+3)>=covid_hosp_admission2&(date_treated_hosp-3)<=covid_hosp_discharge2))
count if treated_hosp==1&all_hosp_admission_hosp!=.
count if treated_hosp==1&covid_hosp_admission_hosp!=.
count if treated_hosp==1&covid_hosp_not_pri_hosp!=.
*check covid test*
count if treated_onset==1&covid_test_positive_onset!=.
count if treated_hosp==1&covid_test_positive_hosp!=.

*distinguish onset and hosp*
tab treated_onset if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge&covid_test_positive_not_pri>covid_hosp_not_pri_admission)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2&covid_test_positive_not_pri2>covid_hosp_not_pri_admission2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge&covid_test_positive_covid_hosp>covid_hosp_admission)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2&covid_test_positive_covid_hosp2>covid_hosp_admission2))
tab treated_onset if start_date!=.&((start_date>=all_hosp_admission&start_date<=all_hosp_discharge&covid_test_positive_all_hosp>all_hosp_admission)|(start_date>=all_hosp_admission2&start_date<=all_hosp_discharge2&covid_test_positive_all_hosp2>all_hosp_admission2))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge&covid_test_positive_not_pri>covid_hosp_not_pri_admission&covid_test_positive_not_pri!=.)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2&covid_test_positive_not_pri2>covid_hosp_not_pri_admission2&covid_test_positive_not_pri2!=.))
tab treated_onset if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge&covid_test_positive_covid_hosp>covid_hosp_admission&covid_test_positive_covid_hosp!=.)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2&covid_test_positive_covid_hosp2>covid_hosp_admission2&covid_test_positive_covid_hosp2!=.))
tab treated_onset if start_date!=.&((start_date>=all_hosp_admission&start_date<=all_hosp_discharge&covid_test_positive_all_hosp>all_hosp_admission&covid_test_positive_all_hosp!=.)|(start_date>=all_hosp_admission2&start_date<=all_hosp_discharge2&covid_test_positive_all_hosp2>all_hosp_admission2&covid_test_positive_all_hosp2!=.))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_not_pri_admission&start_date<=covid_hosp_not_pri_discharge&covid_test_positive_not_pri<=covid_hosp_not_pri_admission)|(start_date>=covid_hosp_not_pri_admission2&start_date<=covid_hosp_not_pri_discharge2&covid_test_positive_not_pri2<=covid_hosp_not_pri_admission2))
tab treated_hosp if start_date!=.&((start_date>=covid_hosp_admission&start_date<=covid_hosp_discharge&covid_test_positive_covid_hosp<=covid_hosp_admission)|(start_date>=covid_hosp_admission2&start_date<=covid_hosp_discharge2&covid_test_positive_covid_hosp2<=covid_hosp_admission2))
tab treated_hosp if start_date!=.&((start_date>=all_hosp_admission&start_date<=all_hosp_discharge&covid_test_positive_all_hosp<=all_hosp_admission)|(start_date>=all_hosp_admission2&start_date<=all_hosp_discharge2&covid_test_positive_all_hosp2<=all_hosp_admission2))



count  if tocilizumab_covid_hosp!=.&death_with_covid_date!=.
count  if sarilumab_covid_hosp!=.&death_with_covid_date!=.
count  if tocilizumab_covid_hosp!=.&death_date!=.
count  if sarilumab_covid_hosp!=.&death_date!=.




*check hosp/death event date range*
*codebook covid_hosp_outcome_date2 hospitalisation_outcome_date2 death_date

*exclusion criteria*

log close




