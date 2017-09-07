loadModule("FASTRTEXT_MODULE", TRUE)

#' @name FastRText
#' @useDynLib FastRText, .registration = TRUE
#' @importFrom Rcpp evalCpp loadModule cpp_object_initializer
"_PACKAGE"

#' Rcpp_FastRText class
#'
#' Models are objects with several methods which can be called that way: model$method()
#'
#' @name Rcpp_FastRText-class
#'
#' @slot load Load a model
#' @slot predict Make a prediction
#' @slot execute Execute commands
#' @slot get_vectors Get vectors related to provided words
#' @slot get_parameters Get parameters used to train the model
#' @slot get_words List all words learned
#' @slot get_labels List all labels learned
NULL
