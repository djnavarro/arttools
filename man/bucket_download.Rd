% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download.R
\name{bucket_download}
\alias{bucket_download}
\title{Download series from remote bucket to local storage}
\usage{
bucket_download(
  series,
  local_path = bucket_local_path(),
  remote_url = bucket_remote_url()
)
}
\arguments{
\item{series}{Name of the series}

\item{local_path}{Local bucket folder to download to}

\item{remote_url}{Remote bucket folder to download from}
}
\value{
This function is called for its side effect, downloading series
files from a remote bucket storage to local storage. Invisibly returns
a tibble containing the download status information, as reported by
\code{curl::multi_download()}.
}
\description{
Download series from remote bucket to local storage
}
