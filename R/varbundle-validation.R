MSG <- list(
  not_list = "Must be a list.",
  valid_x = "x must be a named list or data.frame",
  not_unique = "List names must be unique.",
  no_names = "List must have named items.",
  all_names = "All list items must be named.",
  read_only = "VarBundle fields are read only.",
  not_empty = "List must not be empty",
  not_null = "Argument cannot be NULL",
  not_atomic = "Variables must be atomic.",
  only_atomic_scalar = "Only VarBundles with all atomic scalar items can be converted to data.frame",
  return_null = "Returning NULL"
)

validate_x <- function(x) {
  x %>%
    assertive::assert_is_not_null()
  if (sum(c("list", "data.frame") %in% class(x)) == 0) {
    stop(MSG$valid_x)
  }

}


validate_list <- function(ll) {
  ll %>%
    assertive::assert_is_non_empty() %>%
    assertive::assert_has_names() %>%
    names() %>%
    assertive::assert_all_are_non_empty_character() %>%
    assertive::assert_has_no_duplicates()



  # if (length(ll) == 0) {
  #   stop(MSG$not_empty)
  # }
  #
  # if (is.null(names(ll))) {
  #   stop(MSG$no_names)
  # }
  #
  # if ("" %in% names(ll)) {
  #   stop(MSG$all_names)
  # }
  #
  # if (sum(duplicated(names(ll))) > 0) {
  #   stop(MSG$not_unique)
  # }
}
