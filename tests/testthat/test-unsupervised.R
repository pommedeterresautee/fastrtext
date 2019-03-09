context("Unsupervised training")

model_test_path <- system.file("extdata",
                               "model_unsupervised_test.bin",
                               package = "fastrtext")

test_that("Training", {
  data("train_sentences")
  data("test_sentences")
  texts <- tolower(train_sentences[, "text"])
  tmp_file_txt <- tempfile()
  tmp_file_model <- tempfile()
  writeLines(text = texts, con = tmp_file_txt)
  execute(commands = c("skipgram",
                       "-input", tmp_file_txt,
                       "-output", tmp_file_model,
                       "-verbose", 0,
                       "-dim", 10,
                       "-bucket", 1e3,
                       "-loss", "ns",
                       "-epoch", 3))

  # Check learned file exists
  expect_true(file.exists(paste0(tmp_file_model, ".bin")))
  expect_true(file.exists(paste0(tmp_file_model, ".vec")))

  model <- load_model(tmp_file_model)
  parameters <- get_parameters(model)
  expect_equal(parameters$model_name, "sg")

  build_vectors(documents = texts,
                model_path = tmp_file_model,
                modeltype = "skipgram",
                bucket = 1e3,
                dim = 10,
                epoch = 3,
                loss = "softmax",
                verbose = 0)

})

test_that("Test parameter extraction", {
  model <- load_model(model_test_path)
  parameters <- get_parameters(model)
  expect_equal(parameters$dim, 70)
  expect_equal(parameters$model_name, "sg")
})

test_that("Test word extraction and word IDs", {
  model <- load_model(model_test_path)
  dict <- get_dictionary(model)
  expect_length(dict, 2061)
  expect_true("time" %in% dict)
  expect_true("timing" %in% dict)
  expect_true("experience" %in% dict)
  expect_true("section" %in% dict)

  sentence_to_test <- c("this", "is", "a", "test")
  ids <- get_word_ids(model, sentence_to_test)
  expect_equal(get_dictionary(model)[ids], sentence_to_test)
})

test_that("Tokenization separate words in a text document", {
  model <- load_model(model_test_path)
  tokens <- get_tokenized_text(model, "this is a test")
  expect_equal(tokens, list(c("this", "is", "a", "test")))
})

test_that("Test word embeddings", {
  model <- load_model(model_test_path)

  # test vector lentgh
  parameters <- get_parameters(model)
  expect_length(get_word_vectors(model, "time")[1, ], parameters$dim)

  # test word distance
  expect_lt(get_word_distance(model, "introduction", "conclusions"),
            get_word_distance(model, "experience", "section"))
  expect_lt(get_word_distance(model, "our", "we"),
            get_word_distance(model, "introduction", "conclusions"))
})

test_that("Nearest neighbours", {
  model <- load_model(model_test_path)
  nn <- get_nn(model, "time", 10)
  expect_true("times" %in% names(nn))
})

test_that("Test sentence representation", {
  model <- load_model(model_test_path)
  m <- get_sentence_representation(model, "this is a test")
  expect_length(m, 70)
  expect_equal(nrow(m), 1)
  m <- get_sentence_representation(model, c("this is a test", "and here is another"))
  expect_equal(nrow(m), 2)
  expect_false(any(is.na(m)))
})

gc()
