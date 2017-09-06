// Content of this file is added to each source of Fasttext to change some behaviours

#ifndef R_COMPLIANCY
#define R_COMPLIANCY

#include <Rcpp.h>
#include <stdexcept>

#define exit(error_code) if (error_code != 0) {Rcpp::stop("Exit code: " + std::to_string(error_code));};
#define cerr cout // with cerr, no line refresh possible on R
#define main main_fastrtext // no call to main()


#endif //R_COMPLIANCY
