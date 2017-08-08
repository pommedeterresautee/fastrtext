#ifndef R_COMPLIANCY
#define R_COMPLIANCY

#include <Rcpp.h>
#include <stdexcept>

#define exit(param) throw std::invalid_argument("Exit code: " + std::to_string(param));
#define cerr cout

#endif //R_COMPLIANCY
