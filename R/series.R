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
  cli::cli_alert_info(paste("Checking", agnostic_path(origin, series)))
  existence_ok <- series_check_exists(series, origin)
  if (!existence_ok) return(invisible(FALSE))
  files_extensions_ok <- series_check_file_extensions(series, origin)
  files_names_ok <- series_check_file_names(series, origin)
  manifest_ok <- series_check_manifest(series, origin)
  all_ok <- existence_ok & manifest_ok & files_extensions_ok & files_names_ok
  invisible(all_ok)
}

series_check_exists <- function(series, origin) {
  existence_ok <- fs::dir_exists(agnostic_path(origin, series))
  if (!existence_ok) {
    cli::cli_alert_warning("No series folder detected")
  } else {
    cli::cli_alert_success("Series folder detected")
  }
  existence_ok
}

series_check_manifest <- function(series, origin) {
  manifest_path <- agnostic_path(origin, series, "manifest.csv")
  manifest_exists <- fs::file_exists(manifest_path)
  if (!manifest_exists) {
    cli::cli_alert_warning("No manifest file detected")
    return(FALSE)
  }
  cli::cli_alert_success("Manifest file detected")
  manifest_from_file <- manifest_read(series, origin)
  date <- manifest_from_file$series_date[1]
  manifest_from_series <- manifest_build(series, date, origin)
  comparison <- waldo::compare(manifest_from_file, manifest_from_series)
  if (length(comparison) > 0) {
    cli::cli_alert_warning(
      "Manifest file does not match images in series folder"
    )
    return(FALSE)
  }
  cli::cli_alert_success("Manifest file matches images in series folder")
  TRUE
}

list_images <- function(series, origin) {
  files <- fs::dir_ls(
    path = agnostic_path(origin, series),
    recurse = TRUE,
    type = "file"
  )
  files <- grep(
    pattern = "manifest.csv",
    x = files,
    fixed = TRUE,
    value = TRUE,
    invert = TRUE
  )
  files
}

series_check_file_extensions <- function(series, origin) {
  files <- list_images(series, origin)
  files_ok <- all(is_image(files))
  if (!files_ok) {
    cli::cli_alert_warning("Series folder may contain non-image files")
  } else {
    cli::cli_alert_success("Series folder contains only image files")
  }
  files_ok
}

series_check_file_names <- function(series, origin) {
  files <- list_images(series, origin)
  name_parts <- strsplit(gsub("\\.[^.]*$", "", files), "_")
  num_name_parts <- vapply(name_parts, length, 1L)
  if (any(num_name_parts < 3L | num_name_parts > 4L)) {
    cli::cli_alert_warning("Some image file names have incorrect number of parts")
    return(FALSE)
  }
  cli::cli_alert_success("Image file names have correct number of parts")
  return(TRUE)
}
