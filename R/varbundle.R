#' @title Create bundle of variables.
#'
#' @description VarBundle objects are designed to store related
#' read-only variable/value pairs that are accessed with the `$` operator
#' like the attributes of a list (e.g., \code{vb$foobar}. Unlike a list,
#' after a VarBundle object has been created new fields cannot be added,
#' nor can existing field values be modified. VarBundle objects avoid the
#' overhead of copy-on-modify and pass-by-value semantics.
#'
#' VarBundle objects are particularly useful for storing information that
#' needs to be accessed by multiple client functions while insuring information
#' immutability and consistency across your code base.
#'
#' @param x (list or data.frame) named list of var/val pairs (e.g., list(foo = 1))
#' @return (VarBundle)
#'
#' @examples
#' x <- 7
#' sales <- varbundle(list(min = 1, max = 10))
#' if (x >= sales$min & x <= sales$max) "good" else "bad"
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

  if(all_scalar_atomic) {
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

  # Return number of read-only fields
  VarBundle$set("public", "length", function() length(VarBundle$active))



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
