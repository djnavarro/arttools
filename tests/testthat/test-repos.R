
# setup -------------------------------------------------------------------

temp_repos <- fs::path(tempdir(), "temp_repos")
temp_bucket <- fs::path(tempdir(), "temp_bucket")

if (fs::dir_exists(fs::path(temp_repos, "series-test"))) {
  fs::dir_delete(fs::path(temp_repos, "series-test"))
}

if (fs::dir_exists(fs::path(temp_bucket, "series-test"))) {
  fs::dir_delete(fs::path(temp_bucket, "series-test"))
}


# tests -------------------------------------------------------------------

test_that("repo_create creates repository files", {
  expect_true(
    suppressMessages(
      repo_create(
        series = "series-test",
        license = NULL,
        local_path = temp_repos,
        remote_url = NULL
      )
    )
  )

  expected_repo <- c(
    ".gitignore", ".here", "README.md", "build", "input", "output", "source",
    "source/art-system_01.R", "source/art-system_02.R", "source/common.R"
  )

  actual_repo <- as.character(
    fs::path_rel(
      fs::dir_ls(
        fs::path(temp_repos, "series-test"),
        recurse = TRUE,
        all = TRUE
      ),
      start = fs::path(temp_repos, "series-test")
    )
  )

})

test_that("repo_create aborts when repository exists", {
  expect_false(
    suppressMessages(
      repo_create(
        series = "series-test",
        license = NULL,
        local_path = temp_repos,
        remote_url = NULL
      )
    )
  )
  expect_message(
    repo_create(
      series = "series-test",
      license = NULL,
      local_path = temp_repos,
      remote_url = NULL
    ),
    "folder exists and is not empty, aborting"
  )

})


# clean up ----------------------------------------------------------------


if (fs::dir_exists(fs::path(temp_repos, "series-test"))) {
  fs::dir_delete(fs::path(temp_repos, "series-test"))
}

if (fs::dir_exists(fs::path(temp_bucket, "series-test"))) {
  fs::dir_delete(fs::path(temp_bucket, "series-test"))
}
