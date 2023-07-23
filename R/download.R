#' Download an art series
#'
#' @param series Name of the series
#' @param dest_dir Local folder into which the series folder is downloaded
#' @param base_url URL for the bucket containing all art series
#' @param keep_manifest Should the manifest file be downloaded? (default=TRUE)
#'
#' @return Tibble containing the download status data
#' @export
series_download <- function(
    series,
    dest_dir,
    base_url = NULL,
    keep_manifest = TRUE
) {
  base_url <- get_base_url(base_url)
  manifest <- series_manifest(series, base_url)
  dirs <- unique(dirname(x$path))
  fs::dir_create(fs::path(dest_dir, series, dirs))
  file_paths <- manifest$path
  if (keep_manifest) file_paths <- c("manifest.csv", file_paths)
  curl::multi_download(
    urls = paste(base_url, series, file_paths, sep = "/"),
    destfiles = fs::path(dest_dir, series, file_paths)
  )
}

#' Import the series manifest
#'
#' @param series Name of the series
#' @param base_url URL for the bucket containing all art series
#'
#' @return Tibble containing the manifest data
#' @export
series_manifest <- function(series, base_url = NULL) {
  base_url <- get_base_url(base_url)
  readr::read_csv(
    paste(base_url, series, "manifest.csv", sep = "/"),
    show_col_types = FALSE
  )
}

get_base_url <- function(base_url) {
  if (is.null(base_url)) return(getOption("arttools.base_url"))
  base_url
}
