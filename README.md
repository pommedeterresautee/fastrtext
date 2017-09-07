FastRText
=========

[![Travis-CI Build Status](https://travis-ci.org/pommedeterresautee/FastRText.svg?branch=master)](https://travis-ci.org/pommedeterresautee/FastRText)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/pommedeterresautee/FastRText?branch=master&svg=true)](https://ci.appveyor.com/project/pommedeterresautee/FastRText)
[![codecov](https://codecov.io/gh/pommedeterresautee/FastRText/branch/master/graph/badge.svg)](https://codecov.io/gh/pommedeterresautee/FastRText)

R wrapper for [fastText](https://github.com/facebookresearch/fastText) C++ code from Facebook.

fastText is a library for efficient learning of word representations and sentence classification.

![fastText logo](https://github.com/pommedeterresautee/FastRText/raw/master/tools/fasttext-logo-color-web.png) 

Installation
------------

You can install the FastRText package from Github as follows:

```R
# install.packages("devtools")
devtools::install_github("pommedeterresautee/FastRText")
```

Documentation
-------------

All the updated documentation can be reached at this [address](https://pommedeterresautee.github.io/FastRText/).

API
---

API documentation can be reached at this [address](https://pommedeterresautee.github.io/FastRText//reference/index.html).

In particular, command line options are listed [there](https://pommedeterresautee.github.io/FastRText/articles/list_command.html).

### Supervised learning (text classification)

Data for a multi-class task are embedded in this package.  
Follow this [link](https://pommedeterresautee.github.io/FastRText/articles/supervised_learning.html) to learn a model and then measure the accuracy in 5 minutes.  


### Unsupervised learning (word representation)

Data for a word representation learning task are embedded in this package.  
Following this [link](https://pommedeterresautee.github.io/FastRText/articles/unsupervised_learning.html) will route you to 5mn tutorial to learn a representations of words (word embeddings):  

Alternatives
------------

Why not use the command line client?  

* You can call the client from the client using `system("fastext ...")` ;
* To get prediction, you will need to write file, make predictions from the command line, then read the results ;
* FastRText makes your life easier by making all these operations in memory ;
* It takes less time, and use less commands ;
* Easy to install from R directly.

Why not use [fastTextR](https://github.com/mlampros/fastTextR/) ?  

* FastRText implements both supervised and unsupervised parts of fasttext (fastTextR implements only the unsupervised part) ;
* with FastRText. predictions can be done in memory (fastTextR requires to write the sentence on hard drive and requires you to read the predictions after) ;
* fastText original source code embedded in fastTextR is not up to date (miss several new features, bug fixes since January 2017).

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
