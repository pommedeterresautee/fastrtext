library(fastrtext)
library(irlba)
library(magrittr)
library(plotly)
library(RcppAnnoy)
require(Rtsne)

set.seed(123)

model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
model <- load_model(model_test_path)
#model <- load_model("/home/geantvert/workspace/justice-data/ML/models/fasttext/wiki.fr.bin")
word_embeddings <- get_word_vectors(model)
dict <- rownames(word_embeddings)

build_annoy_model <- function(vectors, trees) {
  model <- new(AnnoyAngular, ncol(vectors))
  for (i in seq(nrow(vectors))) {
    model$addItem(i - 1, vectors[i,])
  }
  model$build(trees)
  model
}

get_list_word <- function(word, dict, annoy_model, n, search_k = max(10000, 10 * n), with_distance = TRUE) {
  position <- which(word == dict)
  l <- annoy_model$getNNsByItemList(position - 1, n, search_k, with_distance)
  l$item <- l$item + 1
  l$text <- dict[l$item]
  l
}

get_coordinates_pca <- function(vectors) {
  pca <- irlba(vectors, nv = 2)
  coordinates <- data.frame(pca$u)
  colnames(coordinates) <- c("x", "y")
  coordinates$text <- rownames(vectors)
  coordinates
}

get_coordinates_tsne <- function(vectors) {
  tsne_model_1 <- Rtsne(vectors, check_duplicates = FALSE, pca = TRUE, perplexity = 30, theta = 0.5, dims = 2)
  coordinates <- as.data.frame(tsne_model_1$Y)
  colnames(coordinates) <- c("x", "y")
  coordinates$text <- rownames(vectors)
  coordinates
}

center_coordinates <- function(coordinates) {
  coordinates$x <- coordinates$x - coordinates[1,]$x
  coordinates$y <- coordinates$y - coordinates[1,]$y
  coordinates
}

system.time(a <- build_annoy_model(word_embeddings, 5))

b = "arbre" %>%
  get_list_word(dict, a, 1000) %>%
  {word_embeddings[.$item,]} %>%
  get_coordinates_tsne() %>%
  center_coordinates() #%>%

  plot_ly(b, x = ~x, y = ~y, name = "default", text = ~text, type = "scatter", mode = "markers", color = ifelse(b$text %in% head(dict, 20e3), "#A93226", "#AEB6BF"))
