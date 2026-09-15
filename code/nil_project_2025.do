*******************************************************
* 2025 COLLEGE FOOTBALL ROSTER SPENDING PROJECT
* Research question:
* Is estimated roster spending associated with better
* on-field performance in college football?
*
* Run this file from the repository root.
*******************************************************

clear all
set more off
capture log close

*******************************************************
* 1. IMPORT DATA
*******************************************************

import excel "data/2025_roster_spending_performance_data_CLEANED.xlsx", ///
    sheet("2025 Analysis Data") firstrow clear

*******************************************************
* 2. BASIC DATA CHECKS
*******************************************************

describe
summarize wins losses win_pct payroll_mid_m point_diff ///
    points_for points_against
tab conference
correlate payroll_mid_m wins point_diff

*******************************************************
* 3. BASELINE MODELS
* Heteroskedasticity-robust standard errors
*******************************************************

reg wins payroll_mid_m, robust
reg point_diff payroll_mid_m, robust

*******************************************************
* 4. LOG PAYROLL SPECIFICATION
*******************************************************

gen ln_payroll = ln(payroll_mid_m)

reg wins ln_payroll, robust
reg point_diff ln_payroll, robust

*******************************************************
* 5. CONFERENCE CONTROLS
*******************************************************

encode conference, gen(conf_id)

* Full sample specification (68 teams).
* Notre Dame is the only Independent observation, so the
* joint robust F-statistic may be unavailable in this model.
reg wins payroll_mid_m i.conf_id, robust
reg point_diff payroll_mid_m i.conf_id, robust

*******************************************************
* 6. PREFERRED CONFERENCE-CONTROLLED ROBUSTNESS MODEL
* Restrict to ACC, Big 12, Big Ten, and SEC teams so
* every conference category contains multiple schools.
*******************************************************

reg wins payroll_mid_m i.conf_id if conference != "Independent", robust
reg point_diff payroll_mid_m i.conf_id if conference != "Independent", robust

*******************************************************
* 7. PAYROLL-RANGE SENSITIVITY CHECKS
*******************************************************

reg wins payroll_low_m, robust
reg wins payroll_high_m, robust

reg point_diff payroll_low_m, robust
reg point_diff payroll_high_m, robust

reg wins payroll_low_m i.conf_id if conference != "Independent", robust
reg wins payroll_high_m i.conf_id if conference != "Independent", robust

reg point_diff payroll_low_m i.conf_id if conference != "Independent", robust
reg point_diff payroll_high_m i.conf_id if conference != "Independent", robust

*******************************************************
* 8. FIGURES
*******************************************************

twoway ///
    (scatter wins payroll_mid_m) ///
    (lfit wins payroll_mid_m), ///
    xtitle("Estimated Roster Payroll ($ Millions)") ///
    ytitle("2025 Regular-Season Wins") ///
    title("Roster Spending and College Football Wins, 2025") ///
    legend(order(1 "Teams" 2 "Linear Fit")) ///
    name(wins_payroll, replace)

graph export "figures/payroll_vs_wins.png", replace width(2000)

twoway ///
    (scatter point_diff payroll_mid_m) ///
    (lfit point_diff payroll_mid_m), ///
    xtitle("Estimated Roster Payroll ($ Millions)") ///
    ytitle("Season Point Differential") ///
    title("Roster Spending and Point Differential, 2025") ///
    legend(order(1 "Teams" 2 "Linear Fit")) ///
    name(diff_payroll, replace)

graph export "figures/payroll_vs_point_diff.png", replace width(2000)

*******************************************************
* 9. OPTIONAL STATA DATASET
*******************************************************

save "data/2025_nil_project.dta", replace

*******************************************************
* END
*******************************************************
