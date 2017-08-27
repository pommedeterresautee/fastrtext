#' Load an existing Fasttext trained model
#'
#' Load and return a pointer to an existing model which will be used in other functions of this package.
#' @param path path to the existing model
#' @export
load_model <- function(path) {
  if (!grepl("\\.bin$", path)) {
    path <- paste0(path, ".bin")
  }
  model <- new(FastRtext)
  model$load(path)
  model
}

#' Export hyper parameters
#'
#' Get hyper paramters used to train the model
#' @param model trained fasttext model
#' @export
get_parameters <- function(model) {
  model$get_parameters()
}

#' Get list of known words
#'
#' Get a [character] containing each word seen during training.
#' @param model trained Fasttext model
#' @export
get_dictionary <- function(model) {
  model$get_words()
}

#' Get predictions (for supervised model)
#'
#' Return probabilities for the sentences to be associated with K labels.
#' @param model trained Fasttext model
#' @param sentences [character] containing the sentences
#' @param k will return the k most probable labels (default = 1)
predict <- function(model, sentences, k = 1) {
  model$predict(sentences, k)
}

#' Get word embeddings
#'
#' Return the vector representation of provided words (unsupervised training)
#' or provided labels (supervised training).
#' @param model trained Fasttext model
#' @param words [character] of words
#' @export
get_word_vectors <- function(model, words) {
  model$get_vectors(words)
}

#' Execute command on Fasttext model (including training)
#'
#' Use the same commands than the one to use for the command line.
#' @param model trained Fasttext model. Null if train a new model.
#' @param commands [character] of commands
#' @importFrom assertthat assert_that
#' @export
execute <- function(model = NULL, commands) {
  if (is.null(model)) {
    model <- new(FastRtext)
  }
  model$execute(c("fasttext", commands))
  invisible(model)
}

#' Distance between two words
#'
#' Distance is equal to `1 - cosine`
#' @param model trained Fasttext model. Null if train a new model.
#' @param w1 first word to compare
#' @param w2 second word to compare
#' @importFrom assertthat assert_that is.string
#' @export
get_word_distance <- function(model, w1, w2) {
  assert_that(is.string(w1))
  assert_that(is.string(w2))
  embeddings <- get_word_vectors(model, c(w1, w2))
  1 - crossprod(embeddings[[1]], embeddings[[2]])/sqrt(crossprod(embeddings[[1]]) * crossprod(embeddings[[2]]))
}

globalVariables(c("new"))
