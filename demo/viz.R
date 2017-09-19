library(fastrtext)
library(irlba)
library(plotly)
library(RcppAnnoy)
library(Rtsne)
library(assertthat)
library(largeVis)


set.seed(123)

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
  l$frequency <- (match(l$text, dict) / length(dict))
  l
}

get_coordinates_pca <- function(vectors) {
  pca <- irlba(vectors, nv = 2)
  data.frame(pca$u)
}

get_coordinates_largeVis <- function(vectors) {
  transposed_vectors <- t(scale(vectors))
  visObject <- largeVis(transposed_vectors, distance_method = "Cosine", sgd_batches = 0.1)
  data.frame(t(visObject$coords))
}

get_coordinates_tsne <- function(vectors) {
  tsne_model_1 <- Rtsne(vectors, check_duplicates = FALSE, pca = TRUE, perplexity = 30, theta = 0.5, dims = 2)
  data.frame(tsne_model_1$Y)
}

get_coordinates <- function(vectors, projection_type, frequency) {
  coordinates <- switch(projection_type,
              tsne = get_coordinates_tsne(vectors = vectors),
              pca = get_coordinates_pca(vectors = vectors),
              largeVis = get_coordinates_largeVis(vectors = vectors))

  colnames(coordinates) <- c("x", "y")
  coordinates$text <- rownames(vectors)
  coordinates$frequency <- frequency
  coordinates
}

center_coordinates <- function(coordinates) {
  coordinates$x <- coordinates$x - coordinates[1,]$x
  coordinates$y <- coordinates$y - coordinates[1,]$y
  coordinates
}

retrieve_neighboors <- function(text, embeddings, projection_type, model, n) {
    l <- get_list_word(text, rownames(embeddings), model$annoy_model, n)
    df <- get_coordinates(embeddings[l$item,], projection_type, l$frequency)
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
  plot_ly(coordinates, x = ~x, y = ~y, name = "default", text = ~text, type = "scatter", mode = "markers", marker = list(color = ~frequency, colorscale = "Hot", showscale = TRUE), size = ifelse(b$text == selected_word, 20, 10))
}

model_test_path <- system.file("extdata",
                               "model_unsupervised_test.bin",
                               package = "fastrtext")
model <- load_model(model_test_path)
#model <- load_model("/home/geantvert/workspace/justice-data/ML/models/fasttext/wiki.fr.bin")
word_embeddings <- get_word_vectors(model)
#dict <- rownames(word_embeddings)

c <- prepare(word_embeddings, trees = 5, explore_k = 10e4)

selected_word <- "avocat"
b <- retrieve_neighboors(selected_word, word_embeddings, "tsne", c, 1000)
plot_text(b)

