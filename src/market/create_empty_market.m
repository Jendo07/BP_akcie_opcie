function M = create_empty_market(N, seed)
% Vytvorí prázdnu štruktúru trhu so základnými parametrami
%
% INPUTS : 
%   N       - počet akcií na trhu 
%   seed    - seed generátora náhodných čísel (pre reprodukovateľnosť)
%
% OUTPUT : 
%   M       - prázdna štruktúra

    if nargin < 1 || isempty(N)
        error('Musíš zadať počet akcií N.');
    end

    if N < 2
        error('Počet akcií N musí byť aspoň 2.');
    end

    if nargin < 2
        seed = [];
    end

     if ~isempty(seed)
        rng(seed);
     end

    M = struct();

    % základné parametre trhu
    M.N  = N;       % počet akcií 
    M.seed = seed;  % seed pre reprodukovateľnosť 
    M.p  = 0.5;     % pravdepodobnosť nastatia udalostí U a D, DEFAULT 0,5
    M.rf = 0;       % bezriziková sadzba DEFAULT 0   
    

    % Akcie
    M.stocks = struct();
    M.stocks.u = [];
    M.stocks.d = [];
    M.stocks.r = [];

    % Call opcie
    M.calls = struct();
    M.calls.k = [];
    M.calls.c = [];
    M.calls.q = [];
    M.calls.gamma = [];
    M.calls.r = [];

    % Put opcie
    M.puts = struct();
    M.puts.k = [];
    M.puts.o = [];
    M.puts.q = [];
    M.puts.delta = [];
    M.puts.r = [];

    % Kovariančná matica
    M.Q = [];  
end
