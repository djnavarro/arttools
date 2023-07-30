
# setup -------------------------------------------------------------------

temp_repos <- fs::path(tempdir(), "temp_repos")
temp_bucket <- fs::path(tempdir(), "temp_bucket")

test_date <- as.Date("2000-01-01")

if (fs::dir_exists(fs::path(temp_repos, "series-test"))) {
  fs::dir_delete(fs::path(temp_repos, "series-test"))
}

if (fs::dir_exists(fs::path(temp_bucket, "series-test"))) {
  fs::dir_delete(fs::path(temp_bucket, "series-test"))
}

fs::dir_create(fs::path(temp_bucket, "series-test"))
fs::dir_create(fs::path(temp_bucket, "series-test", "image"))
fs::dir_create(fs::path(temp_bucket, "series-test", "preview"))
fs::file_create(fs::path(temp_bucket, "series-test", "image", "test_01_01.png"))
fs::file_create(fs::path(temp_bucket, "series-test", "preview", "test_01_01.png"))

# tests -------------------------------------------------------------------

test_that("manifest_build creates manifest tibble", {

  expect_no_error(manifest_build("series-test", test_date, temp_bucket))

  manifest <- manifest_build("series-test", test_date, temp_bucket)
  expect_s3_class(manifest, "data.frame")
  expect_equal(nrow(manifest), 2)
  expect_named(manifest, c("series_name", "series_date", "path", "folder",
                           "file_name", "file_format", "system_name",
                           "system_version", "image_id", "image_short_title",
                           "image_long_title", "manifest_version"))
})

test_that("manifest_write creates manifest csv", {

  manifest_path <- fs::path(temp_bucket, "series-test", "manifest.csv")
  expect_false(fs::file_exists(manifest_path))
  manifest_write("series-test", test_date, temp_bucket)
  expect_true(fs::file_exists(manifest_path))

})

test_that("manifest_read reads manifest csv", {

  expect_no_error(manifest_read("series-test", temp_bucket))

  manifest <- manifest_read("series-test", temp_bucket)
  expect_s3_class(manifest, "data.frame")
  expect_equal(nrow(manifest), 2)
  expect_named(manifest, c("series_name", "series_date", "path", "folder",
                           "file_name", "file_format", "system_name",
                           "system_version", "image_id", "image_short_title",
                           "image_long_title", "manifest_version"))

})

test_that("manifest data survives round trip", {

  expect_equal(
    manifest_read("series-test", temp_bucket),
    manifest_build("series-test", test_date, temp_bucket)
  )

})


# clean up ----------------------------------------------------------------

if (fs::dir_exists(fs::path(temp_bucket, "series-test"))) {
  fs::dir_delete(fs::path(temp_bucket, "series-test"))
}

if (fs::dir_exists(fs::path(temp_repos, "series-test"))) {
  fs::dir_delete(fs::path(temp_repos, "series-test"))
}

