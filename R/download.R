#' Download series from remote bucket to local storage
#'
#' @param series Name of the series
#' @param local Local bucket folder to download to
#' @param remote Remote bucket folder to download from
#'
#' @return This function is called for its side effect, downloading series
#' files from a remote bucket storage to local storage. Invisibly returns
#' a tibble containing the download status information, as reported by
#' \code{curl::multi_download()}.
#'
#' @export
bucket_download <- function(
    series,
    local = bucket_local_path(),
    remote = bucket_remote_path()
) {
  if (!is_url(remote)) rlang::abort("'remote' path must be a url")
  if (is_url(local)) rlang::abort("'local' path cannot be a url")
  manifest <- manifest_read(series, remote)
  dirs <- unique(dirname(manifest$path))
  fs::dir_create(fs::path(local, series, dirs))
  file_paths <- c("manifest.csv", manifest$path)
  cli::cli_alert_info(paste("Downloading from:", url_path(remote, series)))
  cli::cli_alert_info(paste("Downloading to:", fs::path(local, series)))
  out <- curl::multi_download(
    urls = url_path(remote, series, file_paths),
    destfiles = fs::path(local, series, file_paths)
  )
  invisible(out)
}
