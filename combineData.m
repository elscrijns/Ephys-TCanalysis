%% This script will read in all the data per animal and place it an array

%     animal    =   701  915    953 577
%     swap      =   Low  High
%     Sel       =   0    1
%     con       =   Pre  Post
%     psth      =   []

% load('C:\Users\u0105250\Documents\MATLAB\DATA\dataTempContig.mat');
% %or
% dataTempContig = {};

Dir = 'E:\DATA Electrophysiology\';
Dir = uigetdir(Dir, 'Select the recording session you want to analyze');
animalID  =   cellstr('953');
swap      =   cellstr('High');
con       =   cellstr('Pre');

fileNames = dir([Dir '\*.mat']);
n = size(fileNames,1);

%%  Calculate prefference  
 

  % Define general variables for generating PSTH
    binWidth =  10; %ms
    before   = 300; %ms
    after    = 600; %ms
    stimDur  = 200 ;%ms
    edges       = -before:binWidth:after; % msec.
    onsetIndex  = (before - binWidth / 2) / binWidth + 1;
    offsetIndex = (before+stimDur - binWidth/2) / binWidth + 1;
 
for f = 1:n
    
load([Dir '\' fileNames(f).name]);
    % trial = struct('start' 'onset' 'offset' 'condition' 'spikes')
    % Contains information on timing of stimulus presentation, type of stimulus
    % and timing of spiking activity. All times expressed in uSec, should be
    % converted to ms -> time/10^3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spikeTimings= [];
    psths       = [];
    conditions  = [];
    baselineFR  = [];
    immediateFR = [];

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For every trial the psth are calculated %%%

    for i = 1:length(trial)
        spikeTimings     = (trial(i).spikes - trial(i).onset) / 10.0 ^ 3;       % msec.
        psths(end+1, :)  = (10.0 ^ 3 / binWidth) * histc(spikeTimings, edges);  % spikes per sec
        conditions(i) = trial(i).condition;

        baselineIndex = spikeTimings > -95 & spikeTimings < 5 ;
            baselineFR(i) = (10.0 ^ 3 / 100) * sum(baselineIndex);
        immediateIndex = spikeTimings > 15 & spikeTimings < 115 ;
            immediateFR(i)= (10.0 ^ 3 / 100) * sum(immediateIndex);
    end

    clear spikeTimings baselineIndex immediateIndex trial
    
% Calculate the net firing rate for each trial (with respect to the BL response)
    BL = mean(baselineFR); % mean response before stimulus onset for all trials
    netFR = immediateFR - BL;
    
    clear i spikeTimings baselineIndex immediateIndex immediateFR baselineFR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Calculate for each condition the mean net FR and SEM            %%%

% test if any of the stimuli elicit a significant response


% split the immediate FR into columns per stimulus condition
T = countcats(categorical(conditions));
    maxT = max(T);
    minT = min(T);
    FRstim = nan(maxT,6);
    for i = 1:6
       x = T(i);
       FRstim(1:x,i) = netFR(conditions == i);
    end
    %FRstim  = FRstim(1:minT,:);
    
    clear T x i maxT netFR minT

% Calculations per stimulus
    FR  = mean(FRstim, 'omitnan' );         % Calculate the mean on the FR 
    SEM = sem(FRstim,1);          % Calculate the standard error on the FR 
    resp = ttest(FRstim , BL);  % Significant response with respect to BL
    
    Selective  = ttest2(FRstim(:,2),FRstim(:,5), 'Vartype','unequal');
    Responsive = any(resp == 1) & (FR(2)>1 | FR(5)>1);

% Define the prefered OR and group and normalize the FR
    if FR(2) > FR(5)
        Pref = 1;
        normFR = FR / FR(2); % normalized to the ref condition in preferred OR
    else 
        Pref = 2;
        normFR = FR / FR(5);
    end
    
    PSTH1 = mean(psths(conditions == 1,:));
    PSTH2 = mean(psths(conditions == 2,:));
    PSTH3 = mean(psths(conditions == 3,:));
    PSTH4 = mean(psths(conditions == 4,:));
    PSTH5 = mean(psths(conditions == 5,:));
    PSTH6 = mean(psths(conditions == 6,:));
    PSTHS = [PSTH1' PSTH2' PSTH3' PSTH4' PSTH5' PSTH6'];
    
    clear PSTH1 PSTH2 PSTH3 PSTH4 PSTH5 PSTH6 psths conditions
    
    dataTempContig(end+1,:) = {Dir, fileNames(f).name, categorical(animalID), categorical(swap), categorical(con), FRstim, BL, FR, SEM, logical(resp), logical(Selective), Responsive, categorical(Pref), normFR, PSTHS};

    clear FRstim FR SEM resp Selective Responsive Pref normFR BL PSTHS
    
end

clear binWidth before after stimDur edges onsetIndex offsetIndex
clear Dir fileNames animalID swap con f n

%%
save('C:\Users\u0105250\Documents\MATLAB\DATA\dataTempContig.mat', 'dataTempContig')