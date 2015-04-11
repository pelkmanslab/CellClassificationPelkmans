strPath = '\\195.176.109.11\biol_uzh_pelkmans_s5\Data\Users\Thomas\150221-DS101r1ac\BATCH\';
input_file_name = '\\195.176.109.11\biol_uzh_pelkmans_s5\Data\Users\Thomas\150221-DS101r1ac\dSVM_testMitotic01Local.mat';

%%% if you want to run iBrain on a specific machine use the line, which is
%%% commented out below
% SVM_Classify_with_Probabilities_iBRAIN(input_file_name,strPath) % e.g.: test locally 


% This dataset has provided identical classification via iBrain (general
% version running at ETH on Apr11, 2015 and cell classification (using gui
% and server-side classification of transition repository on Apr 11, 2015)
strViaReference = 'Measurements_SVM_testMitotic01.mat';

iBrainOrLocalApr2015 = loadd(strViaReference);

nameOfNewClassification = 'pleaseAdd';
strNewClassification = 'Measurements_SVM_testMitotic01.mat';
NewClassification = loadd(strNewClassification);


if isequal(iBrainOrLocalApr2015.Measurements.SVM.testMitotic01 , NewClassification.Measurements.SVM.(nameOfNewClassification))
    fprintf('Congratulations. You get the same classification as iBrain prior migration to UZH')
else
    error('Classification is different from classification prior migration of iBrain to UZH')
end
