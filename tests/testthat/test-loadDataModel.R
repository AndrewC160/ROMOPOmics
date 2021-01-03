test_that("the CDM files have the correct fieldnames?", {
  
  expect_true(
    all(c("field", "table") %in% colnames(loadDataModel()))
  )
  
})

test_that("every entry has a field and table non-empty string", {
  
  dm <- loadDataModel()
  
  fields <- dm$field
  expect_length(fields[fields!=""],length(fields))
  
  tables <- dm$table
  expect_length(tables[tables!=""],length(tables))
  
})
