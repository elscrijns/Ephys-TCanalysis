% analysis of temporal contiguity data based on selectivity (normalized FR)
% Selectivity is defined as the difference in response between 2
% orientations on the reference SF.
% Firing Rates (FR) are baseline corrected and normalized to the reference SF with
% the highest response
%% The data is loaded as a table
TC_LoadDataAsTable;
% or 
load('normSelectivity.mat');

% TC.Properties.VariableNames
% 'Dir'    'clusters'    'animalID'    'swap'    'phase'    'FRstim'    'BL'    'FR'    'SEM'    'resp'    'Selective'
%  'Responsive'    'Pref'    'normFR'    'PSTHS'

%% 2 new variables are created: PrefFR and nonPrefFR
% These contain the normalized firing rates for the preferred and non
% preffered orientations respectively
% The order of the stimuli is altered to condition : [control, ref, swap] 
n = height(TC);
PrefFR    = zeros(n,3);
nonPrefFR = zeros(n,3);

for i  = 1:n    
    if strcmp(TC.Pref(i) , '2')
        PrefFR(i,1:3) = TC.normFR(i,4:6);
        nonPrefFR(i,1:3) = TC.normFR(i,1:3);
    else
        PrefFR(i,1:3) = TC.normFR(i,1:3);
        nonPrefFR(i,1:3) = TC.normFR(i,4:6);
    end     
    if strcmp(TC.swap(i) , 'Low')
        PrefFR(i,1:3) = flip(PrefFR(i,:));
        nonPrefFR(i,1:3) = flip(nonPrefFR(i,:));
    end
end
    selectivity = PrefFR - nonPrefFR;
    sign = TC.Selective == 1 & TC.Responsive == 1;
    phase = TC.phase == 'Pre'; % PRE = 1
    ID = TC.animalID ;
    save('DATA\normSelectivity.mat', 'selectivity','PrefFR', 'nonPrefFR', 'sign', 'phase')

%% Calculate the selectivity for both orientations per experimental phase

A = PrefFR(sign == 1 & phase == 1,:);
B = nonPrefFR(sign == 1 & phase == 1,:);
%% Plot norm FR of condition vs orientation per phase  
figure;
 hold on
    errorbar( mean(A), sem(A,1) )
    errorbar( mean(B), sem(B,1) )
        legend('Preffered orientation', 'Opposite orientation')
        set(gca, 'XTick', [1 2 3]);
        set(gca, 'XTickLabel', {'control', 'reference', 'swap'});
        set(gca, 'FontSize', 14);
        ylim([0.5 1])
        ylabel('Normalized Firing Rate (mean+SEM)')
        xlabel('Condition')
        
        title(['Pre-exposure Selectivity, n=' num2str(length(A))])

%% Significance testing
n = length(A);
D = A-B; %  selectivity

    % Is there significant object selectivity irrespective of orientation?
    [p0,~,stats0] = anova2([A;B], n, 'off'); %omitting the reference condition?
    
    disp(['Pre-exposure ANOVA            : p= '  num2str(stats0.pval)] )
    disp(['   Main effect of condition   : p= ' num2str(p0(1)) ])
    disp(['   Main effect of orientation : p= ' num2str(p0(2)) ])
    disp(['   Interaction effect         : p= ' num2str(p0(3)) ])
   
    % Is there a significant difference between the 2 orientations at each
    % condition sepperately?
    [h1] = ttest(A,B,'Tail', 'right');
%         for i = 1:3
%             if h1(i) == 1
%                 text(i, 0.1,  '*', 'FontSize', 20)
%             end
%         end
   % Is there a significant difference between the swap and control
   % condition??
   Delta = mean(D);
%    for i = 1:3
%           text(i-0.1, 0.2,  num2str(Delta(i)) , 'FontSize', 14)
%    end
   
