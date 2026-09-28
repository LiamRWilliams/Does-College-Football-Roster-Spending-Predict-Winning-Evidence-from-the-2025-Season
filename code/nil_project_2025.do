* 2025 college football roster spending project
* Looking at whether estimated roster spending is related to team performance

clear all
set more off
capture log close


* Import cleaned data
import excel "data/2025_roster_spending_performance_data_CLEANED.xlsx", ///
    sheet("2025 Analysis Data") firstrow clear


* Quick checks
describe
summarize wins losses win_pct payroll_mid_m point_diff ///
    points_for points_against

tab conference
correlate payroll_mid_m wins point_diff


* Main regressions
reg wins payroll_mid_m, robust
reg point_diff payroll_mid_m, robust


* Log payroll
gen ln_payroll = ln(payroll_mid_m)

reg wins ln_payroll, robust
reg point_diff ln_payroll, robust


* Conference controls
encode conference, gen(conf_id)

reg wins payroll_mid_m i.conf_id, robust
reg point_diff payroll_mid_m i.conf_id, robust


* Notre Dame is the only Independent, so I also run the
* conference models without Independents
reg wins payroll_mid_m i.conf_id if conference != "Independent", robust
reg point_diff payroll_mid_m i.conf_id if conference != "Independent", robust


* Check whether results change using the low and high payroll estimates
reg wins payroll_low_m, robust
reg wins payroll_high_m, robust

reg point_diff payroll_low_m, robust
reg point_diff payroll_high_m, robust


* Same checks with conference controls
reg wins payroll_low_m i.conf_id if conference != "Independent", robust
reg wins payroll_high_m i.conf_id if conference != "Independent", robust

reg point_diff payroll_low_m i.conf_id if conference != "Independent", robust
reg point_diff payroll_high_m i.conf_id if conference != "Independent", robust


* Payroll vs wins
twoway ///
    (scatter wins payroll_mid_m) ///
    (lfit wins payroll_mid_m), ///
    xtitle("Estimated Roster Payroll ($ Millions)") ///
    ytitle("2025 Regular-Season Wins") ///
    title("Roster Spending and College Football Wins, 2025") ///
    legend(order(1 "Teams" 2 "Linear Fit"))

graph export "figures/payroll_vs_wins.png", replace width(2000)


* Payroll vs point differential
twoway ///
    (scatter point_diff payroll_mid_m) ///
    (lfit point_diff payroll_mid_m), ///
    xtitle("Estimated Roster Payroll ($ Millions)") ///
    ytitle("Season Point Differential") ///
    title("Roster Spending and Point Differential, 2025") ///
    legend(order(1 "Teams" 2 "Linear Fit"))

graph export "figures/payroll_vs_point_diff.png", replace width(2000)


* Save Stata version
save "data/2025_nil_project.dta", replace
