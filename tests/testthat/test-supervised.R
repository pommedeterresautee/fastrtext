context("Supervised training")

data("train_sentences")
data("test_sentences")

test_labels <- paste0("__label__", test_sentences[, "class.text"])
test_texts <- tolower(test_sentences[, "text"])
test_sentences_with_labels <- paste(test_labels, test_texts)

model_test_path <- system.file("extdata", "model_classification_test.bin", package = "FastRText")

test_that("Training of a classification model", {
  # prepare data
  tmp_file_model <- tempfile()
  tmp_file_model_quantize <- tempfile()

  train_labels <- paste0("__label__", train_sentences[, "class.text"])
  train_texts <- tolower(train_sentences[, "text"])
  train_to_write <- paste(train_labels, train_texts)
  train_tmp_file_txt <- tempfile()
  writeLines(text = train_to_write, con = train_tmp_file_txt)

  # learn model
  execute(commands =
            c("supervised", "-input", train_tmp_file_txt,
              "-output", tmp_file_model, "-dim", 20, "-lr", 1,
              "-epoch", 20, "-wordNgrams", 2, "-verbose", 0, "-thread", 1))
  learned_model <- load_model(tmp_file_model)
  parameters <- get_parameters(learned_model)
  expect_equal(parameters$model_name, "supervised")
  learned_model_predictions <- predict(learned_model, sentences = test_sentences_with_labels)

  # Compare with embedded model
  embedded_model <- load_model(model_test_path)
  embedded_model_predictions <- predict(embedded_model, sentences = test_sentences_with_labels)
  expect_gt(mean(names(unlist(learned_model_predictions)) == names(unlist(embedded_model_predictions))), 0.75)

  # Compare with quantize model
  # execute(commands = c("quantize", "-output", tmp_file_model_quantize, "-input", tmp_file_model, "-qnorm", "-retrain", "-epoch", "1", "-cutoff", "100000"))
})

test_that("Test predictions", {
  model <- load_model(model_test_path)
  predictions <- predict(model, sentences = test_sentences_with_labels)

  # test measure (for 1 class, hamming == accuracy)
  expect_equal(get_hamming_loss(as.list(test_labels), predictions), mean(sapply(predictions, names) == test_labels))

  predictions <- predict(model, sentences = test_sentences_with_labels)
  expect_length(predictions, 600)
  expect_equal(unique(lengths(predictions)), 1)
  expect_equal(unique(lengths(predict(model,
                                      sentences = test_sentences_with_labels,
                                      k = 2))), 2)
  expect_equal(object = mean(sapply(predictions, names) == test_labels),
               expected = 0.8, tolerance = 0.1)
})

test_that("Test parameter extraction", {
  model <- load_model(model_test_path)
  parameters <- get_parameters(model)
  expect_equal(parameters$model_name, "supervised")
})

test_that("Test label extraction", {
  model <- load_model(model_test_path)
  labels_from_model <- get_labels(model)
  expect_length(labels_from_model, 15)
})

gc()
