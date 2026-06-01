function main()
% Hlavná funkcia v ktorej sa spúšťajú všetky testované experimenty 
% Na spustenie experimentu je potrebné odkomentovať jednu celú sekciu 
% Pre odkomentovanie sekcie ju treba označiť a použiť : CTRL + T
% Pre následné zakomentovanie sekcie : CTRL + R

    clear;
    clc;
% TEST 1 PARAMETRE IPM A ICH VPLYV 
    % 
    % firstSeed = 1;
    % 
    % NValues = [5 10 20];
    % numSeeds = 100;
    % 
    % epsilon = 1e-8;
    % 
    % thetaValues = [0.76 0.78 0.80 0.82 0.84 0.86 0.88 0.90];
    % 
    % ksiValues = [1e-1 1e-2 1e-3 1e-4 1e-5 1e-6 1e-7 1e-8];
    % 
    % 
    % caseTypes = {'call','put','all'};
    % 
    % 
    % makeSelectionPlots = true;
    % makeInfluencePlots = true;
    % 
    % selection = select_ipm_parameters( ...
    %     firstSeed, ...
    %     NValues, ...
    %     numSeeds, ...
    %     epsilon, ...
    %     thetaValues, ...
    %     ksiValues, ...
    %     caseTypes, ...
    %     makeSelectionPlots, ...
    %     makeInfluencePlots);
   

% TEST 2 BASIC TESTY CASE 2, 3, 4 

    % firstSeed = 1;
    % NValues = [10 20 30 40 50 60 70 80 90 100];
    % numSeeds = 100;
    % 
    % parameterSets(1).name = "optimal";
    % parameterSets(1).epsilon = 1e-8;
    % parameterSets(1).theta = 0.8;
    % parameterSets(1).ksi = 1e-1;
    % 
    % parameterSets(2).name = "worst";
    % parameterSets(2).epsilon = 1e-8;
    % parameterSets(2).theta = 0.1;
    % parameterSets(2).ksi = 1e-8;
    % 
    % caseTypes = {'call', 'put', 'all'};
    % makePlots = true;
    % 
    % outputExcelFile = "ipm_linprog_results.xlsx";
    % exportExcel = true;
    % openExcel = true;
    % printDetails = false;
    % 
    % results = run_ipm_linprog_seed_tests( ...
    %     firstSeed, ...
    %     NValues, ...
    %     numSeeds, ...
    %     parameterSets, ...
    %     caseTypes, ...
    %     makePlots, ...
    %     exportExcel, ...
    %     outputExcelFile, ...
    %     openExcel, ...
    %     printDetails);

% TEST 3 VÝSKYTU PUT OPCIE PODĽA N
    % firstSeed = 1;
    % NValues = [5 10 20 30 50 75 100];
    % numSeeds = 100;
    % 
    % epsilon = 1e-8;
    % theta = 0.8;
    % ksi = 1e-1;
    % 
    % weightTolerance = 1e-4;
    % makePlot = true;
    % 
    % resultsPutUsage = analyze_put_option_usage( ...
    %     firstSeed, ...
    %     NValues, ...
    %     numSeeds, ...
    %     epsilon, ...
    %     theta, ...
    %     ksi, ...
    %     weightTolerance, ...
    %     makePlot);


% TEST 4 PODROBNEJŠÍ TEST PUT PRÍPADU 
    % firstSeed = 1;
    % 
    % NValues = 3:10;
    % numSeeds = 1000;
    % 
    % epsilon = 1e-8;
    % theta = 0.8;
    % ksi = 1e-1;
    % 
    % weightTolerance = 1e-4;
    % sampleSize = 50;
    % comparisonSampleSize = 20;
    % 
    % makePlots = true;
    % exportExcel = true;
    % outputExcelFile = "put_option_theory_analysis.xlsx";
    % openExcel = true;
    % 
    % resultsPutTheory = analyze_put_option_usage_theory( ...
    %     firstSeed, ...
    %     NValues, ...
    %     numSeeds, ...
    %     epsilon, ...
    %     theta, ...
    %     ksi, ...
    %     weightTolerance, ...
    %     sampleSize, ...
    %     comparisonSampleSize, ...
    %     makePlots, ...
    %     exportExcel, ...
    %     outputExcelFile, ...
    %     openExcel);
end

