## Test environments
* Local ubuntu 17.04 + R version 3.4.1
* R-Hub Cran check (Linux + Windows)
* App veyor, Windows
* Travis-CI, Linux

## R CMD check results
* Local: no warning, no note
* Travis-CI: no warning, no note
* R-Hub Cran check:
  * 1 note: "Possibly mis-spelled words in DESCRIPTION" -> there is no error
* App Veyor:
  * 1 note: "Found no calls to: 'R_registerRoutines', 'R_useDynamicSymbols'" -> App Veyor tool chain is known to not be up to date, it may be the cause of this note. The note can't be reproduced on R-Hub Windows check.