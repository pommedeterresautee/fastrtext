#' Load an existing fastText trained model
#'
#' Load and return a pointer to an existing model which will be used in other functions of this package.
#' @param path path to the existing model
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' @export
load_model <- function(path) {
  if (!grepl("\\.(bin|ftz)$", path)) {
    message("add .bin extension to the path")
    path <- paste0(path, ".bin")
  }
  model <- new(fastrtext)
  model$load(path)
  model
}

#' Export hyper parameters
#'
#' Retrieve hyper parameters used to train the model
#' @param model trained `fastText` model
#' @return [list] containing each parameter
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "fastrtext")
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
#' @param model trained `fastText` model
#' @return [character] containing each word
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' print(head(get_dictionary(model), 5))
#'
#' @export
get_dictionary <- function(model) {
  model$get_dictionary()
}

#' Get list of labels (supervised model)
#'
#' Get a [character] containing each label seen during training.
#' @param model trained `fastText` model
#' @return [character] containing each label
#' @importFrom assertthat assert_that
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "fastrtext")
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
#' Apply the trained  model to new sentences.
#' Average word embeddings and search most similar `label` vector.
#' @param object trained `fastText` model
#' @param sentences [character] containing the sentences
#' @param k will return the `k` most probable labels (default = 1)
#' @param simplify when [TRUE] and `k` = 1, function return a (flat) [numeric] instead of a [list]
#' @param unlock_empty_predictions [logical] to avoid crash when some predictions are not provided for some sentences because all their words have not been seen during training. This parameter should only be set to [TRUE] to debug.
#' @param ... not used
#' @return [list] containing for each sentence the probability to be associated with `k` labels.
#' @examples
#'
#' library(fastrtext)
#' data("test_sentences")
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' sentence <- test_sentences[1, "text"]
#' print(predict(model, sentence))
#'
#' @importFrom assertthat assert_that is.flag is.count
#' @export
predict.Rcpp_fastrtext <- function(object, sentences, k = 1, simplify = FALSE, unlock_empty_predictions = FALSE, ...) {
  assert_that(is.flag(simplify),
              is.count(k))
  if (simplify) assert_that(k == 1, msg = "simplify can only be used with k == 1")

  predictions <- object$predict(sentences, k)

  # check empty predictions
  if (!unlock_empty_predictions) {
    assert_that(sum(lengths(predictions) == 0) == 0,
                msg = "Some sentences have no predictions. It may be caused by the fact that all their words are have not been seen during the training.")
  }

  if (simplify) {
    unlist(predictions)
  } else {
    predictions
  }
}

#' Get word embeddings
#'
#' Return the vector representation of provided words (unsupervised training)
#' or provided labels (supervised training).
#'
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' get_word_vectors(model, c("introduction", "we"))
#'
#' @param model trained `fastText` model
#' @param words [character] of words. Default: return every word from the dictionary.
#' @return [matrix] containing each word embedding as a row and `rownames` are populated with word strings.
#' @importFrom assertthat assert_that
#' @export
get_word_vectors <- function(model, words = get_dictionary(model)) {
  assert_that(is.character(words))
  model$get_vectors(words)
}

#' Execute command on `fastText` model (including training)
#'
#' Use the same commands than the one to use for the command line.
#'
#' @param commands [character] of commands
#' @examples
#' \dontrun{
#' # Supervised learning example
#' library(fastrtext)
#'
#' data("train_sentences")
#' data("test_sentences")
#'
#' # prepare data
#' tmp_file_model <- tempfile()
#'
#' train_labels <- paste0("__label__", train_sentences[,"class.text"])
#' train_texts <- tolower(train_sentences[,"text"])
#' train_to_write <- paste(train_labels, train_texts)
#' train_tmp_file_txt <- tempfile()
#' writeLines(text = train_to_write, con = train_tmp_file_txt)
#'
#' test_labels <- paste0("__label__", test_sentences[,"class.text"])
#' test_texts <- tolower(test_sentences[,"text"])
#' test_to_write <- paste(test_labels, test_texts)
#'
#' # learn model
#' execute(commands = c("supervised", "-input", train_tmp_file_txt,
#'                      "-output", tmp_file_model, "-dim", 20, "-lr", 1,
#'                      "-epoch", 20, "-wordNgrams", 2, "-verbose", 1))
#'
#' model <- load_model(tmp_file_model)
#' predict(model, sentences = test_sentences[1, "text"])
#'
#' # Unsupervised learning example
#' library(fastrtext)
#'
#' data("train_sentences")
#' data("test_sentences")
#' texts <- tolower(train_sentences[,"text"])
#' tmp_file_txt <- tempfile()
#' tmp_file_model <- tempfile()
#' writeLines(text = texts, con = tmp_file_txt)
#' execute(commands = c("skipgram", "-input", tmp_file_txt, "-output", tmp_file_model, "-verbose", 1))
#'
#' model <- load_model(tmp_file_model)
#' dict <- get_dictionary(model)
#' get_word_vectors(model, head(dict, 5))
#' }
#' @export
execute <- function(commands) {
  model <- new(fastrtext)
  model$execute(c("fasttext", commands))
}

