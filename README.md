# Ephys-TCanalysis
Matlab scripts for the group analysis of SU data in The temporal Contiguity experiment

- combineData.m : SU data is loaded from the selected folders. Firing rates are calculated, baseline corrected and normalized.
A cell with 15 columns is saved containing: Directory, SU filename, animal ID, swap SF, condition, FR per trial per stim, BL FR, mean FR per stim, SEM, Significant response,per stim significant selectivity,  Significant response, Preffered orientatio,, normalized fR per stim, PSTH values
- TC_LoadDataAsTable.m :

- sem: function to calculate the standard error of the mean. Works for both dimensions. NaNs are omitted
