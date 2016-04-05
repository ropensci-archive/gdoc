test_that("TOKEN64 env variable is present", {
  expect_true("TOKEN64" %in% names(Sys.getenv()))
})

test_that("TOKEN64 variable is not blank", {
  TOKEN64 = Sys.getenv("TOKEN64")
  expect_true(TOKEN64 != "")
})

test_that("token is present after writing to file", {
  TOKEN64 = Sys.getenv("TOKEN64")
  if(TOKEN64 != "") {
    token_raw = base64enc::base64decode(what = TOKEN64)
    writeBin(token_raw, ".httr-oauth")
  }
  expect_true(file.exists(".httr-oauth"))
  file.remove('.httr-oauth')
})

