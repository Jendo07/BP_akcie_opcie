function x0 = find_initial_point_case2(M)
% Funckia ktorá nájde počiatočný primárny vnútorný bod pre prípad 2:
%   akcie + call opcie.
%
% INPUT:
%   M  - štruktúra trhu
%
% OUTPUT:
%   x0 - počiatočný bod v tvare [x_1,...,x_N, y_1,...,y_N]^T
%
% Poznámka:
%   Teoretické optimum leží na hranici prípustnej množiny a obsahuje
%   iba y_1 a y_2. Pre metódu vnútorného bodu sa pôvodne nulové
%   premenné nahradia malým kladným parametrom parx.

    N = M.N;
    u = M.stocks.u(:);
    d = M.stocks.d(:);
    q = M.calls.q(:);

    denom = 1/q(1) + 1/(1 - q(2));
    y1_lined = (1/(1 - q(2))) / denom;
    y2_lined = (1/q(1))       / denom;

    % Koeficienty pre dopočet y_1 a y_2.
    a1 = (d - u + 1/(q(2) - 1)) / denom;
    a2 = (u - d - 1/q(1))       / denom;

    
    b1 = zeros(N, 1);
    b2 = zeros(N, 1);

    for i = 3:N
        if u(i) > d(i)
            b1(i) = (1/(q(2)-1) - 1/q(i)) / denom;
            b2(i) = (1/q(i) - 1/q(1))     / denom;

        else
            b1(i) = (1/(q(2)-1) + 1/(1-q(i))) / denom;
            b2(i) = (1/(q(i)-1) - 1/q(1))     / denom;
        end
    end

    % Výber malého kladného parametra podľa teoretickej hranice.
    Lmin = min([a1; a2; b1(3:end); b2(3:end)]);

    upperBound1 = y1_lined / (2 * (1 - N) * Lmin);
    upperBound2 = y2_lined / (2 * (1 - N) * Lmin);
    parx = 0.5 * min(upperBound1, upperBound2);
   
    % Pôvodne nulové premenné nastavíme na parx a dopočítame y_1, y_2.
    x = parx * ones(N, 1);
    y = zeros(N, 1);

    if N >= 3
        y(3:N) = parx;
    end

    y(1) = y1_lined + sum(a1 .* x) + sum(b1 .* y);
    y(2) = y2_lined + sum(a2 .* x) + sum(b2 .* y);

    x0 = [x; y];
end