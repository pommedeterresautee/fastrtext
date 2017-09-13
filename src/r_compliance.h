// Content of this file is added to each source of fastText to change some behaviours

#ifndef R_COMPLIANCE
#define R_COMPLIANCE

#include <Rcpp.h>
#include <stdexcept>

#define exit(status_code) exit_fasttext(status_code)
#define cerr Rcout // with cerr, no line refresh possible on R
#define cout Rcout
#define main main_fastrtext // no direct call to main(), otherwise Cran complains + strange errors

// catch the call to exit and call Rcpp::stop() when there is a fail
void exit_fasttext(int error_code);

// Copy of Rcout in std namespace to reroute cout to R terminal with a macro
namespace std {
  extern std::ostream Rcout;
}

#endif //R_COMPLIANCE
