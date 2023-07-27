
#' Create new art repository
#'
#' @param series Name of the series (e.g., "series-rosemary")
#' @param license License type for the series ("ccby", "cc0", or "mit")
#' @param destination Location in which the repository folder is created
#' @param remote Location to check for a pre-existing remote repository
#'
#' @return Invisibly returns TRUE on success, FALSE on failure (this may change)
#' @export
repo_create <- function(series,
                        license = NULL,
                        destination = repo_local_path(),
                        remote = repo_remote_path()) {

  series_path <- agnostic_path(destination, series)

  # check for problems with the repo specification
  if (is_url(destination)) {
    cli::cli_alert_danger("new repo have a local destination, aborting")
    return(invisible(FALSE))
  }
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

  # series folder
  fs::dir_create(series_path)
  cli::cli_alert_success(paste("repository folder created at", series_path))

  # readme file
  readme_path <- fs::path_package("arttools", "templates", "readme.md")
  readme <- brio::read_lines(readme_path)
  readme <- gsub("SERIESNAME", series, readme)
  brio::write_lines(readme, fs::path(series_path, "README.md"))
  cli::cli_alert_success("writing README.md")

  # license file
  if (!is.null(license) && license %in% c("ccby", "cc0", "mit")) {
    license_file <- paste0("license-", license, ".md")
    license_path <- fs::path_package("arttools", "templates", license_file)
    fs::file_copy(license_path, fs::path(series_path, "LICENSE.md"))
    cli::cli_alert_success("writing LICENSE.md")
  }

  # gitignore file
  gitignore <- c(".Rproj.user", ".Rhistory", ".Rdata", ".httr-oauth",
                 ".DS_Store", "output", series)
  brio::write_lines(gitignore, fs::path(series_path, ".gitignore"))
  cli::cli_alert_success("writing .gitignore")

  # sentinel file
  brio::write_file("", fs::path(series_path, ".here"))
  cli::cli_alert_success("writing .here")

  # empty folders
  series_dirs <- c("source", "input", "output", "build", series)
  for (dir in series_dirs) {
    fs::dir_create(fs::path(series_path, dir))
    cli::cli_alert_success(paste0("creating folder '", dir, "'"))
  }

  # example files
  example_files <- c("common.R", "art-system_01.R", "art-system_02.R")
  for (example in example_files) {
    fs::file_copy(
      path = fs::path_package("arttools", "templates", example),
      new_path = fs::path(series_path, "source", example)
    )
    cli::cli_alert_success(
      paste0("writing example file '", fs::path("source", example), "'")
    )
  }

  invisible(TRUE)
}

# shallow check for a local repo
repo_exists_local <- function(series, local = repo_local_path()) {
  path <- fs::path(local, series)
  fs::dir_exists(path) && length(fs::dir_ls(path, all = TRUE)) > 0
}

# shallow check for a remote repo
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
