#' Set reasonable date breaks
#'
#' Select reasonable breaks for \code{\link[ggplot2]{scale_x_datetime}}
#'
#' @param rng date range years
#'
#' @importFrom dplyr case_when

#' @export
#'
#' @details A helper function for easier date label setting
#'
#' @author Julie Padilla
#'
#' @concept miscellaneous
#'
#' @return Returns a chr string for \code{date_breaks}
#'
#' @seealso \code{\link{set_date_break_labs}}, \code{\link[ggplot2]{scale_x_datetime}}
#'
set_date_breaks <- function(rng) {
  if(length(unique(rng)) == 2) {
    # brks <- ifelse(diff(rng) > 3, '1 year', '4 months')
    brks <- case_when(
      diff(rng) > 20  ~ '4 years',
      diff(rng) > 10  ~ '2 year',
      diff(rng) >  3   ~ '1 year',
      TRUE            ~ '4 months')
  } else {
    brks <- ifelse(length(unique(rng)) > 1, '2 months', '1 month')
  }
}


#' Select reasonable minor breaks for \code{\link[ggplot2]{scale_x_datetime}}
#'
#' @param rng date range years
#'
#' @export
#'
#' @details A helper function for easier date label setting
#'
#' @author Dave Eslinger, Julie Padilla
#'
#' @concept miscellaneous
#'
#' @return Returns a chr string for \code{date_breaks}
#'
#' @seealso \code{\link{set_date_break_labs}}, \code{\link[ggplot2]{scale_x_datetime}}
#'
set_date_breaks_minor <- function(rng) {
  if(length(unique(rng)) == 2) {
    brks_minor <- case_when(
      diff(rng) >  3   ~ '1 year',
      TRUE            ~ '1 year')
  } else {
    brks_minor <- '1 month'

  }
}


#' Set reasonable date breaks labels
#'
#' Select reasonable labels for breaks used in \code{\link[ggplot2]{scale_x_datetime}}
#'
#' @param rng date range years
#'
#' @concept analyze
#'
#' @export
#'
#' @details A helper function for easier date label setting
#'
#' @author Julie Padilla
#'
#' @return Returns a chr string for \code{date_labels}
#'
##' @seealso \code{\link{set_date_breaks}}, \code{\link[ggplot2]{scale_x_datetime}}
#'
set_date_break_labs <- function(rng) {
  if(length(unique(rng)) == 2) {
    lab_brks <- ifelse(diff(rng) > 3, '%Y', '%b-%y')
  } else {
    lab_brks <- ifelse(length(unique(rng)) > 1, '%b-%y', '%b')
  }
}
