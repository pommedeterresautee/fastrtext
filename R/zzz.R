loadModule("FastRtext", TRUE)

#' @useDynLib FastRText, .registration = TRUE
#' @importFrom Rcpp evalCpp loadModule cpp_object_initializer
#' @exportPattern "^[[:alpha:]]+"
NULL
