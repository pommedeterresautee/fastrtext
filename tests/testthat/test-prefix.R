context("test word prefix")

test_that("test unique prefix", {
  expect_equal(object = add_prefix(c("this is a test", "this is another test"), "#"),
               expected = c("#this #is #a #test", 
                            "#this #is #another #test"))
})

test_that("test multiple prefixes", {
  expect_equal(object = add_prefix(c("this is a test", "this is another test"), c("#", "*")),
               expected = c("#this #is #a #test", 
                            "*this *is *another *test"))
})
