% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/image-resize.R
\name{create_resized_images}
\alias{create_resized_images}
\title{Create resized copies of all images in a directory}
\usage{
create_resized_images(
  series,
  images_from,
  images_to,
  pixels_wide,
  pixels_high = pixels_wide,
  origin = bucket_local_path()
)
}
\arguments{
\item{series}{Name of the series}

\item{images_from}{Folder within the series containing original images}

\item{images_to}{Folder within the series to contain resized images}

\item{pixels_wide}{Width of output images in pixels}

\item{pixels_high}{Height of output images in pixels description}

\item{origin}{Location in which to find the series}
}
\value{
Invisibly returns NULL. This may change
}
\description{
Create resized copies of all images in a directory
}
