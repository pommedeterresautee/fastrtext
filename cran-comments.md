## Version 0.2.1 - 18.09.17
* Fix compilation crash on Mac OS
* remove notes on R devel

## Comments from Swetlana Herbrandt - 15.09.17 - 4:45PM (French time)
* please omit the redundant 'R' in your title -> the R is now removed from the title field.
* please write package names and software names in Title and Description in single quotes (e.g. 'FastText'). -> quotes have been applied on any software name.
* please add an URL for 'FastText' in the form <http:...> or <https:...> with angle brackets for auto-linking and no space after 'http:' and 'https:' -> the link has been added at the end of the decsription text.
* we see code lines such as  Copyright (c) 2016-present, Facebook, Inc. All rights reserved. Please add all authors and copyright holders in the Authors@R field with the appropriate roles. -> a new person Facebook, Inc. has been added, with the role cph

Note to Cran
------------
The introduction of quotes (see above) has raised a new note:
"The Description field should start with a capital letter."
This is wanted.


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
