context("Supervised training")

test_that("Training of a classification model", {
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
  execute(commands = c("supervised", "-input", train_tmp_file_txt, "-output", tmp_file_model, "-dim", 20, "-lr", 1, "-epoch", 20, "-wordNgrams", 2, "-verbose", 0, "-thread", 1))

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

  # free memory
  unlink(train_tmp_file_txt)
  unlink(tmp_file_model)
  rm(model)
  gc()
})
