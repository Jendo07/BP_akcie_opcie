function selection = select_ipm_parameters(firstSeed, NValues, numSeeds, epsilon, thetaValues, ksiValues, caseTypes, makeSelectionPlots, makeInfluencePlots)
% SELECT_IPM_PARAMETERS
% Vyberie vhodnú kombináciu parametrov theta a ksi pre IPM pri fixnom epsilon.
%
% Funkcia:
%   1. otestuje kombinácie theta x ksi,
%   2. porovná IPM s linprog,
%   3. vyberie najlepšiu kombináciu pre každý prípad,
%   4. vypíše 10 najlepších a 10 najhorších kombinácií,
%   5. voliteľne vykreslí grafy výberu parametrov,
%   6. voliteľne vykreslí grafy vplyvu theta a ksi.
%
% Dôležité:
%   Pre každé N sa používa samostatná skupina seedov.
%   Tým sa predchádza tomu, aby trhy pre väčšie N boli iba rozšírením
%   trhov pre menšie N pri rovnakom seede.

    if nargin < 1 || isempty(firstSeed), firstSeed = 1; end
    if nargin < 2 || isempty(NValues), NValues = 5:10; end
    if nargin < 3 || isempty(numSeeds), numSeeds = 30; end
    if nargin < 4 || isempty(epsilon), epsilon = 1e-8; end
    if nargin < 5 || isempty(thetaValues), thetaValues = 0.1:0.1:0.9; end
    if nargin < 6 || isempty(ksiValues), ksiValues = [1e-10 1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1]; end
    if nargin < 7 || isempty(caseTypes), caseTypes = {'call','put','all'}; end
    if nargin < 8 || isempty(makeSelectionPlots), makeSelectionPlots = true; end
    if nargin < 9 || isempty(makeInfluencePlots), makeInfluencePlots = true; end

    NValues = NValues(:).';
    caseTypes = string(caseTypes);

    totalUsedSeeds = numel(NValues) * numSeeds;
    lastSeed = firstSeed + totalUsedSeeds - 1;

    fprintf('\n============================================================\n');
    fprintf(' VÝBER PARAMETROV IPM\n');
    fprintf('============================================================\n');
    fprintf('epsilon = %s\n', fmtSci(epsilon));
    fprintf('theta   = %s\n', mat2str(thetaValues));
    fprintf('ksi     = %s\n', strjoin(arrayfun(@fmtSci, ksiValues, 'UniformOutput', false), ', '));
    fprintf('NValues = %s\n', mat2str(NValues));
    fprintf('počet seedov pre každé N = %d\n', numSeeds);
    fprintf('celkový rozsah použitých seedov = %d-%d\n', firstSeed, lastSeed);
    fprintf('Pre každé N sa používa samostatná skupina seedov.\n');

    numTests = numel(thetaValues) * numel(ksiValues) * numel(NValues) * numSeeds * numel(caseTypes);

    comboIdCol = zeros(numTests, 1);
    epsilonCol = zeros(numTests, 1);
    thetaCol = zeros(numTests, 1);
    ksiCol = zeros(numTests, 1);
    NCol = zeros(numTests, 1);
    seedCol = zeros(numTests, 1);
    caseCol = strings(numTests, 1);
    okCol = false(numTests, 1);
    valueErrorCol = NaN(numTests, 1);
    residualCol = NaN(numTests, 1);
    dualGapCol = NaN(numTests, 1);
    timeCol = NaN(numTests, 1);
    errorCol = strings(numTests, 1);

    row = 0;
    comboId = 0;

    for theta = thetaValues
        for ksi = ksiValues

            comboId = comboId + 1;

            fprintf('\nKombinácia %d: epsilon=%s, theta=%s, ksi=%s\n', ...
                comboId, fmtSci(epsilon), fmtTheta(theta), fmtSci(ksi));

            for nIndex = 1:numel(NValues)

                N = NValues(nIndex);

                seedStart = firstSeed + (nIndex - 1) * numSeeds;
                seedEnd = seedStart + numSeeds - 1;

                fprintf('  Testujem N = %d, seedy %d-%d\n', N, seedStart, seedEnd);

                for seedIndex = 1:numSeeds

                    marketSeed = seedStart + seedIndex - 1;

                    for caseType = caseTypes

                        row = row + 1;

                        comboIdCol(row) = comboId;
                        epsilonCol(row) = epsilon;
                        thetaCol(row) = theta;
                        ksiCol(row) = ksi;
                        NCol(row) = N;
                        seedCol(row) = marketSeed;
                        caseCol(row) = caseType;

                        try
                            result = compare_ipm_linprog_by_seed( ...
                                marketSeed, N, char(caseType), epsilon, theta, ksi);

                            okCol(row) = result.overallOk;
                            valueErrorCol(row) = result.valueError;
                            residualCol(row) = result.residualIpm;
                            dualGapCol(row) = result.dualGapIpm;
                            timeCol(row) = result.ipmTime;

                        catch ME
                            okCol(row) = false;
                            errorCol(row) = string(ME.message);
                        end
                    end
                end
            end
        end
    end

    detailTable = table( ...
        comboIdCol, epsilonCol, thetaCol, ksiCol, NCol, seedCol, caseCol, ...
        okCol, valueErrorCol, residualCol, dualGapCol, timeCol, errorCol, ...
        'VariableNames', { ...
            'comboId','epsilon','theta','ksi','N','seed','caseType', ...
            'overallOk','valueError','residualIpm','dualGapIpm','ipmTime','errorMessage'} ...
    );

    summaryTable = make_summary(detailTable);
    bestByCase = table();

    fprintf('\n============================================================\n');
    fprintf(' SÚHRN VÝBERU PARAMETROV\n');
    fprintf('============================================================\n');

    for caseType = caseTypes

        caseRows = summaryTable(summaryTable.caseType == caseType, :);

        bestRows = sort_best(caseRows);
        worstRows = sort_worst(caseRows);
        candidates = get_candidates(caseRows);

        best = bestRows(1, :);
        worst = worstRows(1, :);
        avgTime = mean(candidates.avgIpmTime, 'omitnan');

        bestByCase = [bestByCase; best]; %#ok<AGROW>

        fprintf('\n------------------------------------------------------------\n');
        fprintf(' PRÍPAD: %s\n', upper(char(caseType)));
        fprintf('------------------------------------------------------------\n');

        fprintf('Najlepšia kombinácia:\n');
        print_combo(best);

        fprintf('\nNajhoršia kombinácia:\n');
        print_combo(worst);

        fprintf('\nPorovnanie časov:\n');
        fprintf('  najlepší čas                = %.10f s\n', best.avgIpmTime);
        fprintf('  priemerný čas kombinácií    = %.10f s\n', avgTime);
        fprintf('  najhorší čas                = %.10f s\n', worst.avgIpmTime);
        fprintf('  rozdiel priemer - najlepší  = %.10f s\n', avgTime - best.avgIpmTime);
        fprintf('  rozdiel najhorší - najlepší = %.10f s\n', worst.avgIpmTime - best.avgIpmTime);

        fprintf('\n10 najlepších kombinácií:\n');
        disp(printable_table(bestRows(1:min(10, height(bestRows)), :)));

        fprintf('\n10 najhorších kombinácií:\n');
        disp(printable_table(worstRows(1:min(10, height(worstRows)), :)));

        if makeSelectionPlots
            plot_selection(caseType, bestRows, best, worst, avgTime, firstSeed, lastSeed);
        end

        if makeInfluencePlots
            plot_influence_pair(caseRows, best, caseType, firstSeed, lastSeed);
        end
    end

    selection = struct();
    selection.detailTable = detailTable;
    selection.summaryTable = summaryTable;
    selection.bestByCase = bestByCase;

    selection.parameters = struct( ...
        'firstSeed', firstSeed, ...
        'lastSeed', lastSeed, ...
        'NValues', NValues, ...
        'numSeedsPerN', numSeeds, ...
        'totalUsedSeeds', totalUsedSeeds, ...
        'epsilon', epsilon, ...
        'thetaValues', thetaValues, ...
        'ksiValues', ksiValues, ...
        'caseTypes', caseTypes ...
    );
