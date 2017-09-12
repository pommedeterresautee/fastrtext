// Content of this file is added to each source of Fasttext to change some behaviours

#ifndef R_COMPLIANCY
#define R_COMPLIANCY

#include <Rcpp.h>
#include <stdexcept>
#include "exit_fasttext.h"

#define exit(error_code) ciao(error_code)
#define cerr Rccout // with cerr, no line refresh possible on R
#define cout Rccout
#define main main_fastrtext // no call to main()

#endif //R_COMPLIANCY
