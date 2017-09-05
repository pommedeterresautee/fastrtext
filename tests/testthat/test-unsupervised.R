context("Unsupervised training")

model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "FastRText")

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
                       "-thread", 1,
                       "-dim", 50,
                       "-bucket", 1e3,
                       "-epoch", 20))
  model <- load_model(tmp_file_model)
  parameters <- get_parameters(model)
  expect_equal(parameters$model_name, "sg")
})

test_that("Test parameter extraction", {
  model <- load_model(model_test_path)
  parameters <- get_parameters(model)
  expect_equal(parameters$dim, 100)
  expect_equal(parameters$model_name, "sg")
})
  
test_that("Test word extraction", {
  model <- load_model(model_test_path)
  dict <- get_dictionary(model)
  expect_length(dict, 2061)
  expect_true("time" %in% dict)
  expect_true("timing" %in% dict)
  expect_true("experience" %in% dict)
  expect_true("section" %in% dict)
})

test_that("Test word embeddings", {
  model <- load_model(model_test_path)
  
  # test vector lentgh
  parameters <- get_parameters(model)
  expect_length(get_word_vectors(model, "time")[[1]], parameters$dim)

  # test word distance
  expect_lt(get_word_distance(model, "time", "timing"), get_word_distance(model, "experience", "section"))
})

gc()