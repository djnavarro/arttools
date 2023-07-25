#' Download an art series
#'
#' @param series Name of the series
#' @param destination Local folder into which the series folder is downloaded
#' @param origin Location in which to find the series
#'
#' @return Tibble containing the download status data
#' @export
series_download <- function(
    series,
    destination = bucket_local_path(),
    origin = bucket_remote_path()
) {
  manifest <- manifest_read(series, origin)
  dirs <- unique(dirname(manifest$path))
  fs::dir_create(fs::path(destination, series, dirs))
  file_paths <- c("manifest.csv", manifest$path)
  curl::multi_download(
    urls = paste(origin, series, file_paths, sep = "/"),
    destfiles = fs::path(destination, series, file_paths)
  )
}

#' Check the structure of an art series
#'
#' @param series Name of the series
#' @param origin Location in which to find the series
#'
#' @return Invisibly returns TRUE if all checks pass, FALSE if at least one
#' check fails
#' @export
series_check <- function(series, origin = bucket_local_path()) {
  existence_ok <- series_check_exists(series, origin)
  if (!existence_ok) return(invisible(FALSE))
  manifest_ok <- series_check_manifest(series, origin)
}

series_check_exists <- function(series, origin) {
  existence_ok <- fs::dir_exists(agnostic_path(origin, series))
  if (!existence_ok) {
    cli::cli_alert_info("No series folder detected")
  } else {
    cli::cli_alert_success("Series folder detected")
  }
  existence_ok
}

series_check_manifest <- function(series, origin) {
  manifest_path <- agnostic_path(origin, series, "manifest.csv")
  manifest_exists <- fs::file_exists(manifest_path)
  if (!manifest_exists) {
    cli::cli_alert_info("No manifest file detected")
    return(FALSE)
  }
  cli::cli_alert_success("Manifest file detected")
  manifest_from_file <- manifest_read(series, origin)
  date <- manifest_from_file$series_date[1]
  manifest_from_series <- manifest_build(series, date, origin)
  comparison <- waldo::compare(manifest_from_file, manifest_from_series)
  if (length(comparison) > 0) {
    cli::cli_alert_info("Manifest file does not match images in series")
    return(FALSE)
  }
  cli::cli_alert_success("Manifest file matches images in series")
  TRUE
}
