function [x0, s0] = find_initial_point(M, caseType, A, c)
% Funkcia ktorá nájde počiatočný vnútorný bod pre zvolený prípad.
%
% INPUTS:
%   M        - štruktúra trhu
%   caseType - typ prípadu : 'call', 'put' alebo 'all'
%   A        - matica rovnostných obmedzení
%   c        - vektor koeficientov účelovej funkcie
%
% OUTPUT:
%   x0       - primárny počiatočný bod
%   s0       - duálny počiatočný bod

    caseType = lower(caseType);

    switch caseType
        case 'call'
            x0 = find_initial_point_case2(M);

        case 'put'
            x0 = find_initial_point_case3(M);

        case 'all'
            x0 = find_initial_point_case4(M);

        otherwise
            error('Neznámy caseType. Použi ''call'', ''put'' alebo ''all''.');
    end

    % Keďže c = -r, výnosový vektor je r = -c.
    r = -c;
    rmax = max(r);
    pars = 1;

    % Interný duálny vektor sa používa iba na zostavenie s0.
    pi0 = [-rmax - pars; 0];
    s0 = c - A' * pi0;
end