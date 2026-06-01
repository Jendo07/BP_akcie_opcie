function result = solve_with_linprog(problem)
% Funkcia ktorá vyrieši ULP úlohu pomocou MATLAB funkcie linprog.
%
% INPUT:
%   problem - štruktúra úlohy lineárneho programovania
%             s poľami A, b, c
%
% OUTPUT:
%   result  - štruktúra obsahujúca:
%             x        ... nájdený vektor váh,
%             exitflag ... stav ukončenia linprog.

    n = length(problem.c);

    options = optimoptions('linprog', ...
        'Algorithm', 'dual-simplex-highs', ...
        'Display', 'none');

    [x, ~, exitflag] = linprog( ...
        problem.c, ...
        [], [], ...
        problem.A, problem.b, ...
        zeros(n, 1), [], ...
        options);

    result = struct();
    result.x = x;
    result.exitflag = exitflag;
end