#' Distance between two words
#'
#' Distance is equal to `1 - cosine`
#' @param model trained `fastText` model. Null if train a new model.
#' @param w1 first word to compare
#' @param w2 second word to compare
#' @return a `scalar` with the distance
#'
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' get_word_distance(model, "time", "timing")
#'
#' @importFrom assertthat assert_that is.string
#' @export
get_word_distance <- function(model, w1, w2) {
  assert_that(is.string(w1))
  assert_that(is.string(w2))
  embeddings <- get_word_vectors(model, c(w1, w2))
  1 - crossprod(embeddings[1, ], embeddings[2, ]) /
    sqrt(crossprod(embeddings[1, ]) * crossprod(embeddings[2, ]))
}

#' Hamming loss
#'
#' Compute the hamming loss. When there is only one category, this measure the accuracy.
#' @param labels list of labels
#' @param predictions list returned by the predict command (including both the probability and the categories)
#' @return a `scalar` with the loss
#'
#' @examples
#'
#' library(fastrtext)
#' data("test_sentences")
#' model_test_path <- system.file("extdata", "model_classification_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' sentences <- test_sentences[, "text"]
#' test_labels <- test_sentences[, "class.text"]
#' predictions <- predict(model, sentences)
#' get_hamming_loss(as.list(test_labels), predictions)
#'
#' @importFrom assertthat assert_that
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

#' Print help
#'
#' Print command information, mainly to use with [execute()] `function`.
#'
#' @examples
#' \dontrun{
#' print_help()
#' }
#'
#' @export
print_help <- function() {
  model <- new(fastrtext)
  model$print_help()
  rm(model)
}

#' Get nearest neighbour vectors
#'
#' Find the `k` words with the smallest distance.
#' First execution can be slow because of precomputation.
#' Search is done linearly, if your model is big you may want to use an approximate neighbour algorithm from other R packages (like RcppAnnoy).
#'
#' @param model trained `fastText` model. Null if train a new model.
#' @param word reference word
#' @param k [integer] defining the number of results to return
#' @return [numeric] with distances with [names] as words
#'
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' get_nn(model, "time", 10)
#'
#' @importFrom assertthat assert_that is.string is.number
#' @export
get_nn <- function(model, word, k) {
  assert_that(is.string(word))
  assert_that(is.number(k))
  vec <- model$get_vector(word)
  model$get_nn_by_vector(vec, word, k)
}

#' Get analogy
#'
#' From Mikolov paper
#' Based on related move of a vector regarding a basis.
#' King is to Quenn what a man is to ???
#' w1 - w2 + w3
#' @param model trained `fastText` model. [NULL] if train a new model.
#' @param w1 1st word, basis
#' @param w2 2nd word, move
#' @param w3 3d word, new basis
#' @param k number of words to return
#' @return a [numeric] with distances and [names] are words
#' @examples
#'
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' get_analogies(model, "experience", "experiences", "result")
#'
#' @importFrom assertthat assert_that is.string is.number
#' @export
get_analogies <- function(model, w1, w2, w3, k = 1) {
  assert_that(is.string(w1))
  assert_that(is.string(w2))
  assert_that(is.string(w3))
  assert_that(is.number(k))

  vec <- model$get_vector(w1) - model$get_vector(w2) + model$get_vector(w3)
  model$get_nn_by_vector(vec, c(w1, w2, w3), k)
}

#' Add tags to documents
#'
#' Add tags in the `fastText`` format.
#' This format is require for the training step. As fastText doesn't support newlines inside documents
#' (as newlines are delimiting documents) this function also ensures that there are absolutely no
#' new lines. By default new lines are replaced by a single space.
#'
#' @param documents texts to learn
#' @param tags labels provided as a [list] or a [vector]. There can be 1 or more per document.
#' @param prefix [character] to add in front of tag (`fastText` format)
#' @return [character] ready to be written in a file
#'
#' @examples
#' library(fastrtext)
#' tags <- list(c(1, 5), 0)
#' documents <- c("this is a text", "this is another document")
#' add_tags(documents = documents, tags = tags)
#'
#' @importFrom assertthat assert_that is.string
#' @export
add_tags <- function(documents, tags, prefix = "__label__", new_lines = ' ') {
  assert_that(is.character(documents))
  assert_that(is.string(prefix))
  assert_that(length(documents) == length(tags))

  tags_to_include <- sapply(tags, FUN = function(t) paste0(prefix, t, collapse = " "))
  single_lined_documents <- gsub(x = documents, pattern = '[\\n\\r]+', replacement = new_lines, perl = TRUE)
  paste(tags_to_include, documents)
}

