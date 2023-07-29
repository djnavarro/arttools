#' Download series from remote bucket to local storage
#'
#' @param series Name of the series
#' @param local_path Local bucket folder to download to
#' @param remote_url Remote bucket folder to download from
#'
#' @return This function is called for its side effect, downloading series
#' files from a remote bucket storage to local storage. Invisibly returns
#' a tibble containing the download status information, as reported by
#' \code{curl::multi_download()}.
#'
#' @export
bucket_download <- function(
    series,
    local_path = bucket_local_path(),
    remote_url = bucket_remote_url()
) {
  if (!is_url(remote_url)) rlang::abort("'remote_url' path must be a url")
  if (is_url(local_path)) rlang::abort("'local_path' path cannot be a url")
  manifest <- manifest_read(series, remote_url)
  dirs <- unique(dirname(manifest$path))
  fs::dir_create(fs::path(local_path, series, dirs))
  file_paths <- c("manifest.csv", manifest$path)
  cli::cli_alert_info(paste("Downloading from:", url_path(remote_url, series)))
  cli::cli_alert_info(paste("Downloading to:", fs::path(local_path, series)))
  out <- curl::multi_download(
    urls = url_path(remote_url, series, file_paths),
    destfiles = fs::path(local_path, series, file_paths)
  )
  invisible(out)
}
