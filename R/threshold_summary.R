#' Summary Plots for Threshold Identification
#'
#' Summary plots for threshold identification analysis
#'
#' @param swmpr_in input swmpr object
#' @param param chr string of variable to plot (one only)
#' @param summary_type Choose from \code{month}, \code{season}, or \code{year} aggregation
#' @param parameter_threshold vector of numerical thresholds to evaluate parameters against
#' @param threshold_type vector of logical operators ('<', '>', '<=', '>=', '==', '!=')
#' @param time_threshold The amount of time an event must last to be counted (in hours)
#' @param converted logical, were the units converted from the original units used by CDMO? Defaults to \code{FALSE}. See \code{y_labeler} for details.
#' @param pal Select a palette for boxplot fill colors. See \code{\link[ggplot2]{scale_fill_brewer}} for more details.
#' @param plot_title logical, should the station name be included as the plot title? Defaults to \code{FALSE}
#' @param plot logical, should a plot be returned? Defaults to \code{TRUE}
#' @param label_y_axis logical, include label for y-axis?
#' @param ... additional arguments passed to other methods. See \code{\link{assign_season}} for more details.
#'
#'
#' @import ggplot2
#'
#' @importFrom dplyr case_when filter group_by left_join n summarize
#' @importFrom magrittr "%>%"
#' @importFrom lubridate  month year
#' @importFrom scales comma
#'
#' @export
#'
#' @details This function provides a graphical or tabular summary of the results from \code{threshold_identification}. The user can summarize results on a monthly, seasonal, or annual basis by specifying \code{summary_type = c('month', 'season', 'year')}. If \code{summary_type = 'season'}, then the user should also define \code{season}, \code{season_names}, and \code{season_start}, as required by \code{\link{assign_season}}. The user can specify \code{'month'} for nutrient parameters, but this is not recommended and will produce a warning.
#'
#' Recommended thresholds for chlorophyll-a, dissolved inorganic nitrogen, dissolved inorganic phosphorus, and dissolved oxygen can be found in the National Coastal Condition Assessment 2010 (USEPA 2016)
#'
#' @author Julie Padilla
#'
#' @concept analyze
#'
#' @return Returns a \code{\link[ggplot2]{ggplot}} object (if \code{plot} = \code{TRUE}) or a dataframe (if \code{plot} = \code{FALSE})
#'
#' @references
#' United States Environmental Protection Agency (USEPA). 2015. "National Coastal Condition Assessment 2010". EPA 841-R-15-006.
#' https://cfpub.epa.gov/si/si_public_record_Report.cfm?Lab=OWOW&dirEntryId=327030
#'
#' @seealso \code{\link{assign_season}}, \code{\link[ggplot2]{ggplot}}, \code{\link{threshold_identification}}, \code{\link[ggplot2]{scale_fill_brewer}}
#'
#' @examples
#' \donttest{
#' ## Water quality examples
#' data(apacpwq)
#' dat_wq <- qaqc(apacpwq, qaqc_keep = c(0, 3, 5))
#' dat_wq <- SWMPr::setstep(dat_wq)
#'
#' x <-
#'   threshold_summary(dat_wq, param = 'do_mgl', parameter_threshold = 2
#'   , threshold_type = '<', time_threshold = 2, summary_type = 'month'
#'   , plot_title = TRUE)
#' }
#' \donttest{
#' y <-
#'   threshold_summary(dat_wq, param = 'do_mgl', parameter_threshold = 2,
#'   threshold_type = '<', time_threshold = 2, summary_type = 'season',
#'   season_grps = list(c(1,2,3), c(4,5,6), c(7,8,9), c(10, 11, 12)),
#'   season_names = c('Winter', 'Spring', 'Summer', 'Fall'),
#'   season_start = 'Winter',
#'   plot_title = TRUE)
#'
#' ## Nutrient examples
#' dat_nut <- qaqc(apacpnut, qaqc_keep = c(0, 3, 5))
#'
#' x <-
#'   threshold_summary(dat_nut, param = 'chla_n',
#'   parameter_threshold = 10,
#'   threshold_type = '>', summary_type = 'month',
#'   plot_title = TRUE)
#'
#' y <-
#'   threshold_summary(dat_nut, param = 'chla_n', parameter_threshold = 10,
#'   threshold_type = '>', summary_type = 'season',
#'   season_grps = list(c(1,2,3), c(4,5,6), c(7,8,9), c(10, 11, 12)),
#'   season_names = c('Winter', 'Spring', 'Summer', 'Fall'),
#'   season_start = 'Winter', plot_title = TRUE)
#'
#'  z <-
#'    threshold_summary(dat_nut, param = 'chla_n', parameter_threshold = 10,
#'    threshold_type = '>', summary_type = 'year',
#'    plot_title = TRUE, plot = TRUE)
#' }

