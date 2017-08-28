FastRText
=========

R wrapper for [fastText](https://github.com/facebookresearch/fastText) C++ code from Facebook.

fastText is a library for efficient learning of word representations and sentence classification.

![fastText logo](./vignettes/fasttext-logo-color-web.png) 

Installation
------------

You can install the package from Github.

```R
# install.packages("devtools")
devtools::install_github("pommedeterresautee/FastRText/")
```

API
---

The API has been made very light:  
- `load_model`: load an existing model ;
- `execute`: execute any command supported by the client ;
- `predict`: return predictions and their probability (supervised)
- `get_dictionary`: return list of words learned (unsupervised) ;
- `get_labels`: return list of labels learned (supervised) ;
- `get_parameters`: return the parameters used for training ;
- `get_word_distance`: cosine distance between 2 vectors ;
- `get_word_vectors`: return vector related to `character` vector of words/labels.

### Supervised learning (text classification)

Data for a multi-class task are embedded in this package.  
Below we will learn a model and then measure the accuracy.  

```R
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
```

```
    Read 0M words
    Number of words:  5060
    Number of labels: 15
    Progress: 100.0%  words/sec/thread: 1855760  lr: 0.000000  loss: 0.312088  eta: 0h0m 
```

```R
    # load model
    model <- load_model(tmp_file_model)
    
    # prediction are returned as a list with words and probabilities
    predictions <- predict(model, sentences = test_to_write)
    print(head(predictions, 5))
```

```
    [[1]]
    __label__OWNX 
        0.9980469 
    
    [[2]]
    __label__MISC 
        0.9667969 
    
    [[3]]
    __label__MISC 
        0.9863281 
    
    [[4]]
    __label__OWNX 
        0.9082031 
    
    [[5]]
    __label__AIMX 
         0.984375 
```

```R
    # Compute accuracy
    mean(sapply(predictions, names) == test_labels)
```

```R
    [1] 0.82
```

```R    
    # test predictions
    predictions <- predict(model, sentences = test_to_write)
    print(head(predictions, 5))
```

```
    [[1]]
    __label__OWNX 
        0.9980469 
    
    [[2]]
    __label__MISC 
        0.9667969 
    
    [[3]]
    __label__MISC 
        0.9863281 
    
    [[4]]
    __label__OWNX 
        0.9082031 
    
    [[5]]
    __label__AIMX 
         0.984375 
```

```R    
    # free memory
    unlink(train_tmp_file_txt)
    unlink(tmp_file_model)
    rm(model)
    gc()
```

### Unsupervised learning (word representation)

```R
    library(FastRText)
    
    data("train_sentences")
    data("test_sentences")
    texts <- tolower(train_sentences[,"text"])
    tmp_file_txt <- tempfile()
    tmp_file_model <- tempfile()
    writeLines(text = texts, con = tmp_file_txt)
    execute(commands = c("skipgram", "-input", tmp_file_txt, "-output", tmp_file_model, "-verbose", 1))
```

```
    Read 0M words
    Number of words:  2061
    Number of labels: 0
    Progress: 100.0%  words/sec/thread: 18608  lr: 0.000000  loss: 2.717084  eta: 0h0m
```

```R    
    model <- load_model(tmp_file_model)
   
    # test word extraction
    dict <- get_dictionary(model)
    print(head(dict, 5))
```

```R
    [1] "the"  "</s>" "of"   "to"   "and"
```

```R 
  # print vector
  print(get_word_vectors(model, c("time", "timing")))
```

```R 
    $time
      [1]  0.1296210885  0.1316468269  0.0007626821  0.0356817469  0.2006593198 -0.0460157879  0.0231023580 -0.0233316422  0.1362834424 -0.0420252681
     [11] -0.0655319244 -0.0762185380 -0.1488197595 -0.1035384983 -0.0845064148  0.2970835268 -0.0226780772 -0.1043037027 -0.0474399552  0.2767507732
     [21] -0.1631491482  0.0246577058 -0.0510919876  0.1415337175 -0.0186830349  0.0277102590  0.2989047170 -0.1091243699  0.2127154171  0.1774759591
     [31] -0.2118884921  0.1580083966 -0.2573904097  0.0720630288  0.1223027334 -0.1067906320 -0.1770184636 -0.1367645562 -0.1797255427 -0.2507483065
     [41] -0.0737731382 -0.0335764810  0.4934033751  0.0927968696 -0.1988559216 -0.1831049174  0.0014060348  0.2465015799 -0.0966282785  0.0663930923
     [51]  0.1156903356 -0.0581681095  0.1633448750  0.0965265408 -0.2318589687 -0.0084880590 -0.0637115017 -0.3696584404  0.0428320728  0.0274929013
     [61] -0.1674125642  0.0492200330 -0.0935025662  0.4473278522  0.1401670724 -0.0925518200  0.0110784201 -0.2160260379 -0.0858220831  0.0785235688
     [71] -0.0083946604  0.0849706084 -0.0517802760 -0.2749955654 -0.0682966709  0.0041731247  0.0097561805 -0.0087426975  0.0818234086  0.0333902463
     [81] -0.0850559697  0.1362940371 -0.0933185294  0.1068129763 -0.1092673689 -0.1502138227  0.0475843176  0.1930907071 -0.1171457469  0.0033585809
     [91]  0.1949805468  0.1669725925  0.1696546674 -0.1804515570 -0.1499735862  0.0847207233 -0.1824831218 -0.2149232626 -0.1255764067 -0.0145111699
    
    $timing
      [1]  0.160078079  0.089299947 -0.028443312  0.087577075  0.197204530 -0.046088688  0.014435329  0.010740009  0.157881737 -0.041626919 -0.087656625
     [12] -0.077158570 -0.117233768 -0.084212191 -0.033463344  0.268052191  0.024618769 -0.062947571 -0.038740944  0.274398685 -0.180828378  0.032722849
     [23] -0.074779101  0.169604152  0.001532920  0.011797827  0.298075169 -0.148507968  0.236132696  0.201769084 -0.253632784  0.141390175 -0.358699590
     [34]  0.139938250  0.060195319 -0.084415935 -0.216627970 -0.135275722 -0.168502375 -0.309166789 -0.067674220  0.021249762  0.536724389  0.111997329
     [45] -0.247994825 -0.179069623 -0.010358712  0.212842971 -0.142138332  0.103004083  0.134464145 -0.047396421  0.254947871  0.076861322 -0.288775802
     [56]  0.013832947 -0.091028608 -0.401299775  0.037415996  0.043258362 -0.194530174  0.044848040 -0.110459305  0.459034413  0.105486415 -0.128112644
     [67] -0.011169771 -0.246604726 -0.136286691  0.064792447  0.004366267  0.066067092 -0.043443765 -0.263737917 -0.084394999  0.033850316  0.045276560
     [78] -0.069755353  0.042322587  0.015659215 -0.058141325  0.120230742 -0.131767645  0.110347047 -0.151947677 -0.201012269  0.045367155  0.210986614
     [89] -0.127198741  0.021938557  0.247432858  0.160363480  0.148728162 -0.168013781 -0.169050500  0.132359743 -0.186982766 -0.232297495 -0.124483496
    [100]  0.010415908
```

```R 
  # test word distance
  get_word_distance(model, "time", "timing")
```

```R 
           [,1]
[1,] 0.01769618
```

```R 
  # free memory
  unlink(tmp_file_txt)
  unlink(tmp_file_model)
  rm(model)
  gc()
```

Command list to use with execute() function
-------------------------------------------

```
The following arguments are mandatory:
  -input              training file path
  -output             output file path

  The following arguments are optional:
  -verbose            verbosity level [2]

  The following arguments for the dictionary are optional:
  -minCount           minimal number of word occurences [5]
  -minCountLabel      minimal number of label occurences [0]
  -wordNgrams         max length of word ngram [1]
  -bucket             number of buckets [2000000]
  -minn               min length of char ngram [3]
  -maxn               max length of char ngram [6]
  -t                  sampling threshold [0.0001]
  -label              labels prefix [__label__]

  The following arguments for training are optional:
  -lr                 learning rate [0.05]
  -lrUpdateRate       change the rate of updates for the learning rate [100]
  -dim                size of word vectors [100]
  -ws                 size of the context window [5]
  -epoch              number of epochs [5]
  -neg                number of negatives sampled [5]
  -loss               loss function {ns, hs, softmax} [ns]
  -thread             number of threads [12]
  -pretrainedVectors  pretrained word vectors for supervised learning []
  -saveOutput         whether output params should be saved [0]

  The following arguments for quantization are optional:
  -cutoff             number of words and ngrams to retain [0]
  -retrain            finetune embeddings if a cutoff is applied [0]
  -qnorm              quantizing the norm separately [0]
  -qout               quantizing the classifier [0]
  -dsub               size of each sub-vector [2]
```

Alternatives
------------

* Why not use the command line client?  
  * You can call the client from the client using `system("fastext ...")`.  
  * To get prediction, you will need to write file, make predictions from the command line, then read the results.  
  * FastRText makes your life easier by making all these operations in memory.  
  * It takes less time, and use less commands.
  * Easy to install from R directly. 

* Why not use [fastTextR](https://github.com/mlampros/fastTextR/) ?
  * FastRText implements both supervised and unsupervised parts of fasttext.
  * Predictions can be done in memory (unlike fastTextR)
  * fastText original source code embedded in fastTextR is not up to date (miss many new features, bug fixes since January 2017) because original source code has been modified (not the case of this package)

References
----------

Please cite [1](#enriching-word-vectors-with-subword-information) if using this code for learning word representations or [2](#bag-of-tricks-for-efficient-text-classification) if using for text classification.

### Enriching Word Vectors with Subword Information

[1] P. Bojanowski\*, E. Grave\*, A. Joulin, T. Mikolov, [*Enriching Word Vectors with Subword Information*](https://arxiv.org/abs/1607.04606)

```
@article{bojanowski2016enriching,
  title={Enriching Word Vectors with Subword Information},
  author={Bojanowski, Piotr and Grave, Edouard and Joulin, Armand and Mikolov, Tomas},
  journal={arXiv preprint arXiv:1607.04606},
  year={2016}
}
```

### Bag of Tricks for Efficient Text Classification

[2] A. Joulin, E. Grave, P. Bojanowski, T. Mikolov, [*Bag of Tricks for Efficient Text Classification*](https://arxiv.org/abs/1607.01759)

```
@article{joulin2016bag,
  title={Bag of Tricks for Efficient Text Classification},
  author={Joulin, Armand and Grave, Edouard and Bojanowski, Piotr and Mikolov, Tomas},
  journal={arXiv preprint arXiv:1607.01759},
  year={2016}
}
```

### FastText.zip: Compressing text classification models

[3] A. Joulin, E. Grave, P. Bojanowski, M. Douze, H. Jégou, T. Mikolov, [*FastText.zip: Compressing text classification models*](https://arxiv.org/abs/1612.03651)

```
@article{joulin2016fasttext,
  title={FastText.zip: Compressing text classification models},
  author={Joulin, Armand and Grave, Edouard and Bojanowski, Piotr and Douze, Matthijs and J{\'e}gou, H{\'e}rve and Mikolov, Tomas},
  journal={arXiv preprint arXiv:1612.03651},
  year={2016}
}
```

(\* These authors contributed equally.)
