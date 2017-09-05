# The purpose of this script is to create models
# used in tests.

require(FastRText)

data("train_sentences")
data("test_sentences")

# Unsupervised
texts <- tolower(train_sentences[, "text"])
tmp_file_txt <- tempfile()
tmp_file_model <- "./data-raw/model_unsupervised_test"
writeLines(text = texts, con = tmp_file_txt)
execute(commands = c("skipgram",
                     "-input", tmp_file_txt,
                     "-output", tmp_file_model,
                     "-dim", 100,
                     "-bucket", 5e3,
                     "-epoch", 20))

# Supervised
train_labels <- paste0("__label__", train_sentences[, "class.text"])
train_texts <- tolower(train_sentences[, "text"])
train_to_write <- paste(train_labels, train_texts)
train_tmp_file_txt <- tempfile()
tmp_file_model <- "./data-raw/model_supervised_test"
writeLines(text = train_to_write, con = train_tmp_file_txt)

test_labels <- paste0("__label__", test_sentences[, "class.text"])
test_texts <- tolower(test_sentences[, "text"])
test_to_write <- paste(test_labels, test_texts)

# learn model
execute(commands =
          c("supervised", 
            "-input", train_tmp_file_txt,
            "-output", tmp_file_model, 
            "-dim", 20,
            "-lr", 1,
            "-epoch", 20, 
            "-wordNgrams", 2,
            "-bucket", 5e3))