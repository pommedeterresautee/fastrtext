#' Rcpp module: FastRText
#' @name FastRText
#' @export
NULL
loadModule("FastRText", TRUE)


#' @useDynLib FastRText, .registration = TRUE
#' @importFrom Rcpp evalCpp loadModule cpp_object_initializer
#' @exportPattern "^[[:alpha:]]+"
NULL
