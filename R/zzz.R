#' Rcpp module: FastRText
#' @name FastRText
#' @export
NULL
loadModule("FastRText", TRUE)


#' @useDynLib FastRText, .registration = TRUE
#' @importFrom Rcpp evalCpp loadModule cpp_object_initializer
#' @exportPattern "^[[:alpha:]]+"
NULL

#' Rcpp_FastRText class.
#'
#' Some details about this class and my plans for it in the body.
#'
#' @slot load Load a model
#' @slot predict Make a prediction
#' @slot execute Execute commands
#' @slot get_vectors Get vectors related to provided words
#' @slot get_parameters Get parameters used to train the model
#' @slot get_words List all words learned
#' @slot get_labels List all labels learned
#' @name Rcpp_FastRText-class

NULL

#' C++ object
#' @name C++Object-class
NULL