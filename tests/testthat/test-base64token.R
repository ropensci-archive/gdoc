AUTH64 = Sys.getenv("AUTH64")

if(AUTH64 != "") {
  base64decode(AUTH64, output = ".httr-oauth")
}

test_that("token is present", {
  expect_true(file.exists(".httr-oauth"))
})

