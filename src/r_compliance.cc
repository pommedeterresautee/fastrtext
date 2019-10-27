// Content of this file is added to each source of fastText to change some behaviours
#include <stdlib.h>
#include <string.h>
#include <Rcpp.h>
#include <ostream>
#include "real.h"

void exit_fasttext(int status_code) {
  if (status_code != EXIT_SUCCESS) {
    Rcpp::stop("Failure in fastrtext. Exit code: " + std::to_string(status_code));
  }
}

// catch interrupt from the user
// void interrupt_or_print(double maxDuration) {
//   Rcpp::checkUserInterrupt();
//   printInfo(maxDuration);
// }

namespace std {
  std::ostream Rcout(Rcpp::Rcout.rdbuf());
}
