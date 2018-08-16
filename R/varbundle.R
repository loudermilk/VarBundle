#' VarBundle: A package for creating read-only variable bundles.
#'
#' @section VarBundle functions:
#' Function \code{\link{varbundle}} - Creates VarBundle object from named list
#' or data.frame.
#'
#' @docType package
#' @name VarBundle
#' @importFrom magrittr "%>%"
#' @import dplyr
#' @import crayon
NULL


#' @title Create bundle of variables.
#'
#' @description VarBundle objects store read-only variables in a list-like
#' structure. Variable values can be accessed via the `$` operator
#' (\code{vb$foobar}) or via field name(\code{vb[["foobar"]]}).
#' After a VarBundle object has been created, new fields cannot be added
#' and existing field values cannot be modified.
#'
#' Field names can be accessed via \code{\link{field_names}}.
#'
#' Simple VarBundle objects that only contain atomic, scalar values are
#' useful for storing configuration information. The object method
#' \code{$as.data.frame()} will return a data.frame version of the VarBundle.
#' This can be persisted to disk and subsequently modified by the end user
#' to change system parameters.
#'
#'
#' @param x (list or data.frame)
#' @return (VarBundle)
#'
#' @examples
#' # Access via $
#' sales <- varbundle(list(min = 1, max = 10))
#' sales$min
#'
#' # Access via name
#' my_var <- field_names(sales)[1]
#' sales[[my_var]]
#'
#' # Create data.frame
#' df <- sales$as.data.frame()
#'
#' # Create VarBundle from data.frame
#' corp_sales <- varbundle(df)
#' class(corp_sales)
#'
#' @export
#'
varbundle <- function(x) {
  ## No visible bindings resolved
  private <- NULL



  validate_x(x)

  if (is.data.frame(x)) {
    x <- df_to_list(x)
  }

  validate_list(x)

  VarBundle <- R6::R6Class("VarBundle")

  all_scalar_atomic <- TRUE

  ## Create private$.foo and active$foo(val) pairs for read-only access
  for (i in 1:length(x)) {

    if (!purrr::is_scalar_atomic(x[[i]])) {all_scalar_atomic <- FALSE}

    mthd_name <- names(x)[i]
    mthd_def <- glue::glue("function(value) {{
                            if (missing(value)) {{
                              private$.{mthd_name}
                            }} else {{
                              stop(MSG$read_only)
                            }}
                           }}")
    VarBundle$set("private", glue::glue(".{mthd_name}"), x[[i]])
    VarBundle$set("active", mthd_name, eval(parse(text = mthd_def)))
  }

  if (all_scalar_atomic) {
    create_df <- function(i) {
      var <- names(x)[i]
      val <- x[[i]]
      type <- class(val)
      is_scalar_atomic <- purrr::is_scalar_atomic(val)
      tibble::tibble(var, val, type)
    }
    df <- do.call(rbind, lapply(1:length(x), create_df))
  } else {
    df <- NULL
  }

  ## PUBLIC --------------------------------------------------------------------


  # Transform simple VarBundle to data.frame
  VarBundle$set("public", "as.data.frame", function() {
    if (is.null(private$.df_rep)) {
      warning(MSG$only_atomic_scalar)
      warning(MSG$return_null)
    }
    private$.df_rep
  })


  ## PRIVATE -------------------------------------------------------------------

  # If vb is simple store a data.frame representation
  VarBundle$set("private", ".df_rep", df)

  vb <- VarBundle$new()
  return(vb)
}
