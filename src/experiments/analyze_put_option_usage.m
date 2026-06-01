function results = analyze_put_option_usage(firstSeed, NValues, numSeeds, epsilon, theta, ksi, weightTolerance, makePlot)
% ANALYZE_PUT_OPTION_USAGE
% Jednoduchý test výskytu put opcie v optimálnom portfóliu.
%
% Funkcia testuje prípad 3: akcie + put opcie.
%
% Cieľ:
%   - pre rôzne hodnoty N zistiť, ako často sa v optimálnom portfóliu
%     objaví put opcia,
%   - použiť nové seedovanie, teda pre každé N samostatnú skupinu seedov,
%   - vykresliť graf podielu portfólií s put opciou podľa N.
%
% Seedovanie:
%   Pre každé N sa použije samostatný rozsah seedov:
%
%   NValues(1) -> firstSeed až firstSeed + numSeeds - 1
%   NValues(2) -> ďalších numSeeds seedov
%   atď.
%
% Výstup:
%   results.detailTable
%   results.summaryByN
%   results.parameters

    if nargin < 1 || isempty(firstSeed), firstSeed = 1; end
    if nargin < 2 || isempty(NValues), NValues = [5 10 20 30 50 75 100]; end
    if nargin < 3 || isempty(numSeeds), numSeeds = 200; end
    if nargin < 4 || isempty(epsilon), epsilon = 1e-8; end
    if nargin < 5 || isempty(theta), theta = 0.9; end
    if nargin < 6 || isempty(ksi), ksi = 1e-1; end
    if nargin < 7 || isempty(weightTolerance), weightTolerance = 1e-4; end
    if nargin < 8 || isempty(makePlot), makePlot = true; end

    NValues = NValues(:).';

    totalUsedSeeds = numel(NValues) * numSeeds;
    lastSeed = firstSeed + totalUsedSeeds - 1;

    fprintf('\n============================================================\n');
    fprintf(' TEST VÝSKYTU PUT OPCIE PODĽA N\n');
    fprintf('============================================================\n');
    fprintf('NValues = %s\n', mat2str(NValues));
    fprintf('počet seedov pre každé N = %d\n', numSeeds);
    fprintf('celkový rozsah použitých seedov = %d-%d\n', firstSeed, lastSeed);
    fprintf('epsilon = %s, theta = %s, ksi = %s\n', fmtSci(epsilon), fmtTheta(theta), fmtSci(ksi));
    fprintf('hranica pre nenulovú váhu = %s\n', fmtSci(weightTolerance));
    fprintf('Pre každé N sa používa samostatná skupina seedov.\n');

    detailTable = table();

    for nIndex = 1:numel(NValues)

        N = NValues(nIndex);

        seedStart = firstSeed + (nIndex - 1) * numSeeds;
        seedEnd = seedStart + numSeeds - 1;

        fprintf('\n------------------------------------------------------------\n');
        fprintf('Testujem N = %d, seedy %d-%d\n', N, seedStart, seedEnd);
        fprintf('------------------------------------------------------------\n');

        for seedIndex = 1:numSeeds

            marketSeed = seedStart + seedIndex - 1;

            try
                r = compare_ipm_linprog_by_seed( ...
                    marketSeed, N, 'put', epsilon, theta, ksi);

                row = make_detail_row(r, marketSeed, N, weightTolerance);

            catch ME
                row = make_error_row(marketSeed, N, ME.message);
            end

            detailTable = [detailTable; row]; %#ok<AGROW>
        end
    end

    summaryByN = make_summary_by_N(detailTable);

    fprintf('\n============================================================\n');
    fprintf(' SÚHRN VÝSKYTU PUT OPCIE PODĽA N\n');
    fprintf('============================================================\n');
    disp(summaryByN);

    if makePlot
        plot_put_share_by_N(summaryByN, numSeeds);
    end

    results = struct();
    results.detailTable = detailTable;
    results.summaryByN = summaryByN;

    results.parameters = struct( ...
        'firstSeed', firstSeed, ...
        'lastSeed', lastSeed, ...
        'NValues', NValues, ...
        'numSeedsPerN', numSeeds, ...
        'totalUsedSeeds', totalUsedSeeds, ...
        'epsilon', epsilon, ...
        'theta', theta, ...
        'ksi', ksi, ...
        'weightTolerance', weightTolerance ...
    );
end


