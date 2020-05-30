#### SWMPrExtestion 1.1.5
* Changes in lm_pLlabs.R to prepare for upcoming release of {broom} 0.7, which removed rowise tidier functions.

#### SWMPrExtension 1.1.4
* Updates for R 4.0 and associated changes
* Fixed {tibble} related issues in seasonal_dot.R and historical_range.R
* Fixed pre-existing error in threshold_percentile_plot.R if target year is outside of historical range.

#### SWMPrExtension 1.1.3
* Fixed ISSUE# 46: Addressed {rgdal} & {sp} issues when using PROJ > 6. 
* Corrected mismatched and mislabeled map projections in national mapping code so that all national-level maps use a Lambert Azimuthal Equal Area projections.  This is the projection that was being used for some shapefiles, but was mislabelled as Albers Equal Area, which then lead to some projection mismatch errors.

#### SWMPrExtension 1.1.2
* Fixed annotation error in seasonal_dot.R; changed from annotate() to geom_text().

#### SWMPrExtension 1.1.1
* Updates to allow user to specify trend colors for `create_sk_flextable_list` function
* Additional updates to compensate for changes in Officer 0.3.3 flextable structure
* adding `free_y` argument to `threshold_percentile_plot`
* Minor fix to help files if searching by concept, e.g., `help.search('analyze', package = "SWMPrExtension")

#### SWMPrExtension 1.1.0
* Updates to plot legends for compatibility with ggplot2 3.0.0
* Updates to `threshold_percentile_plot()` to handle issues with the y-axis
* Updates to `threshold_summary()` to work with dplyr 0.8.0
* Added `remove_inf_and_nan()` to fix issues with range plots and dot_plot
* Corrections to custom mapping functions (label placement)

#### SWMPrExtension 1.0
* package maintainer changed from Julie Padilla to Dave Eslinger
* license changed to NOAA approved language

#### SWMPrExtension 0.3.16
* Updates to historical_range and historical_daily_range: analysis now allows for comparisons between a target year and a historical range that does not include the target year.

#### SWMPrExtension 0.3.15
* Updates to y-axis for threshold_percentile_plot

#### SWMPrExtension 0.3.14
* Changes to leaflet package resulted in station labels without formats. Currently this bug cannot be fully addressed. Basic formatting has been implemented for reserve level mapping functions
* Updates to:
 * res_sk_map
 * res_sk_custom_map
 * res_local_map
 * res_custom_map

#### SWMPrExtension 0.3.13
* Documentation updates and the addition of toy examples for testing
* Updates to historical_daily_range.swmpr
 * legend order when criteria = NULL is now equivalent to legend order when criteria argument is not null.

#### SWMPrExtension 0.3.12

* Added Bob Rudis and Marcus Beck as authors
