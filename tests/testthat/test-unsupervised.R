context("Unsupervised training")

test_that("Training and extraction of word embeddings", {
  data("train_sentences")
  data("test_sentences")
  texts <- tolower(train_sentences[, "text"])
  tmp_file_txt <- tempfile()
  tmp_file_model <- tempfile()
  writeLines(text = texts, con = tmp_file_txt)
  try(execute(commands = c("skipgram",
                           "-input", tmp_file_txt,
                           "-output", tmp_file_model,
                           "-verbose", 0,
                           "-thread", 1)))
  model <- load_model(tmp_file_model)

  # test parameter extraction
  parameters <- get_parameters(model)
  expect_equal(parameters$model_name, "sg")
  expect_equal(parameters$dim, 100)

  # test word extraction
  dict <- get_dictionary(model)
  expect_length(dict, 2061)
  expect_true("time" %in% dict)
  expect_true("timing" %in% dict)
  expect_true("experience" %in% dict)
  expect_true("section" %in% dict)

  # test vector lentgh
  expect_length(get_word_vectors(model, "time")[[1]], parameters$dim)

  # test word distance
  expect_lt(get_word_distance(model, "time", "timing"), 0.05)
  expect_gt(get_word_distance(model, "experience", "section"), 0.2)

  # free memory
  unlink(tmp_file_txt)
  unlink(tmp_file_model)
  rm(model)
  gc()
})
