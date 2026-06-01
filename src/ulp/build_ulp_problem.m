function problem = build_ulp_problem(M, caseType)
% Funkcia zostaví úlohu lineárneho programovania pre zvolený prípad.
%
% INPUTS:
%   M        - štruktúra trhu
%   caseType - 'call', 'put' alebo 'all'
%
% OUTPUT:
%   problem - štruktúra reprezentujúca ULP úlohu
%
%       problem.caseType
%       problem.N
%       problem.A   - matica rovnostných obmedzení
%       problem.b   - vektor pravých strán
%       problem.c   - vektor koeficientov účelovej funkcie
%
% Poznámka:
%   V teórii maximalizujeme výnos portfólia. Keďže MATLAB rieši
%   minimalizačnú úlohu, používame c = -r.

    caseType = lower(caseType);

    N = M.N;

    u = M.stocks.u(:);
    d = M.stocks.d(:);
    rStocks = M.stocks.r(:);

    % Pravá strana obmedzení : súčet váh = 1, nulové riziko = 0
    b = [1; 0];

    switch caseType

        case 'call'
            gamma = M.calls.gamma(:);
            rCalls = M.calls.r(:);

            % Premenné:
            % v = [x_1,...,x_N, y_1,...,y_N]^T
            %
            % x_i ... váha i-tej akcie
            % y_i ... váha i-tej call opcie
            A = [
                ones(1, 2*N);
                [(u - d).' gamma.']
            ];

            c = -[rStocks; rCalls];

        case 'put'
            delta = M.puts.delta(:);
            rPuts = M.puts.r(:);

            % Premenné:
            % v = [x_1,...,x_N, z_1,...,z_N]^T
            %
            % x_i ... váha i-tej akcie
            % z_i ... váha i-tej put opcie
            A = [
                ones(1, 2*N);
                [(u - d).' delta.']
            ];

            c = -[rStocks; rPuts];

        case 'all'
            gamma = M.calls.gamma(:);
            delta = M.puts.delta(:);

            rCalls = M.calls.r(:);
            rPuts = M.puts.r(:);

            % Premenné:
            % v = [x_1,...,x_N, y_1,...,y_N, z_1,...,z_N]^T
            %
            % x_i ... váha i-tej akcie
            % y_i ... váha i-tej call opcie
            % z_i ... váha i-tej put opcie
            A = [
                ones(1, 3*N);
                [(u - d).' gamma.' delta.']
            ];

            c = -[rStocks; rCalls; rPuts];

        otherwise
            error('Neznámy caseType. Použi ''call'', ''put'' alebo ''all''.');
    end

    problem = struct();
    problem.caseType = caseType;
    problem.N = N;
    problem.A = A;
    problem.b = b;
    problem.c = c;
end