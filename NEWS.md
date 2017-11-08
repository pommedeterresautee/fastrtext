# 0.2.3

  * fix a cran note related to the DESCRIPTION file
  * remove documentation not anymore useful because of previous update
  * add some asserts to avoid the case where some sentences have no prediction because all their words are unknown (not seen during training).

# 0.2.2 (07.11.17)

  * make possible to interrupt long computation (not for model training part)
  * add simplify option to predict (to get flat vector as a result)
  * remove prefix label in predict result
  * update fastText source code
  * fix crash when learning and setting verbose to 2 (calling Rcout from multiple threads crash the application)

# 0.2.1 (18.09.17)

  * fix small bugs in compilation (mostly for mac os)
  * remove all notes (Cran)

# 0.2.0 (15.09.17)

  * first Cran release
  * covers all basic features of fastText
