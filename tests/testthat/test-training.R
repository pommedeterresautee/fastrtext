context("Training and prediction")

test_that("Unsupervised training", {
  data("train_sentences")
  data("test_sentences")
  texts <- tolower(train_sentences[,"text"])
  tmp_file_txt <- tempfile()
  tmp_file_model <- tempfile()
  writeLines(text = texts, con = tmp_file_txt)
  execute(commands = c("skipgram", "-input", tmp_file_txt, "-output", tmp_file_model))
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

test_that("Supervised training", {
  data("train_sentences")
  data("test_sentences")

  # prepare data
  tmp_file_model <- tempfile()

  train_labels <- paste0("__label__", train_sentences[,"class.text"])
  train_texts <- tolower(train_sentences[,"text"])
  train_to_write <- paste(train_labels, train_texts)
  train_tmp_file_txt <- tempfile()
  writeLines(text = train_to_write, con = train_tmp_file_txt)

  test_labels <- paste0("__label__", test_sentences[,"class.text"])
  test_texts <- tolower(test_sentences[,"text"])
  test_to_write <- paste(test_labels, test_texts)

  # learn model
  execute(commands = c("supervised", "-input", train_tmp_file_txt, "-output", tmp_file_model, "-dim", 20, "-lr", 1, "-epoch", 20, "-wordNgrams", 2))

  # load model
  model <- load_model(tmp_file_model)
  predictions <- predict(model, sentences = test_to_write)
  mean(sapply(predictions, names) == test_labels)

  # test predictions
  predictions <- predict(model, sentences = test_to_write)
  expect_length(predictions, 600)
  expect_equal(unique(lengths(predictions)), 1)
  expect_equal(unique(lengths(predict(model, sentences = test_to_write, k = 2))), 2)
  expect_equal(object = mean(sapply(predictions, names) == test_labels), expected = 0.8, tolerance = 0.1)

  # test parameter extraction
  parameters <- get_parameters(model)
  expect_equal(parameters$model_name, "supervised")

  # test label extraction
  labels_from_model <- get_labels(model)
  expect_length(labels_from_model, 15)
})
