#' Load an existing Fasttext trained model
#'
#' Load and return a pointer to an existing model which will be used in other functions of this package.
#' @param path path to the existing model
#' @examples
#'
#' library(FastRText)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")
#' model <- load_model(model_test_path)
#'
#' @export
load_model <- function(path) {
  if (!grepl("\\.bin$", path)) {
    path <- paste0(path, ".bin")
  }
  model <- new(FastRText)
  model$load(path)
  model
}

#' Export hyper parameters
#'
#' Get hyper paramters used to train the model
#' @param model trained fasttext model
#' @examples
#'
#' library(FastRText)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")
#' model <- load_model(model_test_path)
#' print(head(get_parameters(model), 5))
#'
#' @export
get_parameters <- function(model) {
  model$get_parameters()
}

#' Get list of known words
#'
#' Get a [character] containing each word seen during training.
#' @param model trained Fasttext model
#' @examples
#'
#' library(FastRText)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")
#' model <- load_model(model_test_path)
#' print(head(get_dictionary(model), 5))
#'
#' @export
get_dictionary <- function(model) {
  model$get_words()
}

#' Get list of labels (supervised model)
#'
#' Get a [character] containing each label seen during training.
#' @param model trained Fasttext model
#' @importFrom assertthat assert_that
#' @examples
#'
#' library(FastRText)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")
#' model <- load_model(model_test_path)
#' print(head(get_labels(model), 5))
#'
#' @export
get_labels <- function(model) {
  param <- model$get_parameters()
  assert_that(param$model_name == "supervised",
              msg = "This is not a supervised model.")
  model$get_labels()
}

#' Get predictions (for supervised model)
#'
#' Return probabilities for the sentences to be associated with K labels.
#' @param object trained Fasttext model
#' @param sentences [character] containing the sentences
#' @param k will return the k most probable labels (default = 1)
#' @param ... not used
#' @examples
#'
#' library(FastRText)
#' data("test_sentences")
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")
#' model <- load_model(model_test_path)
#' sentence <- test_sentences[1, "text"]
#' print(predict(model, sentence))
#'
#' @export
predict.Rcpp_FastRText <- function(object, sentences, k = 1, ...) {
  object$predict(sentences, k)
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
#' @export
execute <- function(model = NULL, commands) {
  if (is.null(model)) {
    model <- new(FastRText)
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
  embeddings <- get_word_vectors(model, c(w1, w2) )
  1 - crossprod(embeddings[[1]], embeddings[[2]]) /
    sqrt(crossprod(embeddings[[1]]) * crossprod(embeddings[[2]]))
}

#' Hamming loss
#'
#' Compute the hamming loss. When there is only one category, this measure the accuracy.
#' @param labels list of labels
#' @param predictions list returned by the predict command (including both the probability and the categories)
#' @importFrom assertthat assert_that
#' @examples
#'
#' library(FastRText)
#' data("test_sentences")
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")
#' model <- load_model(model_test_path)
#' sentences <- test_sentences[, "text"]
#' test_labels <- test_sentences[, "class.text"]
#' predictions <- predict(model, sentences)
#' get_hamming_loss(as.list(test_labels), predictions)
#'
#' @export
get_hamming_loss <- function(labels, predictions) {
  diff <- function(a, b) {
    common <- union(a, b)
    difference <- setdiff(union(a, b), intersect(a, b))
    distance <- length(difference) / length(common)
    1 - distance
  }
  assert_that(is.list(labels))
  assert_that(is.list(predictions))
  assert_that(length(labels) == length(predictions))
  prediction_categories <- lapply(predictions, names)
  mean(mapply(diff, prediction_categories, labels, USE.NAMES = FALSE))
}

globalVariables(c("new"))
