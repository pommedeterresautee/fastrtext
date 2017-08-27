#' Load an existing Fasttext trained model
#'
#' Load and return a pointer to an existing model which will be used in other functions of this package.
#' @param path path to the existing model
#' @export
load_model <- function(path) {
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

#' Get word embedding
#'
#' Return the vector representation of a word (unsupervised training)
#' or a label (supervised training).
#' @param model trained Fasttext model
#' @param words [character] of words
#' @export
get_word_vector <- function(model, words) {
  model$get_vectors(words)
}

#' Execute command on Fasttext model (including training)
#'
#' Use the same commands than the one to use for the command line.
#' @param model trained Fasttext model. Null if train a new model.
#' @param path path to an existing model. Null id command to be applied to an existing model.
#' @param commands [character] of commands
#' @export
execute <- function(model = NULL, path = NULL, commands) {
  assert_that(is.null(model) + is.null(path) == 1,
              msg = "Use model OR path but not both or none.")
  model <- new(FastRtext)
  if (!is.null(path)) {
    model$load(path)
  }
  model$execute(commands)
  model
}




