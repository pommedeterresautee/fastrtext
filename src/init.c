#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME:
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP _rcpp_module_boot_FASTRTEXT_MODULE();

static const R_CallMethodDef CallEntries[] = {
    {"_rcpp_module_boot_FASTRTEXT_MODULE", (DL_FUNC) &_rcpp_module_boot_AnnoyAngular, 0},
    {NULL, NULL, 0}
};

void R_init_FastRText(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