threshold_summary <- function(swmpr_in, ...) UseMethod('threshold_summary')

#' @rdname threshold_summary
#'
#' @export
#'
#' @method threshold_summary swmpr
#'
threshold_summary.swmpr <- function(swmpr_in
                                    , param = NULL
                                    , summary_type = c('month', 'season', 'year')
                                    , parameter_threshold = NULL
                                    , threshold_type = NULL
                                    , time_threshold = NULL
                                    , converted = FALSE
                                    , pal = 'Set3'
                                    , plot_title = FALSE
                                    , plot = TRUE
                                    , label_y_axis = TRUE
                                    , ...)
{

  # define local variables  to remove `check()` warnings
  count <- NULL

  dat <- swmpr_in
  parm <- sym(param)
  grp <- sym(summary_type)
  conv <- converted

 seas <- sym('season')
#  seas <- sym('season')
  yr <- sym('year')

  # attributes
  parameters <- attr(dat, 'parameters')
  station <- attr(dat, 'station')
  data_type <- substr(station, 6, nchar(station))

  #TESTS
  #determine that variable name exists
  if(!any(param %in% parameters))
    stop('Param argument must name input column')

  if(data_type == 'nut' && summary_type == 'month')
    warning('Analyzing nutrient data on a monthly is not recommended. Please set summary_type = season, and specify parameters for assign_season. See examples for details.')

  #determine if QAQC has been conducted
  if(attr(dat, 'qaqc_cols'))
    warning('QAQC columns present. QAQC not performed before analysis.')

  # Assign label for y axis
  y_label <- ifelse(label_y_axis
                    , y_count_labeler(param = param, parameter_threshold = parameter_threshold, threshold_type = threshold_type, time_threshold = time_threshold, converted = conv)
                    , '')

  dat_threshold <- threshold_identification(dat
                                            , param = param
                                            , parameter_threshold = parameter_threshold
                                            , threshold_type = threshold_type
                                            , time_threshold = time_threshold)
  dat_threshold$month <- lubridate::month(dat_threshold$starttime)
  dat_threshold$year <- lubridate::year(dat_threshold$starttime)


  # Assign the seasons and order them
    dat_threshold$season <- assign_season(dat_threshold$starttime,
                                        abb = TRUE, ...)

  mn_yr <- min(lubridate::year(dat$datetimestamp))
  mx_yr <- max(lubridate::year(dat$datetimestamp))

  yr_ct <- mx_yr - mn_yr + 1

  #Summarize results from threshold summary according to summary_type
  if(summary_type == 'year') {
    summary <- dat_threshold %>%
      group_by(!! yr) %>%
      summarise(count = n())

    dummy <- data.frame(grp_join = c(mn_yr:mx_yr)
                        , year = c(mn_yr:mx_yr)
                        , stringsAsFactors = FALSE)

    # dat_grp <- left_join(dummy, summary, by = "dummy")
    dat_grp <- left_join(dummy, summary, by = summary_type)
    dat_grp$count[is.na(dat_grp$count)] <- 0

    dat_grp$grp_join <- factor(dat_grp$grp_join)

  } else {

    #return(dat_threshold)
    if(grp == seas) {
      summary <- dat_threshold %>%
        # group_by(!! yr, !! grp) %>%
        group_by(!! yr, !! grp) %>%
        summarise(count = n(), .groups = "drop_last")
    } else {
      summary <- dat_threshold %>%
        # group_by(!! yr, !! grp) %>%
        # group_by(!! grp) %>%
        group_by(!! yr, !! grp, !! seas) %>%
        summarise(count = n(), .groups = "drop_last")
    }
    # summary <- dat_threshold %>%
    #   # group_by(!! yr, !! grp) %>%
    #   group_by(!! yr, !! grp, !! seas) %>%
    #   summarise(count = n())

    grp_ct <- as.numeric(length(unique(levels(summary$season))))
    grp_nm <- as.character(unique(levels(summary$season)))

    summary$grp_join <- as.character(summary$season)
    summary <- summary %>% filter(count > 0)

    dummy <- data.frame(grp_join = rep(grp_nm, yr_ct)
                        , year = rep(c(mn_yr:mx_yr), each = grp_ct)
                        , stringsAsFactors = FALSE)

    dat_grp <- suppressMessages(left_join(dummy, summary))
    dat_grp$count[is.na(dat_grp$count)] <- 0

    dat_grp$grp_join <- factor(dat_grp$grp_join, levels = levels(dat_grp$season))
  }

  dat_grp$x_lab <- seq(from = 1, to = length(dat_grp$grp_join), by = 1)

  if(plot){

    by_arg <- ifelse(summary_type == 'year', 1, length(unique(levels(dat_grp$grp_join))))


    brks <- seq(from = 1, to = max(dat_grp$x_lab), by = by_arg)
    label_spacing <- case_when(
        mx_yr - mn_yr > 20 ~ 4,
        mx_yr - mn_yr > 10 ~ 2,
        TRUE               ~ 1)

    dummy_labs <- seq(from = mn_yr, to = mx_yr, by = 1)
    brk_labs <- rep("", length(dummy_labs))
    label_indx <- seq(1, length(dummy_labs), label_spacing)
    brk_labs[label_indx] <- dummy_labs[label_indx]


plt <-
      ggplot(dat_grp, aes_string(x = 'x_lab', y = 'count', fill = 'grp_join')) +
      geom_bar(stat = 'identity', position = 'dodge') +
      scale_x_continuous(breaks = brks, labels = brk_labs) +
      labs(x = '', y = y_label)

    plt <-
      plt +
      theme_bw() +
      guides(fill = guide_legend(override.aes = list(linetype = 'blank'), order = 1, nrow = 2, byrow = TRUE)) +
      theme(panel.grid.minor.y = element_blank()
            , panel.grid.major.y = element_line(linetype = 'dashed')) +
      theme(panel.grid.minor.x = element_blank()) +
      theme(legend.position = 'top', legend.title = element_blank()) +
      theme(axis.title.x = element_text(margin = unit(c(8, 0, 0, 0), 'pt'))
            , axis.title.y = element_text(margin = unit(c(0, 8, 0, 0), 'pt'), angle = 90))

    plt <- plt +
      theme(text = element_text(size = 14))

    plt <- plt +
      theme(legend.key.size = unit(7, 'pt')) +
      theme(legend.text = element_text(size = 8)) +
      theme(legend.spacing.x = unit(3, 'pt'))


    if(summary_type == 'year') {

      yrs <- length(unique(brks))

      plt <- plt + scale_fill_manual('', values = rep('gray30', yrs)) +
        guides(fill = FALSE)
    } else {
      plt <- plt + scale_fill_brewer('', palette = pal)
    }

    if(plot_title) {
      ttl <- title_labeler(nerr_site_id = station)

      plt <-
        plt +
        ggtitle(ttl) +
        theme(plot.title = element_text(hjust = 0.5))
    }

    return(plt)

  } else {
    return(dat_grp)
  }

}
