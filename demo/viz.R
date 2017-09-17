library(fastrtext)
library(irlba)
library(magrittr)

model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
model <- load_model(model_test_path)
#model <- load_model("/home/geantvert/workspace/justice-data/ML/models/fasttext/wiki.fr.bin")
dict <- get_dictionary(model) %>% head(1e4)
word_embeddings <- get_word_vectors(model, dict)
pca <- irlba(word_embeddings, nv = 2)
coord <- data.frame(pca$u)
colnames(coord) <- c("x", "y")
coord$word <- dict


library(ggvis)
tooltip_test <- function(x) {
  if (is.null(x)) return(NULL)
  x$word
}

coord %>%
  ggvis(~x, ~y, key := ~word) %>%
  add_tooltip(tooltip_test, "hover") %>%
  layer_points()

library(rbokeh)
figure() %>%
  ly_points(x, y, data = coord,
            hover = list(word))


