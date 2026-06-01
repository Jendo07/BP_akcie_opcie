function result = compare_ipm_linprog_by_seed(seed, N, caseType, epsilon, theta, ksi)
% COMPARE_IPM_LINPROG_BY_SEED
% Porovná riešenie ULP úlohy pomocou linprog a IPM pre jeden seed a jeden prípad.
%
% INPUTS:
%   seed     - seed pre generovanie trhu
%   N        - počet akcií na trhu
%   caseType - typ prípadu: 'call', 'put' alebo 'all'
%   epsilon  - presnosť IPM a zároveň tolerancia porovnania
%   theta    - parameter znižovania mi
%   ksi      - parameter blízkosti ku centrálnej trajektórii
%
% OUTPUT:
%   result   - štruktúra s riešeniami linprog, IPM a ich porovnaním

    if nargin < 4 || isempty(epsilon)
        epsilon = 1e-10;
    end

    if nargin < 5 || isempty(theta)
        theta = 0.2;
    end

    if nargin < 6 || isempty(ksi)
        ksi = 1e-10;
    end

    caseType = lower(caseType);

    % 1. Vygenerovanie trhu a zostavenie ULP úlohy.
    M = generate_market(N, seed);
    problem = build_ulp_problem(M, caseType);

    % 2. Referenčné riešenie pomocou linprog.
    tic;
    linprogResult = solve_with_linprog(problem);
    linprogTime = toc;

    if linprogResult.exitflag <= 0
        error('linprog nenašiel optimálne riešenie. exitflag = %d', linprogResult.exitflag);
    end

    % 3. Počiatočný vnútorný bod a riešenie pomocou IPM.
    [x0, s0] = find_initial_point(M, caseType, problem.A, problem.c);

    tic;
    [xIpm, sIpm] = interior_point_method(problem.A, x0, s0, epsilon, theta, ksi);
    ipmTime = toc;

    % 4. Výnosnosti portfólia.
    returnLinprog = -problem.c' * linprogResult.x;
    returnIpm = -problem.c' * xIpm;

    % 5. Kontrolné hodnoty.
    valueError = abs(returnLinprog - returnIpm);
    vectorError = norm(linprogResult.x - xIpm);

    residualLinprog = norm(problem.A * linprogResult.x - problem.b, inf);
    residualIpm = norm(problem.A * xIpm - problem.b, inf);

    dualGapIpm = xIpm' * sIpm;

    minXIpm = min(xIpm);
    minSIpm = min(sIpm);

    linprogOk = linprogResult.exitflag > 0;
    valueOk = valueError <= epsilon;
    residualLinprogOk = residualLinprog <= epsilon;
    residualIpmOk = residualIpm <= epsilon;
    dualGapOk = dualGapIpm <= epsilon;

    nonnegativeOk = minXIpm >= -epsilon && ...
                    minSIpm >= -epsilon;

    overallOk = ...
        linprogOk && ...
        valueOk && ...
        residualLinprogOk && ...
        residualIpmOk && ...
        dualGapOk && ...
        nonnegativeOk;

    % 6. Výstupná štruktúra.
    result = struct();

    result.seed = seed;
    result.N = N;
    result.caseType = caseType;

    result.market = M;
    result.problem = problem;

    result.x0 = x0;
    result.s0 = s0;

    result.xLinprog = linprogResult.x;
    result.xIpm = xIpm;
    result.sIpm = sIpm;

    result.returnLinprog = returnLinprog;
    result.returnIpm = returnIpm;

    result.valueError = valueError;
    result.vectorError = vectorError;

    result.residualLinprog = residualLinprog;
    result.residualIpm = residualIpm;
    result.dualGapIpm = dualGapIpm;

    result.minXIpm = minXIpm;
    result.minSIpm = minSIpm;

    result.linprogExitflag = linprogResult.exitflag;

    result.linprogTime = linprogTime;
    result.ipmTime = ipmTime;

    result.linprogOk = linprogOk;
    result.valueOk = valueOk;
    result.residualLinprogOk = residualLinprogOk;
    result.residualIpmOk = residualIpmOk;
    result.dualGapOk = dualGapOk;
    result.nonnegativeOk = nonnegativeOk;
    result.overallOk = overallOk;

    result.parameters = struct();
    result.parameters.epsilon = epsilon;
    result.parameters.theta = theta;
    result.parameters.ksi = ksi;
end