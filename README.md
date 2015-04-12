# SingleCellClassificationTransition
SingleCellClassification code prepared for transition of ClassifyGui + integration into iBRAIN UZH


## Notes for transition to UZH

Code for single-cell classification on client-side (classify_gui) and server/iBrain-side has been compared and repacked in the repository “SingleCellClassificationTransition”. Duplications on client and server-side were removed and replaced by calls to same function. The client-side uses the former “classify_gui –Dev version” as this version has been the most maintained and most heavily used version during the last 2 years. 

In addition a test set was created and tests performed to ensure that iBrain-ETH (April 2015) gives same classification result as SingleCellClassificationTransition (which it indeed does; see /Shared/TestFor.... ) .One emergent issue is the dependency of single-cell classification on general code of the lab (e.g.: extracting metainformation about the position of an image within a muli-well plate; see /Shared/).

## Dependencies

* stprtool (compiled according to operating system); see http://cmp.felk.cvut.cz/cmp/software/stprtool/
* Shared code of lab (for curated versions of critical functions for single-cell-classification, where we have various functions circulating around in the lab (on Aril 2015) see /Shared/ATTENTIONGeneralFunctionsOfLab)