%  hold off
 
   [h2, p2] = ttest(D(:,1), D(:,2) ,'Tail', 'left');
   [h3, p3] = ttest(D(:,3), D(:,2) ,'Tail', 'left');
   [h4, p4] = ttest(D(:,3), D(:,1) ,'Tail', 'both');
   
   disp('Differences between conditions')
   disp(['   swap vs ref: ' num2str(Delta(3)-Delta(2), '%.2f') ', p = ' num2str(p3, '%.2f') ', 1-tailed paired t-test']);
   disp(['   con  vs ref: ' num2str(Delta(1)-Delta(2),  '%.2f') ', p = ' num2str(p2, '%.2f') ', 1-tailed paired t-test']);
   disp(['   swap vs con: ' num2str(Delta(3)-Delta(1),  '%.2f') ', p = ' num2str(p4, '%.2f') ', 2-tailed paired t-test']);

   pwrSwapCon = sampsizepwr('t2', [mean(D(:,3)) std(D(:,3)) ] , mean(D(:,1)) ,[] , n)
   nSwapCon = sampsizepwr('t2', [mean(D(:,3)) std(D(:,3)) ] , mean(D(:,1)) ,0.8)
   
 %%  comparison of pre vs post selectivity
 % only includes clusert significantly selective for reference condition
 
 A = selectivity(sign == 1 & phase == 1 & ID == '701' ,:);
 B = selectivity(sign == 1 & phase == 0 & ID == '701',:);

 nA = length(A);
 nB = length(B);
 
 figure;
 hold on
    errorbar( mean(A), sem(A,1) )
    errorbar( mean(B), sem(B,1) )
        legend(['Pre-exposure clu, n=' num2str(length(A))], ['Post-exposure clu, n=' num2str(length(B))])
        set(gca, 'XTick', [1 2 3]);
        set(gca, 'XTickLabel', {'control', 'reference', 'swap'});
        set(gca, 'FontSize', 14);
        ylim([0 1]);
        ylabel('normalized selectivity (mean+SEM)')
        xlabel('Condition')
        title('Selectivity: pre vs post exposure')
 
%% Significance testing
    % is there significant selectivity in each phase
    [ha,pa] = ttest(A);
    [hb,pb] = ttest(B);
    
    disp(['Selectivity of pre-exposure  : p= ' num2str(pa, ' %1.3f ') ])
    disp(['Selectivity of post-exposure : p= ' num2str(pb, ' %1.3f ') ])
    
    % Is there significant exposure effect irrespective of condition?
        %omitting the reference condition?
    C = [ reshape(A(:,[1 3]),[],1 ); reshape(B(:,[1 3]),[],1 ) ] ;
    con = [reshape(repmat([1 3], nA,1),[],1) ; reshape(repmat([1 3], nB,1),[],1) ];
    exp = [ones(2*nA, 1) ; zeros(2*nB, 1)];
    [p0,~,stats0] = anovan(C, {con, exp}, 'display', 'off', 'model', 'interaction');
    
    disp('ANOVA of exposure x condition  ')
    disp(['   Main effect of condition   : p=  ' num2str(p0(1),' %1.3f ') ])
    disp(['   Main effect of exposure    : p=  ' num2str(p0(2),' %1.3f ') ])
    disp(['   Interraction effect        : p=  ' num2str(p0(3),' %1.3f ') ])
    
    % Is there a significant difference between the 2 phases at each
    % condition sepperately?
    [h1, p1, ci, stats] = ttest2(A,B,'Tail', 'both');
        for i = 1:3
            if h1(i) == 1
                text(i, 0.09,  '*', 'FontSize', 20)
            end
        end
   % Is there a significant difference between the swap and control
   % condition??
   Delta = mean(A) - mean(B);
%   [h2, p2] = ttest(Delta, 0.99496 ,'Tail', 'both')
   for i = 1:3
          text(i-0.1, 0.05,  num2str(Delta(i)) , 'FontSize', 14)
   end
   hold off

%% comparing swap vs non swap
 
index   = selectivity(:,3)-selectivity(:,1);
PreI    = index(sign == 1 & phase == 1);
PostI   = index(sign == 1 & phase == 0);
nPost   = length(PostI);
nPre    = length(PreI);

[mean(PreI) std(PreI) sem(PreI); mean(PostI) std(PostI) sem(PostI)]

[h,p] = ttest2(PreI, PostI)

effect400 = 4.8/0.9;    % 5.33      Based on SUA of position tollerance
effect800 = 10.2/1.6 ;  % 6.33      Based on MUA of position tollerance
effect800 = 1 - 9/31;   % 0.2903    Based on MUA of size tollerance, change at swap size / initial selectivty
PostI   = effect800 * selectivity(sign == 1 & phase == 1,3) - selectivity(sign == 1 & phase == 1,1);

pwr = sampsizepwr('t2', [mean(PreI) std(PreI)], mean(PostI), [], nPost, 'Ratio', nPre/nPost) 
    % 0.1379        %   0.1869
n = sampsizepwr('t2', [mean(PreI) std(PreI)], mean(PostI), 0.8) 
    % 1115          %   725

    % To detect a change of 29% in the swap condition we would need 575 SU
    % per group. Our current power is 22.37%