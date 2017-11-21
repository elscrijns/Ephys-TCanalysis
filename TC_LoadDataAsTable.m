load('dataTempContig.mat');
% convert cell array to table with variable names
TC = cell2table(dataTempContig, 'variableNames', ...
     {'Dir', 'clusters', 'animalID', 'swap', 'phase', 'FRstim',...
    'BL', 'FR', 'SEM', 'resp', 'Selective', 'Responsive', 'Pref', 'normFR', 'PSTHS'});

clear dataTempContig

% Variables:
% 
%     Dir: 793x1 cell string        =  Filepath of the cluster file
% 
%     clusters: 793x1 cell string   =  Filename of the cluster
% 
%     animalID: 793x1 categorical   =  ID number of the animal 
%         Values:
%             953     360       
%             915     180       
%             701     253       
% 
%     swap: 793x1 categorical       =  Experimental group 
%         Values:
%             High    540   
%             Low     253   
% 
%     phase: 793x1 categorical      =  Pre or Post exposure phase  
%         Values:
%             Post    291  
%             Pre     502  
% 
%     FRstim: 793x1 cell            =  net spike counts per trial per stimulus
% 
%     BL: 793x1 double              =  BL firing rate ove all conditions [-95:5] ms
% 
%     FR: 793x6 double              =  average FR per stim [15:115] ms
% 
%     SEM: 793x6 double             =  standard error of the mean FR per stim
%  
%     resp: 793x6 logical           =  Significant immediate response per stim (t-test)
% 
%     Selective: 793x1 logical      =  Significantly selective for Ref SF
%         Values:
%             true     228        
%             false    565        
% 
%     Responsive: 793x1 logical  	= significantly responsive for ref SF
%         Values:
%             true     726         
%             false     67         
% 
%     Pref: 793x1 categorical       =  Preffered orientation
%         Values:
%             1        381      45°
%             2        412      135°
% 
%     normFR: 793x6 double          =  average FR per stimulus normalized 
%                                       to the preferred OR at ref SF
% 
%     PSTHS: 793x1 cell             = Spike bin counts with respect to stimulus onset