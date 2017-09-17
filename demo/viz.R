library(fastrtext)
library(irlba)
library(magrittr)
library(plotly)
require(Rtsne)

set.seed(123)

model_test_path <- system.file("extdata", "model_unsupervised_test.bin", package = "fastrtext")
model <- load_model(model_test_path)
#model <- load_model("/home/geantvert/workspace/justice-data/ML/models/fasttext/wiki.fr.bin")
word_embeddings <- get_word_vectors(model)
dict <- rownames(word_embeddings)

cos_sim <- function(vector_to_compare, full_matrix){
  ma <- matrix(vector_to_compare, nrow = 1)
  mat <- tcrossprod(ma, full_matrix)
  t1 <- sqrt(apply(ma, 1, crossprod))
  t2 <- sqrt(apply(full_matrix, 1, crossprod))
  mat / outer(t1,t2)
}

library(RcppAnnoy)

build_annoy_model <- function(vectors, trees) {
  a <- new(AnnoyAngular, ncol(vectors))
  for (i in seq(nrow(vectors))) {
    a$addItem(i - 1, vectors[i,])
  }
  a$build(trees)
  a
}

get_list_word <- function(word, dict, annoy_model, n, search_k = 10000, with_distance = TRUE) {
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

a <- build_annoy_model(word_embeddings, 5)

"loisir" %>%
  get_list_word(dict, a, 1000) %>%
  {word_embeddings[.$item,]} %>%
  get_coordinates_tsne() %>%
  center_coordinates() %>%
  plot_ly(x = ~x, y = ~y, name = "default", text = ~text, type = "scatter")