function row = make_detail_row(r, seed, N, weightTolerance)
% MAKE_DETAIL_ROW
% Vytvorí jeden riadok detailnej tabuľky.

    x = r.xLinprog(:);

    putWeights = x(N+1:2*N);
    activePutIdx = find(abs(putWeights) >= weightTolerance);

    containsPut = ~isempty(activePutIdx);
    putCount = numel(activePutIdx);

    if containsPut
        [selectedPutWeight, localIdx] = max(abs(putWeights(activePutIdx)));
        selectedPutIndex = activePutIdx(localIdx);
        selectedPutName = "z_" + string(selectedPutIndex);
    else
        selectedPutWeight = 0;
        selectedPutIndex = NaN;
        selectedPutName = "-";
    end

    row = table( ...
        N, ...
        seed, ...
        containsPut, ...
        putCount, ...
        selectedPutIndex, ...
        selectedPutName, ...
        selectedPutWeight, ...
        r.returnLinprog, ...
        string(fmtPct2(r.returnLinprog)), ...
        "OK", ...
        'VariableNames', { ...
            'N', ...
            'seed', ...
            'containsPut', ...
            'putCount', ...
            'selectedPutIndex', ...
            'selectedPutName', ...
            'selectedPutWeight', ...
            'returnValue', ...
            'returnPct', ...
            'status' ...
        } ...
    );
end


function row = make_error_row(seed, N, message)
% MAKE_ERROR_ROW
% Vytvorí riadok pre chybný test.

    row = table( ...
        N, ...
        seed, ...
        false, ...
        0, ...
        NaN, ...
        "-", ...
        NaN, ...
        NaN, ...
        "NaN", ...
        "ERROR: " + string(message), ...
        'VariableNames', { ...
            'N', ...
            'seed', ...
            'containsPut', ...
            'putCount', ...
            'selectedPutIndex', ...
            'selectedPutName', ...
            'selectedPutWeight', ...
            'returnValue', ...
            'returnPct', ...
            'status' ...
        } ...
    );
end


function summaryByN = make_summary_by_N(detailTable)
% MAKE_SUMMARY_BY_N
% Vytvorí súhrnnú tabuľku podľa N.

    Ns = unique(detailTable.N).';
    summaryByN = table();

    for N = Ns

        rows = detailTable(detailTable.N == N & detailTable.status == "OK", :);

        totalTests = height(rows);
        putTests = sum(rows.containsPut);
        noPutTests = totalTests - putTests;

        if totalTests > 0
            putSharePct = 100 * putTests / totalTests;
        else
            putSharePct = NaN;
        end

        row = table( ...
            N, ...
            totalTests, ...
            putTests, ...
            noPutTests, ...
            putSharePct, ...
            'VariableNames', { ...
                'N', ...
                'totalTests', ...
                'putTests', ...
                'noPutTests', ...
                'putSharePct' ...
            } ...
        );

        summaryByN = [summaryByN; row]; %#ok<AGROW>
    end
end


function plot_put_share_by_N(summaryByN, numSeeds)
% PLOT_PUT_SHARE_BY_N
% Graf podielu portfólií s put opciou podľa N.

    figure('Name', 'Podiel portfólií s put opciou podľa N');

    bar(summaryByN.N, summaryByN.putSharePct);
    text(summaryByN.N, summaryByN.putSharePct, ...
        compose('%.1f %%', summaryByN.putSharePct), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom');

    xlabel('N');
    ylabel('Výskyt put opcie [%]');
    title(sprintf('Podiel portfólií s put opciou podľa N na %d trhoch pre každé N', numSeeds));
    grid on;
end


function textValue = fmtPct2(value)
% FMTPCT2
% Formát percent na 2 desatinné miesta.

    if isnan(value)
        textValue = "NaN";
        return;
    end

    textValue = string(sprintf('%.2f %%', 100 * value));
    textValue = strrep(textValue, '.', ',');
end


function textValue = fmtSci(value)
% FMTSCI
% Formát napr. 1e-8.

    textValue = sprintf('%.10e', value);
    textValue = regexprep(textValue, '(\.\d*?)0+e', '$1e');
    textValue = regexprep(textValue, '\.e', 'e');
    textValue = regexprep(textValue, 'e([+-])0*(\d+)', 'e$1$2');
    textValue = strrep(textValue, 'e+', 'e');
end


function textValue = fmtTheta(value)
% FMTTHETA
% Formát napr. 0.9.

    textValue = sprintf('%.10f', value);
    textValue = regexprep(textValue, '0+$', '');
    textValue = regexprep(textValue, '\.$', '');

    if isempty(textValue)
        textValue = '0';
    end
end