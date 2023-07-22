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
