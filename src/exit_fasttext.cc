#include "exit_fasttext.h"
#include <stdlib.h>
#include <string.h>
#include <Rcpp.h>
#include <ostream>

void ciao(int error_code) {
  if (error_code != 0) {
    Rcpp::stop("Exit code: " + std::to_string(error_code));
  }
}

namespace std {
std::ostream Rccout(Rcpp::Rcout.rdbuf());
}