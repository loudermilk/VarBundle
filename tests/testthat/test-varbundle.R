
# vb has same values as list ll
same_vals_test <- function(vb, ll) {
  skip_if_not_installed("purrr")

  purrr::walk(1:length(ll), function(i) {
    info <- glue::glue("iteration = {i}")
    testthat::expect_equal(ll[[i]], vb[[names(ll)[i]]], info = info)
  })
}

# vb has values with same class as ll
same_val_classes_test <- function(vb, ll) {
  skip_if_not_installed("purrr")

  purrr::walk(1:length(ll), function(i) {
    info <- glue::glue("iteration = {i}")
    testthat::expect_equal(class(ll[[i]]), class(vb[[names(ll)[i]]]), info = info)
  })
}

context("Testing classes of VarBundle")

testthat::test_that("is R6", {
  vb <- varbundle(list(a = 1))
  testthat::expect_is(vb, "R6")
})

testthat::test_that("is VarBundle", {
  vb <- varbundle(list(a = 1))
  testthat::expect_is(vb, "VarBundle")
})


context("Testing VarBundle with list constructor")

testthat::test_that("has same vals as list", {
  ll <- list(min = 100, sample_perc = 0.3, file = "bar", debug = FALSE)
  vb <- varbundle(ll)
  same_vals_test(vb, ll)
})

testthat::test_that("has vals with same classes as list", {
  ll <- list(min = 100, sample_perc = 0.3, file = "bar", debug = FALSE)
  vb <- varbundle(ll)
  same_val_classes_test(vb, ll)
})


testthat::test_that("has same var names as list", {
  ll <- list(min = 100, sample_perc = 0.3, file = "bar", debug = FALSE)
  vb <- varbundle(ll)
  testthat::expect_equal(sum(names(ll) %in% names(vb)), length(ll))
})

testthat::test_that("field names", {
  ll <- list(a = 1, b = 2, c = 3)
  vb <- varbundle(ll)
  testthat::expect_identical(field_names(vb), names(ll))
  testthat::expect_named(vb)
})


context("Testing errors thrown with list constructor")

testthat::test_that("throws error on list w/ missing names", {
  ll <- list(100, sample_perc = 0.3, file = "bar", debug = FALSE)
  testthat::expect_error(vb <- varbundle(ll),
    regexp = MSG$all_names
  )
})

testthat::test_that("throws error on list w/ no names", {
  ll <- list(100, 0.3, "bar", FALSE)
  testthat::expect_error(vb <- varbundle(ll),
    regexp = MSG$no_names
  )
})


testthat::test_that("throws error on non-unique names", {
  ll <- list(foo = 1, bar = 2, bar = 3)
  testthat::expect_error(vb <- varbundle(ll),
    regexp = MSG$not_unique
  )
})


testthat::test_that("not list", {
  ll <- c(foo = 1, bar = 2, bar = 3)
  testthat::expect_error(vb <- varbundle(ll),
                         regexp = MSG$valid_x
  )
})


testthat::test_that("throws error on empty list", {
  ll <- list()
  testthat::expect_error(vb <- varbundle(ll),
    regexp = MSG$not_empty
  )
})


testthat::test_that("throws error on NULL", {
  ll <- NULL
  testthat::expect_error(vb <- varbundle(ll),
    regexp = MSG$not_null
  )
})

context("Testing throws error on mutation")

testthat::test_that("read only fields", {
  ll <- list(foo = 1, bar = 2)
  vb <- varbundle(ll)
  testthat::expect_error(vb$foo <- 5,
                         regexp = MSG$read_only
  )
})

testthat::test_that("can't add field", {
  ll <- list(foo = 1, bar = 2)
  vb <- varbundle(ll)
  testthat::expect_error(vb$hello <- 5)
})


context("Testing VarBundle handles different element types")

testthat::test_that("handles NA as vals", {
  ll <- list(foo = 1, bar = NA)
  vb <- varbundle(ll)
  testthat::expect_true(is.na(vb$bar))
  same_vals_test(vb, ll)
  same_val_classes_test(vb, ll)
})


testthat::test_that("handles atomic vectors with > 1 items", {
  vec <- c("my", "dog", "has", "fleas")
  ll <- list(a = 1, b = 2, vec = vec)
  vb <- varbundle(ll)
  testthat::expect_equal(vb$vec, vec)
  same_vals_test(vb, ll)
  same_val_classes_test(vb, ll)
})

testthat::test_that("handles non-atomic list items", {
  df <- data.frame(foo = 1:5)
  ll <- list(a = 1, b = 2, my_df = df)
  vb <- varbundle(ll)
  testthat::expect_equal(vb$my_df, df)
  same_vals_test(vb, ll)
  same_val_classes_test(vb, ll)
})

testthat::test_that("handles nested varbundles", {
  sales <- varbundle(list(min = 100, max = 10000))
  units <- varbundle(list(min = 10, max = 50))
  ll <- list(sales = sales, units = units)
  thresholds <- varbundle(ll)
  same_vals_test(thresholds, ll)
  same_val_classes_test(thresholds, ll)
  testthat::expect_reference(thresholds$sales, sales)
})

