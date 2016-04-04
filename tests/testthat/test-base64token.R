TOKEN64 = Sys.getenv("AUTH64")

if(TOKEN64 != "") {
  base64decode(TOKEN64, output = ".httr-oauth")
}

test_that("token is present", {
  expect_true(file.exists(".httr-oauth"))
})

