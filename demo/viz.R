library(fastrtext)
library(irlba)
library(magrittr)
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

get_list_word <- function(word, dict, annoy_model, n, search_k = max(10000, 10 * n), with_distance = TRUE) {
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

center_coordinates <- function(coordinates) {
  coordinates$x <- coordinates$x - coordinates[1,]$x
  coordinates$y <- coordinates$y - coordinates[1,]$y
  coordinates
}

retrieve_neighboors <- function(text, embeddings, annoy_model, n = 1000) {
    get_list_word(text, rownames(embeddings), annoy_model, n) %>%
    {embeddings[.$item,]} %>%
    get_coordinates_tsne() %>%
    center_coordinates()
}

system.time(a <- build_annoy_model(word_embeddings, 5))

b <- retrieve_neighboors("avocat", word_embeddings, a, n = 10e4)

plot_ly(b, x = ~x, y = ~y, name = "default", text = ~text, type = "scatter", mode = "markers", marker = list(color = 1 - (match(b$text, dict) / length(dict)), colorscale = c('#FFE1A1', '#683531'), showscale = TRUE), size = ifelse(b$text == "avocat", 20, 10))
