# CellClassificationPelkmans

Code for single-cell classification on client-side (classify_gui) and server/iBrain-side has been compared and repacked in the repository “SingleCellClassificationTransition”. Duplications on client and server-side were removed and replaced by calls to same function. The client-side uses the former “classify_gui –Dev version” as this version has been the most maintained and most heavily used version during the last 2 years. 

In addition a test set was created and tests performed to ensure that iBrain-ETH (April 2015) gives same classification result as SingleCellClassificationTransition (which it indeed does; see /Shared/TestForIdenticalClassification).

## Dependencies

* stprtool (compiled according to operating system); see http://cmp.felk.cvut.cz/cmp/software/stprtool/
* PelkmansLibrary
* MATLAB toolboxes (image processing, statistics)