end


function summaryTable = make_summary(detailTable)
% MAKE_SUMMARY
% Vytvorí súhrn po kombináciách a prípadoch.

    [G, comboId, epsilon, theta, ksi, caseType] = findgroups( ...
        detailTable.comboId, detailTable.epsilon, detailTable.theta, detailTable.ksi, detailTable.caseType);

    totalTests = splitapply(@numel, detailTable.overallOk, G);
    okTests = splitapply(@sum, detailTable.overallOk, G);

    summaryTable = table( ...
        comboId, epsilon, theta, ksi, caseType, ...
        totalTests, ...
        okTests, ...
        totalTests - okTests, ...
        100 * okTests ./ totalTests, ...
        splitapply(@max_omitnan, detailTable.valueError, G), ...
        splitapply(@max_omitnan, detailTable.residualIpm, G), ...
        splitapply(@max_omitnan, detailTable.dualGapIpm, G), ...
        splitapply(@mean_omitnan, detailTable.ipmTime, G), ...
        splitapply(@all, detailTable.overallOk, G), ...
        'VariableNames', { ...
            'comboId','epsilon','theta','ksi','caseType', ...
            'totalTests','okTests','failedTests','successRate', ...
            'maxValueError','maxResidualIpm','maxDualGapIpm','avgIpmTime','isSuccessfulCombination'} ...
    );
