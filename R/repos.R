
#' Create new art repository
#'
#' @param series Name of the series (e.g., "series-rosemary")
#' @param destination Location in which the repository folder is created
#' @param remote Location to check for a pre-existing remote repository
#' @param license License type for the series (e.g. "ccby", "cc0")
#'
#' @return Invisibly returns TRUE on success, FALSE on failure (this may change)
#' @export
repo_create <- function(series,
                        destination = repo_local_path(),
                        remote = repo_remote_path(),
                        license = NULL) {

  if (is_url(destination)) {
    cli::cli_alert_danger("new repo have a local destination, aborting")
    return(invisible(FALSE))
  }

  series_path <- agnostic_path(destination, series)
  if (repo_exists_local(series, destination)) {
    cli::cli_alert_danger(
      paste(series_path, "folder exists and is not empty, aborting")
    )
    return(invisible(FALSE))
  }

  if (repo_exists_remote(series, remote)) {
    cli::cli_alert_danger(paste(series_path, "already exists, aborting"))
    return(invisible(FALSE))
  }

  invisible(TRUE)
}

# shallow check: only looks to see if there's something there
repo_exists_local <- function(series, local = repo_local_path()) {
  path <- fs::path(local, series)
  fs::dir_exists(path) && length(fs::dir_ls(path, all = TRUE)) > 0
}

# shallow check: only looks to see if there's something there
repo_exists_remote <- function(series, remote = repo_remote_path()) {
  url <- agnostic_path(remote, series)
  request <- httr2::request(url)
  request <- httr2::req_timeout(request, seconds = 5)
  request <- httr2::req_error(request, is_error = function(resp) FALSE)
  response <- try(httr2::req_perform(request), silent = TRUE)
  if (inherits(response, "try-error")) {
    cli::cli_alert_warning(paste("Unable to check url:", url))
    return(FALSE)
  }
  status <- httr2::resp_status(response)
  status == 200
}
