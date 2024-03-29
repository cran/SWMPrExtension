% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/national_sk_map.R
\name{national_sk_map}
\alias{national_sk_map}
\title{Reserve National Map with Seasonal Kendall Results}
\usage{
national_sk_map(
  incl = c("contig", "AK", "HI", "PR"),
  highlight_states = NULL,
  sk_reserves = NULL,
  sk_results = NULL,
  sk_fill_colors = c("#444E65", "#A3DFFF", "#247BA0", "#0a0a0a"),
  agg_county = TRUE
)
}
\arguments{
\item{incl}{chr vector to include AK, HI , and PR (case sensitive)}

\item{highlight_states}{chr vector of state FIPS codes}

\item{sk_reserves}{chr vector of 3 letter reserve codes that have seasonal kendall results}

\item{sk_results}{chr vector of seasonal kendall results. Results can be 'inc', 'dec', 'insig', or 'insuff' which stand for 'increasing trend', 'decreasing trend', 'statistically insignificant trend', or 'insufficient data to detect trend'}

\item{sk_fill_colors}{chr vector of colors used to fill seasonal kendall result markers}

\item{agg_county}{logical, should counties be aggregated to the state-level? Defaults to \code{TRUE}}
}
\value{
Returns a \code{\link[ggplot2]{ggplot}} object
}
\description{
Create a base map for NERRS reserves in ggplot with seasonal kendall results
}
\details{
Create a base map of the US with options for including AK, HI, and PR. The user can choose which states and NERRS reserves to highlight. An early 'sp'-based version of this function by Julie Padilla was developed, in part, from a blog post by Bob Rudis. The current \code{sf}-based version, by Dave Eslinger, uses an approach from the r-spatial tutorial by Mel Moreno and Mathieu Basille.

To ensure the proper plotting of results, the order of the results vector for \code{sk_results} should match the order of the reserves vector for \code{sk_reserves}.
}
\examples{
##National map highlighting west coast and non-CONUS states and NERRS.
nerr_states_west <- c('02', '06', '41', '53', '72', '15')

nerrs_codes <- c('pdb', 'sos', 'sfb', 'elk', 'tjr', 'kac', 'job', 'hee')

nerrs_sk_results <- c('inc', 'inc', 'dec', 'insig', 'insuff', 'dec', 'inc', 'dec')

national_sk_map(highlight_states = nerr_states_west,
                sk_reserve = nerrs_codes, sk_results = nerrs_sk_results)

}
\references{
Rudis, Bob. 2014. "Moving The Earth (well, Alaska & Hawaii) With R". rud.is (blog). November 16, 2014. https://rud.is/b/2014/11/16/moving-the-earth-well-alaska-hawaii-with-r/
Moreno, Mel, and Basille, Mathieu Basille. 2018. "Drawing beautiful maps programmatically with R, sf and ggplot2 — Part 3: Layouts" r-spatial (blog). October 25, 2018. https://www.r-spatial.org/r/2018/10/25/ggplot2-sf-3.html
}
\author{
Julie Padilla, Dave Eslinger
Maintainer: Dave Eslinger
}
\concept{analyze}