end


function T = get_candidates(T)
% GET_CANDIDATES
% Ak existujú 100 % úspešné kombinácie, používa iba tie.

    successful = T(T.isSuccessfulCombination, :);

    if ~isempty(successful)
        T = successful;
    end
end


function T = sort_best(T)
% SORT_BEST
% Zoradí kombinácie od najlepšej po najhoršiu.

    T = get_candidates(T);
    T = sortrows(T, ...
        {'avgIpmTime','maxValueError','maxResidualIpm','maxDualGapIpm'}, ...
        {'ascend','ascend','ascend','ascend'});
end


function T = sort_worst(T)
% SORT_WORST
% Zoradí kombinácie od najhoršej po najlepšiu.

    T = get_candidates(T);
    T = sortrows(T, ...
        {'avgIpmTime','maxValueError','maxResidualIpm','maxDualGapIpm'}, ...
        {'descend','descend','descend','descend'});
end


function print_combo(row)
% PRINT_COMBO
% Vypíše jednu kombináciu parametrov.

    fprintf('  comboId           = %d\n', row.comboId);
    fprintf('  epsilon           = %s\n', fmtSci(row.epsilon));
    fprintf('  theta             = %s\n', fmtTheta(row.theta));
    fprintf('  ksi               = %s\n', fmtSci(row.ksi));
    fprintf('  úspešnosť         = %.2f %%\n', row.successRate);
    fprintf('  priemerný čas IPM = %.10f s\n', row.avgIpmTime);
    fprintf('  max. chyba výnosu = %.10f\n', row.maxValueError);
end


function outputTable = printable_table(T)
% PRINTABLE_TABLE
% Zjednodušená tabuľka pre výpis.

    outputTable = table( ...
        T.comboId, ...
        arrayfun(@fmtSci, T.epsilon, 'UniformOutput', false), ...
        arrayfun(@fmtTheta, T.theta, 'UniformOutput', false), ...
        arrayfun(@fmtSci, T.ksi, 'UniformOutput', false), ...
        T.successRate, ...
        T.avgIpmTime, ...
        T.maxValueError, ...
        'VariableNames', {'comboId','epsilon','theta','ksi','successRate','avgIpmTime','maxValueError'} ...
    );
end


function plot_selection(caseType, bestRows, best, worst, avgTime, firstSeed, lastSeed)
% PLOT_SELECTION
% Vykreslí graf 10 najlepších kombinácií a porovnanie časov.

    topRows = bestRows(1:min(10, height(bestRows)), :);

    figure('Name', sprintf('Výber parametrov IPM - %s', upper(char(caseType))));
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    nexttile;
    plot_top10(topRows, caseType, firstSeed, lastSeed);

    nexttile;
    plot_time_comparison(caseType, best, worst, avgTime, firstSeed, lastSeed);
end


function plot_top10(T, caseType, firstSeed, lastSeed)
% PLOT_TOP10
% Graf 10 najlepších kombinácií.

    n = height(T);
    labels = strings(n, 1);

    for i = 1:n
        labels(i) = sprintf('\\theta=%s, \\xi=%s', fmtTheta(T.theta(i)), fmtPow10(T.ksi(i)));
    end

    bar(1:n, T.avgIpmTime);

    xticks(1:n);
    xticklabels(labels);
    set(gca, 'TickLabelInterpreter', 'tex');

    xlabel('Kombinácia parametrov');
    ylabel('Priemerný čas IPM [s]');
    title(sprintf('10 najlepších kombinácií - CASE %s, SEEDS %d-%d', ...
        upper(char(caseType)), firstSeed, lastSeed));

    grid on;
    xtickangle(45);
end


