
test_that("token is present", {
  TOKEN64 = Sys.getenv("TOKEN64")
  if(TOKEN64 != "") {
    token_raw = base64enc::base64decode(what = TOKEN64)
    writeBin(token_raw, ".httr-oauth")
  }
  cat(TOKEN64)
  expect_true(file.exists(".httr-oauth"))
  file.remove('.httr-oauth')
})

