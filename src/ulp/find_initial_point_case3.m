function x0 = find_initial_point_case3(M)
% Funkcia ktorá nájde počiatočný primárny vnútorný bod pre prípad 3:
%   akcie + put opcie.
%
%
% INPUT:
%   M  - štruktúra trhu
%
% OUTPUT:
%   x0 - počiatočný bod v tvare [x_1,...,x_N, z_1,...,z_N]^T
%
% Poznámka:
%   Základné hraničné riešenie je vyjadrené cez akcie x_1 a x_2.
%   Ostatné akcie a put opcie sa nastavia na malé kladné parx
%   a hodnoty x_1, x_2 sa dopočítajú.


    N = M.N;
    u = M.stocks.u(:);
    d = M.stocks.d(:);
    delta = M.puts.delta(:);
    
    denom = u(1) - d(1) + d(2) - u(2);
    x1_lined = (d(2) - u(2)) / denom;
    x2_lined = (u(1) - d(1)) / denom;
    
    % Koeficienty pre dopočet x_1 a x_2.
    alpha = zeros(N, 1);
    beta  = zeros(N, 1);

    for i = 3:N
        alpha(i) = (u(2) - d(2) - u(i) + d(i)) / denom;
        beta(i)  = (u(i) - d(i) - u(1) + d(1)) / denom;
    end

    g1 = (u(2) - d(2) - delta) / denom;
    g2 = (delta + d(1) - u(1)) / denom;

    % Výber malého kladného parametra podľa teoretickej hranice.
    Lmin = min([alpha(3:end); beta(3:end); g1; g2]);
    
    upperBound1 = x1_lined / (2 * (1 - N) * Lmin);
    upperBound2 = x2_lined / (2 * (1 - N) * Lmin);
    parx = 0.5 * min(upperBound1, upperBound2);

    % Premenné x_3,...,x_N a z_1,...,z_N nastavíme na parx.
    x = zeros(N, 1);
    z = parx * ones(N, 1);

    if N >= 3
        x(3:N) = parx;
    end

    x(1) = x1_lined + sum(alpha .* x) + sum(g1 .* z);
    x(2) = x2_lined + sum(beta  .* x) + sum(g2 .* z);

    x0 = [x; z];
end