function plot_time_comparison(caseType, best, worst, avgTime, firstSeed, lastSeed)
% PLOT_TIME_COMPARISON
% Graf porovnania najlepšej, priemernej a najhoršej kombinácie.

    values = [best.avgIpmTime, avgTime, worst.avgIpmTime];

    labels = { ...
        sprintf('najlepšia: \\theta=%s, \\xi=%s', fmtTheta(best.theta), fmtPow10(best.ksi)), ...
        'priemerná', ...
        sprintf('najhoršia: \\theta=%s, \\xi=%s', fmtTheta(worst.theta), fmtPow10(worst.ksi)) ...
    };

    bar(1:3, values);

    xticks(1:3);
    xticklabels(labels);
    set(gca, 'TickLabelInterpreter', 'tex');

    ylabel('Priemerný čas IPM [s]');
    title(sprintf('Porovnanie časov - CASE %s, SEEDS %d-%d', ...
        upper(char(caseType)), firstSeed, lastSeed));

    grid on;
    xtickangle(20);

    text(1:3, values, compose('%.6f s', values), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom');
end


function plot_influence_pair(caseRows, best, caseType, firstSeed, lastSeed)
% PLOT_INFLUENCE_PAIR
% Vykreslí vplyv theta a vplyv ksi pri fixovanom druhom parametri.

    figure('Name', sprintf('Vplyv parametrov IPM - %s', upper(char(caseType))));
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    nexttile;
    plot_influence( ...
        caseRows, "theta", "ksi", best.ksi, ...
        sprintf('Vplyv parametra \\theta pri \\epsilon = %s, \\xi = %s, CASE %s, SEEDS %d-%d', ...
        fmtPow10(best.epsilon), fmtPow10(best.ksi), upper(char(caseType)), firstSeed, lastSeed));

    nexttile;
    plot_influence( ...
        caseRows, "ksi", "theta", best.theta, ...
        sprintf('Vplyv parametra \\xi pri \\epsilon = %s, \\theta = %s, CASE %s, SEEDS %d-%d', ...
        fmtPow10(best.epsilon), fmtTheta(best.theta), upper(char(caseType)), firstSeed, lastSeed));
end


function plot_influence(caseRows, variableName, fixedName, fixedValue, graphTitle)
% PLOT_INFLUENCE
% Univerzálne vykreslenie vplyvu theta alebo ksi.

    rows = get_candidates(caseRows);
    rows = rows(abs(rows.(fixedName) - fixedValue) < 1e-15, :);
    rows = sortrows(rows, variableName);

    if isempty(rows)
        warning('Nie sú dostupné dáta pre graf vplyvu parametra %s.', variableName);
        return;
    end

    if variableName == "theta"
        x = rows.theta;
        xLabels = arrayfun(@fmtTheta, rows.theta, 'UniformOutput', false);
        color = [0.20 0.50 1.00];
        xName = '\theta';
    else
        x = 1:height(rows);
        xLabels = arrayfun(@fmtPow10, rows.ksi, 'UniformOutput', false);
        color = [0.20 0.70 0.30];
        xName = '\xi';
    end

    plot(x, rows.avgIpmTime, '-o', ...
        'LineWidth', 1.8, ...
        'MarkerSize', 7, ...
        'Color', color, ...
        'MarkerFaceColor', color);

    xlabel(xName);
    ylabel('Priemerný čas IPM [s]');
    title(graphTitle, 'Interpreter', 'tex');
    grid on;

    xticks(x);
    xticklabels(xLabels);
    set(gca, 'TickLabelInterpreter', 'tex');
end


function value = max_omitnan(x)
% MAX_OMITNAN
% Maximum bez NaN hodnôt.

    value = max(x, [], 'omitnan');
end


function value = mean_omitnan(x)
% MEAN_OMITNAN
% Priemer bez NaN hodnôt.

    value = mean(x, 'omitnan');
end


function textValue = fmtSci(value)
% FMTSCI
% Formát pre výpisy, napr. 1e-8.

    textValue = sprintf('%.10e', value);
    textValue = regexprep(textValue, '(\.\d*?)0+e', '$1e');
    textValue = regexprep(textValue, '\.e', 'e');
    textValue = regexprep(textValue, 'e([+-])0*(\d+)', 'e$1$2');
    textValue = strrep(textValue, 'e+', 'e');
end


function textValue = fmtTheta(value)
% FMTTHETA
% Formát pre theta, napr. 0.1.

    textValue = sprintf('%.10f', value);
    textValue = regexprep(textValue, '0+$', '');
    textValue = regexprep(textValue, '\.$', '');

    if isempty(textValue)
        textValue = '0';
    end
end


function textValue = fmtPow10(value)
% FMTPOW10
% Formát pre grafy: 10^{-1}, 10^{-2}, ...

    exponent = round(log10(value));

    if abs(value - 10^exponent) < 1e-15
        textValue = sprintf('10^{%d}', exponent);
    else
        textValue = fmtSci(value);
    end
end