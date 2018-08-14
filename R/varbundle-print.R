# Given a string, indent every line by some number of spaces.
# The exception is to not add spaces after a trailing \n.
indent <- function(str, indent = 0) {
  gsub("(^|\\n)(?!$)",
       paste0("\\1", paste(rep(" ", indent), collapse = "")),
       str,
       perl = TRUE
  )
}

# Trim a string to n characters; if it's longer than n, add " ..." to the end
trim <- function(str, n = 60) {
  if (nchar(str) > n) paste(substr(str, 1, n-4), "...")
  else str
}

# Return a summary string of the items of a list or environment
# x must be a list or environment
object_summaries <- function(x, exclude = NULL) {
  if (length(x) == 0)
    return(NULL)

  if (is.list(x))
    obj_names <- names(x)
  else if (is.environment(x))
    obj_names <- ls(x, all.names = TRUE)

  obj_names <- setdiff(obj_names, exclude)

  values <- vapply(obj_names, function(name) {
    if (is.environment(x) && bindingIsActive(name, x)) {
      "active binding"
    } else {
      obj <- .subset2(x, name)
      if (is.function(obj)) deparse(args(obj))[[1L]]
      # Plain environments (not envs with classes, like R6 or RefClass objects)
      else if (is.environment(obj) && identical(class(obj), "environment")) "environment"
      else if (is.null(obj)) "NULL"
      else if (is.atomic(obj)) trim(paste(as.character(obj), collapse = " "))
      else paste(class(obj), collapse = ", ")
    }
  }, FUN.VALUE = character(1))

  paste0(obj_names, ": ", values, sep = "")
}

extract_field_names <- function(x) {
  what <- NULL
  var <- NULL

  active_binding <- "active binding"

  pub_sum <- object_summaries(x, exclude = ".__enclos_env__")
  m <- stringr::str_split(pub_sum, ":", simplify = TRUE)
  colnames(m) <- c("var", "what")
  pub_df <- tibble::as_tibble(m)

  pub_df %>%
    filter(grepl(active_binding, what)) %>%
    pull(var)
}

extract_field_vals <- function(x, field_names) {
  val <- NULL
  var <- NULL
  private <- .subset2(.subset2(x, ".__enclos_env__"), "private")
  if (!is.null(private)) {
    priv_sum <- object_summaries(private)
    m <- stringr::str_split(priv_sum, ":", simplify = TRUE)
    colnames(m) <- c("var", "val")
    priv_df <- tibble::as_tibble(m)

    priv_df %>%
      filter(var %in% paste0(".", field_names)) %>%
      pull(val) %>%
      trimws()
  } else {
    NULL
  }
}

#' @export
names.VarBundle <- function(x) {
  extract_field_names(x)
}


format.VarBundle <- function(x, ...) {


  if (is.function(.subset2(x, "format"))) {
    .subset2(x, "format")(...)
  } else {
    ret <- paste0("<", class(x)[1], ">")

    # If there's another class besides first class and R6
    classes <- setdiff(class(x), "R6")
    if (length(classes) >= 2) {
      ret <- c(ret, paste0("  Inherits from: <", classes[2], ">"))
    }

    field_names <- extract_field_names(x)
    field_vals <- extract_field_vals(x, field_names)

    ret <- c(ret,
             "  Fields:",
             indent(paste(field_names, field_vals, sep = " : "), 4))

    paste(ret, collapse = "\n")
  }
}

#' @export
print.VarBundle <- function(x, ...) {
  ret <- format.VarBundle(x, ...)
  cat(ret)
}
