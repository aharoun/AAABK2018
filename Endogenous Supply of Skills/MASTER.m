%% MASTER FILE
% Replication file for "Innovation, Reallocation and Growth" 
% by Daron Acemoglu, Ufuk Akcigit, Harun Alp, Nicholas Bloom, William Kerr
% May 2018

clear all;
close all;
clc;

disp('---------------------------------------------------');
disp(' ROBUSTNESS: Model with Endogenous Suppy of Skills ')
disp('---------------------------------------------------');

initalg('endogenousSkillSupply');       % Initialize  global parameters
solver(1);                              % Solve the model
compMoments();                          % Firm simulation, targeted and nontargeted moments
policy_opt(0);                          % Optimal education policy
socplan_opt('full');                    % Social planner problem full
policy_opt(212);                        % Optimal incumbent and operation policy
compileTablesRobustness();              % create tables under folder "Output"

% end


