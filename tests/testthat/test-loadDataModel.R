test_that("the CDM files have the correct fieldnames?", {
  
  expect_true(
    all(c("field", "required", "type", "description", "table") %in% colnames(loadDataModel()))
  )
  
})
