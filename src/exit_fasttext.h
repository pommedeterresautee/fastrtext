#ifndef R_EXIT
#define R_EXIT

#include <stdlib.h>
#include <string.h>
#include <Rcpp.h>
#include <ostream>

void ciao(int error_code);
namespace std {
  extern std::ostream Rccout;
}
#endif