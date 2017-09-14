## ----unsupervised_learning-----------------------------------------------
 library(fastrtext)
    
    data("train_sentences")
    data("test_sentences")
    texts <- tolower(train_sentences[,"text"])
    tmp_file_txt <- tempfile()
    tmp_file_model <- tempfile()
    writeLines(text = texts, con = tmp_file_txt)
    execute(commands = c("skipgram", "-input", tmp_file_txt, "-output", tmp_file_model, "-verbose", 1))
 
    model <- load_model(tmp_file_model)
   
    # test word extraction
    dict <- get_dictionary(model)
    print(head(dict, 5))

  # print vector
  print(get_word_vectors(model, c("time", "timing")))

  # test word distance
  get_word_distance(model, "time", "timing")

  # free memory
  unlink(tmp_file_txt)
  unlink(tmp_file_model)
  rm(model)
  gc()

