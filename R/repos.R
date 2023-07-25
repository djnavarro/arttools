
#' Check the structure of an art repository
#'
#' @param series Name of the series
#' @param origin Location in which to find the series
#'
#' @return Invisibly returns TRUE if all checks pass, FALSE if at least one
#' check fails
#' @export
repo_check <- function(series, origin = repo_local_path()) {
  if (is_url(origin)) rlang::abort("cannot check a remote repository")
  cli::cli_alert_info(paste("Checking", agnostic_path(origin, series)))
  existence_ok <- repo_check_exists(series, origin)
  if (!existence_ok) return(invisible(FALSE))
  git_ok <- repo_check_git(series, origin)
  license_ok <- repo_check_license(series, origin)

  all_ok <- existence_ok & git_ok & license_ok
  invisible(all_ok)
}

repo_check_exists <- function(series, origin) {
  existence_ok <- fs::dir_exists(agnostic_path(origin, series))
  if (!existence_ok) {
    cli::cli_alert_warning("Series folder not detected")
  } else {
    cli::cli_alert_success("Series folder detected")
  }
  existence_ok
}

# this is a shallow check: it looks for the .git folder
repo_check_git <- function(series, origin) {
  git_ok <- fs::dir_exists(agnostic_path(origin, series, ".git"))
  if (!git_ok) {
    cli::cli_alert_warning("Git repository not detected")
  } else {
    cli::cli_alert_success("Git repository detected")
  }
  git_ok
}

repo_check_license <- function(series, origin) {
  license_ok <- fs::file_exists(agnostic_path(origin, series, "LICENSE.md"))
  if (!license_ok) {
    cli::cli_alert_warning("LICENSE.md file not detected")
  } else {
    cli::cli_alert_success("LICENSE.md file detected")
  }
  license_ok
}



