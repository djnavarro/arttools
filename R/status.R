
#' Status of a repository or bucket
#'
#' @param series Name of the series
#' @param local_path Location in which to find the bucket or repository folder
#'
#' @return Invisibly returns TRUE if no problems are detected, FALSE otherwise
#' @name status
NULL

#' @rdname status
#' @export
bucket_status <- function(series, local_path = bucket_local_path()) {
  if (is_url(local_path)) rlang::abort("'local_path' must not be a url")
  cli::cli_alert_info(paste("Checking bucket:", agnostic_path(local_path, series)))
  existence_ok <- bucket_check_exists(series, local_path)
  if (!existence_ok) return(invisible(FALSE))
  files_extensions_ok <- bucket_check_file_extensions(series, local_path)
  files_names_ok <- bucket_check_file_names(series, local_path)
  manifest_ok <- bucket_check_manifest(series, local_path)
  all_ok <- existence_ok & manifest_ok & files_extensions_ok & files_names_ok
  invisible(all_ok)
}

#' @rdname status
#' @export
repo_status <- function(series, local_path = repo_local_path()) {
  if (is_url(local_path)) rlang::abort("'local_path' must not be a url")
  cli::cli_alert_info(
    paste("Checking repository:", agnostic_path(local_path, series))
  )
  existence_ok <- repo_check_exists(series, local_path)
  if (!existence_ok) return(invisible(FALSE))

  git_ok <- repo_check_git(series, local_path)
  gitignore_ok <- repo_check_gitignore(series, local_path)
  license_ok <- repo_check_license(series, local_path)
  readme_ok <- repo_check_readme(series, local_path)
  folders_ok <- repo_check_folders(series, local_path)

  all_ok <- existence_ok & git_ok & gitignore_ok & license_ok & readme_ok &
    folders_ok
  invisible(all_ok)
}


# repo checks -------------------------------------------------------------

repo_check_exists <- function(series, local_path) {
  existence_ok <- fs::dir_exists(agnostic_path(local_path, series))
  if (!existence_ok) {
    cli::cli_alert_warning("Repository folder not detected")
  } else {
    cli::cli_alert_success("Repository folder detected")
  }
  existence_ok
}

repo_check_git <- function(series, local_path) {
  git_ok <- fs::dir_exists(agnostic_path(local_path, series, ".git"))
  if (!git_ok) {
    cli::cli_alert_warning(".git folder not detected")
  } else {
    cli::cli_alert_success(".git folder detected")
  }
  git_ok
}

repo_check_gitignore <- function(series, local_path) {
  gitignore_path <- agnostic_path(local_path, series, ".gitignore")

  gitignore_exists <- fs::file_exists(gitignore_path)
  if (!gitignore_exists) {
    cli::cli_alert_warning(".gitignore file not detected")
    return(FALSE)
  } else {
    cli::cli_alert_success(".gitignore file detected")
  }

  gitignore <- brio::read_lines(gitignore_path)
  output_ignored <- length(grep("output", gitignore)) > 0
  if (!output_ignored) {
    cli::cli_alert_warning(".gitignore file does not list 'output' folder")
  } else {
    cli::cli_alert_success(".gitignore file lists 'output' folder")
  }

  series_ignored <- length(grep(series, gitignore)) > 0
  if (!output_ignored) {
    cli::cli_alert_warning(
      paste0(".gitignore file does not list '", series, "' folder")
    )
  } else {
    cli::cli_alert_success(
      paste0(".gitignore file lists '", series, "' folder")
    )
  }

  gitignore_exists & output_ignored & series_ignored
}

repo_check_license <- function(series, local_path) {
  license_ok <- fs::file_exists(agnostic_path(local_path, series, "LICENSE.md"))
  if (!license_ok) {
    cli::cli_alert_warning("LICENSE.md file not detected")
  } else {
    cli::cli_alert_success("LICENSE.md file detected")
  }
  license_ok
}

repo_check_readme <- function(series, local_path) {
  readme_ok <- fs::file_exists(agnostic_path(local_path, series, "README.md"))
  if (!readme_ok) {
    cli::cli_alert_warning("README.md file not detected")
  } else {
    cli::cli_alert_success("README.md file detected")
  }
  readme_ok
}

repo_check_folders <- function(series, local_path) {
  repo_path <- agnostic_path(local_path, series)

  folders <- fs::dir_ls(path = repo_path, type = "directory")
  folders <- fs::path_split(folders)
  folders <- vapply(folders, function(x) x[length(x)], "")

  folders_ok <- TRUE
  good_folders <- c("build", "source", "input", "output")
  good_folders <- intersect(folders, good_folders)
  if (length(good_folders) > 0) {
    for (folder in good_folders) {
      cli::cli_alert_success(paste0("'", folder, "' folder detected"))
    }
    folders <- setdiff(folders, good_folders)
  }

  if (series %in% folders) {
    cli::cli_alert_info(paste0("'", series, "' folder detected"))
    folders <- setdiff(folders, series)
  }

  if (length(folders) > 0) {
    for (folder in folders) {
      cli::cli_alert_warning(paste0("'", folder, "' folder detected"))
    }
    folders_ok <- FALSE
  }

  folders_ok
}


# bucket checks -----------------------------------------------------------

bucket_check_exists <- function(series, local_path) {
  existence_ok <- fs::dir_exists(agnostic_path(local_path, series))
  if (!existence_ok) {
    cli::cli_alert_warning("Series folder not detected")
  } else {
    cli::cli_alert_success("Series folder detected")
  }
  existence_ok
}

bucket_check_manifest <- function(series, local_path) {
  manifest_path <- agnostic_path(local_path, series, "manifest.csv")
  manifest_exists <- fs::file_exists(manifest_path)
  if (!manifest_exists) {
    cli::cli_alert_warning("Manifest file not detected")
    return(FALSE)
  }
  cli::cli_alert_success("Manifest file detected")
  manifest_from_file <- manifest_read(series, local_path)
  date <- manifest_from_file$series_date[1]
  manifest_from_bucket <- manifest_build(series, date, local_path)
  comparison <- waldo::compare(manifest_from_file, manifest_from_bucket)
  if (length(comparison) > 0) {
    cli::cli_alert_warning(
      "Manifest file does not match images in bucket folder"
    )
    return(FALSE)
  }
  cli::cli_alert_success("Manifest file matches images in bucket folder")
  TRUE
}

list_images <- function(series, local_path) {
  files <- fs::dir_ls(
    path = fs::path(local_path, series),
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

bucket_check_file_extensions <- function(series, local_path) {
  files <- list_images(series, local_path)
  files_ok <- all(is_image(files))
  if (!files_ok) {
    cli::cli_alert_warning("Bucket folder contains non-image files")
  } else {
    cli::cli_alert_success("Bucket folder contains only image files")
  }
  files_ok
}

bucket_check_file_names <- function(series, local_path) {
  files <- list_images(series, local_path)
  name_parts <- strsplit(gsub("\\.[^.]*$", "", files), "_")
  num_name_parts <- vapply(name_parts, length, 1L)
  if (any(num_name_parts < 3L | num_name_parts > 4L)) {
    cli::cli_alert_warning("Image file names may have incorrect number of parts")
    return(FALSE)
  }
  cli::cli_alert_success("Image file names have correct number of parts")
  return(TRUE)
}
