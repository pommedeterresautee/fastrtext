// Content of this file is added to each source of Fasttext to change some behaviours

#ifndef R_COMPLIANCE
#define R_COMPLIANCE

#include <Rcpp.h>
#include <stdexcept>

#define exit(status_code) exit_fasttext(status_code)
#define cerr Rcout // with cerr, no line refresh possible on R
#define cout Rcout
#define main main_fastrtext // no call to main()

void exit_fasttext(int error_code);

namespace std {
  extern std::ostream Rcout;
}

#endif //R_COMPLIANCE
