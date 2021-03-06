% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/threshold_identification.R
\name{threshold_identification}
\alias{threshold_identification}
\alias{threshold_identification.swmpr}
\title{Tabulate Threshold Exceedances}
\usage{
threshold_identification(swmpr_in, ...)

\method{threshold_identification}{swmpr}(
  swmpr_in,
  param,
  parameter_threshold,
  threshold_type,
  time_threshold = NULL,
  ...
)
}
\arguments{
\item{swmpr_in}{input swmpr object}

\item{...}{arguments passed to other methods}

\item{param}{vector of parameters to evaluate}

\item{parameter_threshold}{vector of numerical thresholds to evaluate parameters against}

\item{threshold_type}{vector of logical operators ('<', '>', '<=', '>=', '==', '!=')}

\item{time_threshold}{The amount of time an event must last to be counted (in hours)}
}
\value{
Returns a data frame of threshold exceedances by parameter
}
\description{
Tabulate user-specified threshold exceedances
}
\details{
This function creates tabular summary of events when a user-specified threshold is exceeded.

Before using this function, the user must apply \code{\link[SWMPr]{setstep}} to normalize the \code{datetimestamp} time step.

For MET and WQ data, the user must specify \code{time_threshold}. This argument is the minimum duration that an event must last in order to be counted. For example, if \code{time_threshold = 2}, \code{param = "do_mgl"}, \code{parameter_threshold = 2}, and \code{threshold_type = "<"} then dissolved oxygen must be lower than 2 mg/L for more than two hours or the event will not be summarized in the final table. For NUT parameters, all exceedances are included in the tabular summary.

Recommended thresholds for chlorophyll-a, dissolved inorganic nitrogen, dissolved inorganic phosphorus, and dissolved oxygen can be found in the National Coastal Condition Assessment 2010 (USEPA 2016)
}
\examples{
data("apacpwq")
wq <- apacpwq

dat_wq <- qaqc(wq, qaqc_keep = c(0, 3, 5))
dat_wq <- setstep(dat_wq)

wq_pars<- threshold_identification(dat_wq, param = c('do_mgl', 'ph', 'temp')
                          , parameter_threshold = c(2, 5, 30)
                          , threshold_type = c('<', '<', '>'), time_threshold = 2)

\donttest{
wq_par<- threshold_identification(dat_wq, param = c('do_mgl')
                          , parameter_threshold = c(2)
                          , threshold_type = c('<'), time_threshold = 2)


## time_threshold and setstep are not necessary for monthly parameters
data("apacpnut")
nut <- apacpnut

dat_nut <- qaqc(nut, qaqc_keep = c(0, 3, 5))

nut_pars <- threshold_identification(dat_nut, param = c('chla_n', 'po4f')
                          , parameter_threshold = c(10, 0.01)
                          , threshold_type = c('>', '>'))

nut_par <- threshold_identification(dat_nut, param = c('chla_n')
                          , parameter_threshold = c(10)
                          , threshold_type = c('>'))

nut_err <- threshold_identification(dat_nut, param = c('chla_n')
                          , parameter_threshold = c(30)
                          , threshold_type = c('>'))

}
}
\references{
United States Environmental Protection Agency (USEPA). 2015. "National Coastal Condition Assessment 2010". EPA 841-R-15-006.
https://cfpub.epa.gov/si/si_public_record_Report.cfm?Lab=OWOW&dirEntryId=327030
}
\author{
Julie Padilla
}
\concept{analyze}