#' Get sentence embedding
#'
#' Sentence is splitted in words (using space characters), and word embeddings are averaged.
#'
#' @param model `fastText` model
#' @param sentences [character] containing the sentences
#' @examples
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' m <- get_sentence_representation(model, "this is a test")
#' print(m)
#' @importFrom assertthat assert_that
#' @export
get_sentence_representation <- function(model, sentences) {
  assert_that(is.character(sentences))
  model$get_sentence_embeddings(sentences)
}

#' Retrieve word IDs
#'
#' Get ID of words in the dictionary
#' @param model `fastText` model
#' @param words [character] containing words to retrieve IDs
#' @return [numeric] of ids
#' @examples
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' ids <- get_word_ids(model, c("this", "is", "a", "test"))
#'
#' # print positions
#' print(ids)
#' # retrieve words in the dictionary using the positions retrieved
#' print(get_dictionary(model)[ids])
#' @importFrom assertthat assert_that
#' @export
get_word_ids <- function(model, words) {
  assert_that(is.character(words))
  model$get_word_ids(words)
}

#' Tokenize text
#'
#' Separate words in a text using space characters
#' @param model `fastText` model
#' @param texts a [character] containing the documents
#' @return a [list] of [character] containing words
#' @examples
#' library(fastrtext)
#' model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
#' model <- load_model(model_test_path)
#' tokens <- get_tokenized_text(model, "this is a test")
#' print(tokens)
#' tokens <- get_tokenized_text(model, c("this is a test 1", "this is a second test!"))
#' print(tokens)
#' @importFrom assertthat assert_that is.string
#' @export
get_tokenized_text <- function(model, texts){
  assert_that(is.character(texts))
  lapply(texts, FUN = function(text) model$tokenize(text))
}

globalVariables(c("new"))


#' Build fasttext vectors
#' 
#' Trains a fasttext vector/unsupervised model following method described in 
#' \href{https://arxiv.org/abs/1607.04606}{Enriching Word Vectors with Subword Information}
#' using the \href{https://fasttext.cc/}{fasttext} implementation.
#' 
#' See \href{https://fasttext.cc/docs/en/unsupervised-tutorial.html} for more information on 
#' training unsupervised models using fasttext
#'
#' @param documents character vector of documents used for training
#' @param model_path Name of output file *without* file extension.
#' @param modeltype Should training be done using skipgram or cbow? Defaults to skipgram.
#' @param bucket number of buckets 
#' @param dim size of word vectors 
#' @param epoch number of epochs 
#' @param label text string, labels prefix. Default is "__label__"
#' @param loss loss function {ns, hs, softmax} 
#' @param lr learning rate 
#' @param lrUpdateRate change the rate of updates for the learning rate 
#' @param maxn max length of char ngram 
#' @param minCount minimal number of word occurences 
#' @param minn min length of char ngram 
#' @param neg number of negatives sampled 
#' @param t sampling threshold 
#' @param thread number of threads 
#' @param verbose verbosity level
#' @param wordNgrams max length of word ngram 
#' @param ws size of the context window 
#'
#' @return path to model file, as character
#' @export
#'
#' @examples
#' library(fastrtext)
#' text <- train_sentences
#' model_file <- build_vectors(text[['text']], 'my_model')
#' model <- load_model(model_file)

build_vectors <- function(documents, model_path,
                          modeltype = c('skipgram', 'cbow'),                          
                          bucket = 2000000,
                          dim = 100,
                          epoch = 5,
                          label = "__label__",
                          loss = c('ns', 'hs', 'softmax'),
                          lr = 0.05,
                          lrUpdateRate = 100,
                          maxn = 6,
                          minCount = 5,
                          minn = 3,
                          neg = 5,
                          t = 1e-4,
                          thread = 12,
                          verbose = 2,
                          wordNgrams = 1,
                          ws = 5
) {
  
  # ensure modeltype only takes valid values as defined in function definition. https://stackoverflow.com/a/4684604
  modeltype <- match.arg(modeltype)
  loss <- match.arg(loss)
  args <- as.list(environment())
  
  tmp_file_txt <- tempfile()
  
  message("writing tempfile at ... ", tmp_file_txt)
  writeLines(text = documents, con = tmp_file_txt)
  
  #Build character vector containing all fasttext arguments
  c_args <- args[-1:-3] #First 3 args are not named arguments for our fasttext command
  commands <- c(modeltype,
                "-input", tmp_file_txt,
                "-output", model_path,
                # build name/value pairs for each named argument
                rbind(
                  paste0('-', names(c_args)),
                  format(c_args, scientific = FALSE)
                )
  )
  
  message("Starting training vectors with following commands: \n$ ", paste(commands, collapse=" "), "\n\n")
  fastrtext::execute(commands = commands)
  
  unlink(tmp_file_txt)
  return(paste0(model_path, '.bin'))
}


