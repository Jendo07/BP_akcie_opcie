function x0 = find_initial_point_case4(M)
% Funckia ktorá nájde počiatočný primárny vnútorný bod pre prípad 4:
%   akcie + call opcie + put opcie.
%
% INPUT:
%   M  - štruktúra trhu
%
% OUTPUT:
%   x0 - počiatočný bod v tvare
%        [x_1,...,x_N, y_1,...,y_N, z_1,...,z_N]^T
%
% Poznámka:
%   Teoretické hraničné optimum má rovnaké jadro ako v prípade 2,
%   teda obsahuje iba y_1 a y_2. Ostatné premenné sa nahradia
%   malým kladným parametrom parx.

    N = M.N;
    u = M.stocks.u(:);
    d = M.stocks.d(:);
    q = M.calls.q(:);
    gamma = M.calls.gamma(:);
    delta = M.puts.delta(:);

    denom = 1/q(1) + 1/(1 - q(2));
    y1_lined = (1/(1 - q(2))) / denom;
    y2_lined = (1/q(1))       / denom;

    % Koeficienty pre dopočet y_1 a y_2.
    a1 = (d - u + 1/(q(2) - 1)) / denom;
    a2 = (u - d - 1/q(1))       / denom;

    b1 = zeros(N, 1);
    b2 = zeros(N, 1);

    for i = 3:N
        b1(i) = (gamma(2) - gamma(i)) / denom;
        b2(i) = (gamma(i) - gamma(1)) / denom;
    end

    h1 = (gamma(2) - delta) / denom;
    h2 = (delta - gamma(1)) / denom;

    Lmin = min([a1; a2; b1(3:end); b2(3:end); h1; h2]);

    upperBound1 = y1_lined / ((2 - 3*N) * Lmin);
    upperBound2 = y2_lined / ((2 - 3*N) * Lmin);
    parx = 0.5 * min(upperBound1, upperBound2);
   
    % Výber malého kladného parametra podľa teoretickej hranice.
    x = parx * ones(N, 1);
    y = zeros(N, 1);
    z = parx * ones(N, 1);

    if N >= 3
        y(3:N) = parx;
    end

    y(1) = y1_lined + sum(a1 .* x) + sum(b1 .* y) + sum(h1 .* z);
    y(2) = y2_lined + sum(a2 .* x) + sum(b2 .* y) + sum(h2 .* z);

    x0 = [x; y; z];
end