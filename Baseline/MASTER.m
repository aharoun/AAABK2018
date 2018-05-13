%% MASTER FILE
% Replication file for "Innovation, Reallocation and Growth" 
% by Daron Acemoglu, Ufuk Akcigit, Harun Alp, Nicholas Bloom, William Kerr
% May 2018

clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('------------------');
disp(' BASELINE RESULTS ')
disp('------------------');

initalg('baseline');        % Initialize  global parameters
solver(1);                  % Solve the model
graphDist();                % Figure 2,(a)
graphDistIncumbentTax();    % Figure 2,(b)
compMoments();              % Firm simulation, targeted and nontargeted moments
nonTargetedMomP1P3();       % Additional non-targeted moments
run_pols();                 % One-percent subsidy policy
socplan_opt('full');        % Social planner problem full
socplan_opt('onlyQmin');    % Social planner problem, only qmin is chosen
socplan_opt('onlyX');       % Social planner problem, only innovation is chosen
policy_opt(11);             % Optimal incumbent policy
policy_opt(12);             % Optimal operation policy
policy_opt(13);             % Optimal entrant policy
policy_opt(212);            % Optimal incumbent and operation policy
compileTablesBaseline();    % create tables under folder "Output"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('---------------');
disp(' ROBUSTNESS ')
disp('---------------');

disp('Employment-weighted')
disp('--------------------');
initalg('employmentWeighted');          % Initialize  global parameters
solver(1);                              % Solve the model
compMoments();                          % Firm simulation, targeted moments
socplan_opt('full');                    % Social planner problem full
policy_opt(212);                        % Optimal incumbent and operation policy
compileTablesRobustness();              % create tables under folder "Output"
%-------------------------------------------------------------------------------
clear all;

disp('Organic sample')
disp('---------------');
initalg('organicSample');               % Initialize  global parameters
solver(1);                              % Solve the model
compMoments();                          % Firm simulation, targeted moments
socplan_opt('full');                    % Social planner problem full
policy_opt(212);                        % Optimal incumbent and operation policy
compileTablesRobustness();              % create tables under folder "Output"
%-------------------------------------------------------------------------------
clear all;

disp('Manufacturing sample')
disp('---------------------');
initalg('manufacturingSample');         % Initialize  global parameters
solver(1);                              % Solve the model
compMoments();                          % Firm simulation, targeted moments
socplan_opt('full');                    % Social planner problem full
policy_opt(212);                        % Optimal incumbent and operation policy
compileTablesRobustness();              % create tables under folder "Output"
%-------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

