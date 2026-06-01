function [x_opt, s_opt] = interior_point_method(A, x0, s0, epsilon, theta, ksi)
% Funkcia ktorá rieši úlohu lineárneho programovania 
% primálno-duálnou metódou vnútorného bodu.
%
% INPUTS:
%   A       - matica rovnostných obmedzení
%   x0      - primárny počiatočný vnútorný bod
%   s0      - duálny počiatočný vnútorný bod
%   epsilon - presnosť ukončenia podľa duálnej medzery x^T*s
%   theta   - parameter redukcie mi, theta z intervalu (0,1)
%   ksi     - parameter blízkosti ku centrálnej trajektórii
%
% OUTPUTS:
%   x_opt   - výsledný vektor váh portfólia
%   s_opt   - výsledný duálny vektor

    if epsilon <= 0
        error('Parameter epsilon musí byť kladný.');
    end

    if theta <= 0 || theta >= 1
        error('Parameter theta musí byť z intervalu (0,1).');
    end

    if ksi <= 0
        error('Parameter ksi musí byť kladný.');
    end

    x = x0(:);
    s = s0(:);

    n = length(x);

    % Počiatočná hodnota bariérového parametra.
    mi = (x' * s) / n;

    delta = norm(sqrt((x .* s) / mi) - 1 ./ sqrt((x .* s) / mi));

    % Fáza 1: Centrovanie počiatočného bodu
    while delta > ksi
        [dx, ds] = compute_newton_direction(A, x, s, mi);

        omega = sqrt(norm(dx ./ x)^2 + norm(ds ./ s)^2);
        alpha = (delta^2) / (omega * (omega + delta^2));
        
        x = x + alpha * dx;
        s = s + alpha * ds;

        delta = norm(sqrt((x .* s) / mi) - 1 ./ sqrt((x .* s) / mi));
    end

    % Fáza 2: Postupné znižovanie mi až po dosiahnutie presnosti epsilon
    while (x' * s) > epsilon

        mi = (1 - theta) * mi;
        delta = norm(sqrt((x .* s) / mi) - 1 ./ sqrt((x .* s) / mi));

        while delta > ksi
            [dx, ds] = compute_newton_direction(A, x, s, mi);

            omega = sqrt(norm(dx ./ x)^2 + norm(ds ./ s)^2);
            alpha = (delta^2) / (omega * (omega + delta^2));

            x = x + alpha * dx;
            s = s + alpha * ds;

            delta = norm(sqrt((x .* s) / mi) - 1 ./ sqrt((x .* s) / mi));
        end
    end

    x_opt = x;
    s_opt = s;
end


function [dx, ds] = compute_newton_direction(A, x, s, mi)
% Pomocná funkcia ktorá vypočíta Newtonov smer riešením KKT sústavy.
%
% Používané rovnice:
%   A*dx = 0,
%   A^T*dy + ds = 0,
%   S*dx + X*ds = mi*e - X*s.

    n = length(x);
    m = size(A, 1);
    X = diag(x);
    S = diag(s);

    % Bloková matica Newtonovej sústavy
    Jacobi_matrix = [
        A,             zeros(m, m), zeros(m, n);
        zeros(n, n),    A',         eye(n);
        S,             zeros(n, m), X
    ];

     right_side = [
        zeros(m, 1);                
        zeros(n, 1);                 
        mi * ones(n, 1) - X * s     
    ];

    newton_step = Jacobi_matrix \ right_side;

    % step = [dx; dy; ds], pričom dy ďalej nepoužívame
    dx = newton_step(1:n); 
    ds = newton_step(n + m + 1:end);
end


