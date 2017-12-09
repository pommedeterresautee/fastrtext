// Content of this file is added to each source of fastText to change some behaviours

#pragma once

#include <stdlib.h>
#include <string.h>
#include <Rcpp.h>
#include <stdexcept>
#include <RcppThread.h>

#define exit(status_code) exit_fasttext(status_code)
#define cerr Rcout // with cerr, no line refresh possible on R (it is an issue for learning with verbose set to 2, progress line is updated)
#define cout Rcout
#define thread Rthread // reroute call to thread to RcppThread to get an update of Rcout from time to time even when Rcout is never called from main thread
#define main main_fastrtext // no direct call to main(), otherwise Cran complains + strange errors

// catch the call to exit and call Rcpp::stop() when there is a fail
void exit_fasttext(int error_code);

namespace std {
  // Copy of Rcout in std namespace to reroute cout to R terminal with a macro
  // RcppThread makes possible call Rcout from multiple threads
  extern RcppThread::RPrinter Rcout;
  typedef  RcppThread::Thread Rthread;
}
