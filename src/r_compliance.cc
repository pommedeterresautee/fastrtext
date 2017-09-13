// Code to be included in all cc files to avoid warnings / notes from Cran
#include <stdlib.h>
#include <string.h>
#include <Rcpp.h>
#include <ostream>

void exit_fasttext(int status_code) {
  if (status_code != EXIT_SUCCESS) {
    Rcpp::stop("Exit code: " + std::to_string(status_code));
  }
}

namespace std {
  std::ostream Rcout(Rcpp::Rcout.rdbuf());
}