#' Build a supervised fasttext model
#'
#' Trains a supervised model, following the method layed out in 
#' \href{https://arxiv.org/abs/1607.01759}{Bag of Tricks for Efficient Text Classification} 
#' using the \href{https://fasttext.cc/}{fasttext} implementation
#' 
#' See \href{https://fasttext.cc/docs/en/supervised-tutorial.html} for more information on 
#' training supervised models using fasttext
#'
#' @param documents character vector of documents used for training
#' @param targets vector of targets/catagory of each document. Must have same length as `documents` and be coercable to character
#' @param model_path Name of output file *without* file extension.
#' @param bucket number of buckets 
#' @param wordNgrams max length of word ngram 
#' @param minCount minimal number of word occurences 
#' @param minCountLabel minimal number of label occurences 
#' @param maxn max length of char ngram 
#' @param minn min length of char ngram 
#' @param t sampling threshold 
#' @param lr learning rate 
#' @param lrUpdateRate change the rate of updates for the learning rate 
#' @param dim size of word vectors 
#' @param ws size of the context window 
#' @param epoch number of epochs 
#' @param neg number of negatives sampled 
#' @param loss = c('softmax', 'ns', 'hs'), loss function {ns, hs, softmax} 
#' @param thread number of threads 
#' @param pretrainedVectors path to pretrained word vectors for supervised learning. Leave empty for no pretrained vectors.
#'
#' @return path to new model file as a `character`
#' @export
#'
#' @examples
#'\dontrun{
#' library(fastrtext)
#' text <- train_sentences
#' model_file <- build_supervised(text[["text"]], text[["class.text"]], 'my_model', dim = 20, lr = 1, epoch = 20, wordNgrams = 2)
#' model <- load_model(model_file)
#' 
#' predictions <- predict(model, test_sentences[["text"]])
#' mean(sapply(predictions, names) == test_sentences[["class.text"]])
#' # ~0.8
#' }
build_supervised <- function(documents, targets, model_path,
                             # default arguments for fasttext, as seen by running `fasttext supervised` in bash
                             lr = 0.05,
                             dim = 100,
                             ws = 5,
                             epoch = 5,
                             minCount = 5,
                             minCountLabel = 0,
                             neg = 5,
                             wordNgrams = 1,
                             loss = c('ns', 'hs', 'softmax'),
                             bucket = 2000000,
                             minn = 3,
                             maxn = 6,
                             thread = 12,
                             lrUpdateRate = 100,
                             t = 1e-4,
                             label = "__label__",
                             verbose = 2,
                             pretrainedVectors = NULL
) {
  
  #Check that all arguments are correct and load them all into a list
  modeltype = "supervised"
  loss <- match.arg(loss)
  if (!is.character(pretrainedVectors)) rm(pretrainedVectors)
  args <- as.list(environment())
  
  # get input / output file paths
  tmp_file_txt <- tempfile()
  
  
  message("Prepare and write tempfile at ... ", tmp_file_txt)
  # We need 1 document per line and to prepend each line with '__label__' + label name
  prepared_docs <- add_tags(documents, tags = targets, prefix = label)
  writeLines(text = prepared_docs, 
             con = tmp_file_txt)
  
  #Build character vector containing all fasttext arguments
  c_args <- args[-1:-4] #First 4 args values are not to be used as named function arguments (modeltype, documents ...)
  commands <- c(modeltype,
                "-input", tmp_file_txt,
                "-output", model_path,
                # build name/value pairs for each named argument
                rbind(
                  paste0('-', names(c_args)),
                  format(c_args, scientific = FALSE)
                )
  )  
  
  message("Starting supervised training with following commands: \n$ ", paste(commands, collapse = " "), "\n\n")
  fastrtext::execute(commands = commands)
  
  unlink(tmp_file_txt)
  return(paste0(model_path, '.bin'))
}
