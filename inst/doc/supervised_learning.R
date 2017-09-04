## ----supervised_learning-------------------------------------------------
library(FastRText)

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
execute(commands = c("supervised", "-input", train_tmp_file_txt, "-output", tmp_file_model, "-dim", 20, "-lr", 1, "-epoch", 20, "-wordNgrams", 2, "-verbose", 1))

# load model
model <- load_model(tmp_file_model)

# prediction are returned as a list with words and probabilities
predictions <- predict(model, sentences = test_to_write)
print(head(predictions, 5))

# Compute accuracy
mean(sapply(predictions, names) == test_labels)

# because there is only one category by observation, hamming loss will be the same
get_hamming_loss(as.list(test_labels), predictions)

# test predictions
predictions <- predict(model, sentences = test_to_write)
print(head(predictions, 5))

# free memory
unlink(train_tmp_file_txt)
unlink(tmp_file_model)
rm(model)
gc()

