
#' Paths to object buckets and repositories
#'
#' @param ... Names of subfolders
#'
#' @return Fully qualified path or url
#' @rdname paths
#' @export
bucket_remote_url <- function(...) {
  base <- getOption("arttools.bucket.remote")
  paste(base, ..., sep = "/")
}

#' @rdname paths
#' @export
bucket_local_path <- function(...) {
  base <- getOption("arttools.bucket.local")
  fs::path_expand(fs::path(base, ...))
}

#' @rdname paths
#' @export
repo_remote_url <- function(...) {
  base <- getOption("arttools.repos.remote")
  paste(base, ..., sep = "/")
}

#' @rdname paths
#' @export
repo_local_path <- function(...) {
  base <- getOption("arttools.repos.local")
  fs::path_expand(fs::path(base, ...))
}
