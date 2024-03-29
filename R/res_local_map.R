#' Local Reserve Map
#'
#' Create a stylized reserve-level map for use with the reserve level reporting
#' template
#'
#' @param nerr_site_id chr string of the reserve to make, first three characters
#'   used by NERRS
#' @param stations chr string of the reserve stations to include in the map
#' @param bbox a bounding box associated with the reserve. Must be in the format
#'   of c(X1, Y1, X2, Y2)
#' @param shp {sf} data frame (preferred) or SpatialPolygons object
#' @param station_labs logical, should stations be labeled? Defaults to
#'   \code{TRUE}
#' @param lab_loc chr vector of 'R' and 'L', one letter for each station. if no
#'   \code{lab_loc} is specified then labels will default to the left.
#' @param bg_map a georeferenced \code{ggmap} or \code{ggplot} object used as a
#'   background map, generally provided by a call to \code{base_map}. If
#'   \code{bg_map} is specified, \code{maptype} and \code{zoom} are ignored.
#' @param maptype Background map type from Stadia Maps (formerly Stamen)
#'   (\url{https://docs.stadiamaps.com/}); one of c("stamen_terrain",
#'   "stamen_toner", "stamen_toner_lite", "stamen_watercolor", "alidade_smooth",
#'   "alidade_smooth_dark", "outdoors", "stamen_terrain_background",
#'   "stamen_toner_background", "stamen_terrain_labels", "stamen_terrain_lines",
#'   "stamen_toner_labels", "stamen_toner_lines").
#' @param zoom Zoom level for the base map created when \code{bg_map} is not
#'   specified.  An integer value, 5 - 15, with higher numbers providing  more
#'   detail.  If not provided, a zoom level is autoscaled based on \code{bbox}
#'   parameters.
#'
#'
#' @importFrom magrittr "%>%"
#' @importFrom methods as
#' @importFrom sf st_as_sf st_bbox st_crs st_sfc st_transform
#' @importFrom utils download.file unzip
#'
#' @export
#'
#' @details Creates a stylized, reserve-level base map. The user can specify the
#'   reserve and stations to plot. The user can also specify a bounding box. For
#'   multi-component reserves, the user should specify a bounding box that
#'   highlights the component of interest.
#'
#'   This function does not automatically detect conflicts between station
#'   labels. The \code{lab_loc} argument allows the user to specify "R" or "L"
#'   for each station to prevent labels from conflicting with each other.
#'
#'   This function is intended to be used with \code{mapview::mapshot} to
#'   generate a png for the reserve-level report.
#'
#' @author Julie Padilla, Dave Eslinger
#'
#' @concept analyze
#'
#' @return returns a \code{ggplot} object
#'
#' @examples
#' ## a compact reserve
#' ### set plotting parameters
#' stations <-
#' sampling_stations[(sampling_stations$NERR.Site.ID == 'elk'
#'           & sampling_stations$Status == 'Active'
#'           & sampling_stations$isSWMP == "P"), ]$Station.Code
#'           to_match <- c('wq', 'met')
#' stns <- stations[grep(paste(to_match, collapse = '|'), stations)]
#' shp_fl <- elk_spatial
#' bounding_elk <- c(-121.8005, 36.7779, -121.6966, 36.8799)
#' lab_dir <- c('L', 'R', 'L', 'L', 'L')
#' labs <- c('ap', 'cw', 'nm', 'sm', 'vm')
#'
#' ### Low zoom and default maptype plot (for CRAN testing, not recommended)
#' #    Lower zoom number gives coarser text and fewer features
#' (x_low <- res_local_map('elk', stations = stns, bbox = bounding_elk,
#'                    lab_loc = lab_dir, shp = shp_fl,
#'                    zoom = 10))
#'
#' \donttest{
#' ### Default zoom and maptype
#' x_def  <- res_local_map('elk', stations = stns, bbox = bounding_elk,
#'                    lab_loc = lab_dir, shp = shp_fl,
#'                    zoom = 10)
#'
#' ### A multicomponent reserve (show two different bounding boxes)
#' #    set plotting parameters
#' stations <- sampling_stations[(sampling_stations$NERR.Site.ID == 'cbm'
#'             & sampling_stations$Status == 'Active'
#'             & sampling_stations$isSWMP == "P"), ]$Station.Code
#'             to_match <- c('wq', 'met')
#' stns <- stations[grep(paste(to_match, collapse = '|'), stations)]
#' shp_fl <- cbm_spatial
#' bounding_cbm_1 <- c(-77.393, 38.277, -75.553, 39.741)
#' bounding_cbm_2 <- c(-76.8,  38.7, -76.62,  38.85)
#' lab_dir <- c('L', 'R', 'L', 'L', 'L')
#' labs <- c('ap', 'cw', 'nm', 'sm', 'vm')
#'
#' ### plot
#' y <- res_local_map('cbm', stations = stns, bbox = bounding_cbm_1,
#'                    lab_loc = lab_dir, shp = shp_fl)
#'
#' z <- res_local_map('cbm', stations = stns, bbox = bounding_cbm_2,
#'                    lab_loc = lab_dir, shp = shp_fl)
#'
#' }
#'
res_local_map <- function(nerr_site_id
                          , stations
                          , bbox
                          , shp
                          , station_labs = TRUE
                          , lab_loc = NULL
                          #                          , scale_pos = c("lower", "bottom")
                          , bg_map = NULL
                          , zoom = NULL
                          , maptype = "stamen_toner_lite") {

  # define local variables  to remove `check()` warnings
  abbrev <- lab_long <- lab_lat <- NULL

  # check that a shape file exists
  if(!('SpatialPolygons' %in% class(shp))) {
    if(!('sf' %in% class(shp))) {
      stop('shapefile (shp) must be sf (preferred) or SpatialPolygons object')
    }
  } else {
    shp <- as(shp, "sf")   # convert SpatialPolygons to sf
  }

  # check that length(lab_loc) = length(stations)
  if(!is.null(station_labs) && length(lab_loc) != length(stations))
    stop('Incorrect number of label location identifiers specified. R or L designation must be made for each station.' )

  # check that the bb has the right dimensions
  if(is.null(bbox))
    stop('Specify a bounding box (bbox) in the form of c(X1, Y1, X2, Y2)')
  if(length(bbox) != 4)
    stop('Incorrect number of elements specified for bbox. Specify a bounding box (bbox) in the form of c(X1, Y1, X2, Y2)')
  # Get min-max bounding coordinates, and format bbox correctly:
  xmin <- min(bbox[c(1,3)])
  xmax <- max(bbox[c(1,3)])
  ymin <- min(bbox[c(2,4)])
  ymax <- max(bbox[c(2,4)])
  bbox <- c(xmin, ymin, xmax, ymax)

  # generate location labels
  loc <- get('sampling_stations')
  loc <- loc[(loc$Station.Code %in% stations), ]
  loc$abbrev <- toupper(substr(loc$Station.Code, start = 4, stop = 5))

  # Default all labels to left and then change if there is location information
  loc$align <- -1.25
  if(!is.null(lab_loc))
    loc$align[lab_loc == 'R'] <- 1.25

  # order selected stations alphabetically
  loc <- loc[order(loc$Station.Code), ]

  # Swap sign of longitudes, which seem to be positive in the data!
  loc$Longitude <- -loc$Longitude

  # Define lat/long for labels, based on stations, alignment, and bbox
  loc$lab_long <- loc$Longitude + 0.045* loc$align * (bbox[3] - bbox[1])
  loc$lab_lat <- loc$Latitude + 0.015 * (bbox[4] - bbox[2])

  # convert Labels info to sf object, use lat/lon, WGS84 projection, EPSG:4326.
  labels_sf <- loc %>%
    select(abbrev, lab_long, lab_lat) %>%
    sf::st_as_sf(coords = c("lab_long","lab_lat"))
  sf::st_crs(labels_sf) <- 4326

  # convert location info to sf object, use lat/lon, WGS84 projection, EPSG:4326.
  loc_sf <- sf::st_as_sf(loc, coords = c("Longitude","Latitude"))
  sf::st_crs(loc_sf) <- 4326


  # These are the codes for the fill color, size and shape legends.
  fill_colors <-  loc_sf$color #  c('#444E65', '#A3DFFF', '#247BA0', '#0a0a0a')
  break_vals <- loc_sf$abbrev #c("inc", "dec", "insig", "insuff")

  print(paste("maptype is ",maptype))

  if(is.null(bg_map)) {
    bg_map <- base_map(bbox, crs = st_crs(shp),
                     maptype = maptype,
                     zoom = zoom)
  }

  m <- bg_map +
    geom_sf(data = shp, aes(), inherit.aes = FALSE,
            fill = "yellow", col = '#B3B300', alpha = 0.3) +
    ggthemes::theme_map() +
    #    geom_sf_text(data = loc_sf, aes(), inherit.aes = FALSE) +
    geom_sf(data = loc_sf, inherit.aes = FALSE,
            aes(color = .data$abbrev,
                fill = .data$abbrev),
            shape = 21,
            size = 4.,
            show.legend = FALSE) +
    scale_color_manual(values = fill_colors, breaks = break_vals) +
    scale_fill_manual(values = fill_colors, breaks = break_vals)

  if(station_labs) {
    # Define lat/long for labels, based on stations, alignment, and bbox
    loc$lab_long <- loc$Longitude + 0.055 * loc$align * (bbox[3] - bbox[1])
    loc$lab_lat <- loc$Latitude + 0.015 * (bbox[4] - bbox[2])

    # convert Labels info to sf object, use lat/lon, WGS84 projection, EPSG:4326.
    labels_sf <- loc %>%
      select(abbrev, lab_long, lab_lat) %>%
      sf::st_as_sf(coords = c("lab_long","lab_lat"))
    sf::st_crs(labels_sf) <- 4326

    m <- m +
      geom_sf_label(data = labels_sf, inherit.aes = FALSE,
                    aes(label = abbrev))
  }

  m <- m +
    coord_sf(
      xlim = c(bbox[1], bbox[3]),
      ylim = c(bbox[2], bbox[4]),
      expand = FALSE,
      crs = st_crs(shp),
      default_crs = NULL,
      datum = sf::st_crs(4326),
      # label_graticule = waiver(),
      # label_axes = waiver(),
      lims_method = c("cross", "box", "orthogonal", "geometry_bbox"),
      ndiscr = 100,
      default = FALSE,
      clip = "on"
    )

  return(m)
}
