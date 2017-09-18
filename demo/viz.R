library(fastrtext)
library(irlba)
library(plotly)
library(RcppAnnoy)
library(Rtsne)
library(assertthat)

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

get_list_word <- function(word, dict, annoy_model, n, search_k = min(max(10000, 10 * n), length(dict)), with_distance = TRUE) {
  assert_that(isTRUE(word %in% dict))
  position <- which(word == dict)
  assert_that(is.count(position))
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

get_coordinates <- function(vectors, projection) {
  switch(projection,
         tsne = get_coordinates_tsne(vectors = vectors),
         pca = get_coordinates_pca(vectors = vectors))
}

center_coordinates <- function(coordinates) {
  coordinates$x <- coordinates$x - coordinates[1,]$x
  coordinates$y <- coordinates$y - coordinates[1,]$y
  coordinates
}

retrieve_neighboors <- function(text, embeddings, projection, model, n) {
    l <- get_list_word(text, rownames(embeddings), model$annoy_model, n)
    df <- get_coordinates(embeddings[l$item,], projection)
    center_coordinates(df)
}

prepare <- function(embeddings, trees, explore_k) {
  container <- list()
  container$annoy_model <- build_annoy_model(embeddings, trees)
  container$embeddings <- embeddings
  container$k <- explore_k
  container
}

plot_text <- function(coordinates) {
  plot_ly(coordinates, x = ~x, y = ~y, name = "default", text = ~text, type = "scatter", mode = "markers", marker = list(color = 1 - (match(b$text, dict) / length(dict)), colorscale = "Reds", showscale = TRUE), size = ifelse(b$text == selected_word, 20, 10))
}

selected_word <- "we"
c <- prepare(word_embeddings, trees = 5, explore_k = 10e4)
b <- retrieve_neighboors(selected_word, word_embeddings, "pca", c, 1000)
plot_text(b)
