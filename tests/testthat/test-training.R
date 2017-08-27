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
  parameters <- get_parameters(model)
  expect_equal(parameters$model_name, "sg")
  get_word_vectors(model, "the")
  unlink(tmp_file_txt)
  unlink(tmp_file_model)
})

test_that("Supervised training", {

})
