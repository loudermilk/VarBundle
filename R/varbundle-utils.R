

#' Convert value to type
#' Casts character val to type
#' @param val (character)
#' @param type (character)
#' @return object
convert <- function(val, type) {
  conv_val <- switch (type,
                      "character" = as.character(val),
                      "numeric" = as.numeric(val),
                      "integer" = as.integer(val),
                      "logical" = as.logical(val),
                      "complex" = as.complex(val)
  )
  conv_val
}

#' @title Data.frame to List
#'
#' @description Helper function to create a list from a data.frame so that a
#' VarBundles can be created. Currently only "simple" lists can be created by
#' this method (i.e. all elements of the list are atomic scalars - no vectors,
#' lists, data.frames, etc).
#'
#' Designed to work with a persistence mechanism that allows users to easily mod
#' an external file (e.g., configuration values) to be used to instantiate
#' a VarBundle object.
#'
#' var   val   type
#' <chr> <chr> <chr>
#' 1 a   1     numeric
#' 2 b   foo   character
#' 3 c   TRUE  logical
#' 4 d   3.14  numeric
#'
#' The df must be nx3, with column headers "var", "val", "type" and all cols of type
#' character. The type col can only contain values of "character", "numeric",
#' "integer", "logical", or "complex" - this information is used to convert
#' the character values in the "val" column to the appropriate type.
#'
#' @param df (data.frame)
#' @return VarBundle
#'
df_to_list <- function(df) {
  vals <- lapply(1:nrow(df), function(i) {
    var <- df$var[i]
    val <- df$val[i]
    type <- df$type[i]

    convert(val, type)
  })
  ll <- stats::setNames(vals, df$var)
  return(ll)
}

