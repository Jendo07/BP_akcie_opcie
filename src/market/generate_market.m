function M = generate_market(N, seed)
% Funkcia ktorá vygeneruje celý trh 
%
% INPUTS : 
%   N       - počet akcií na trhu 
%   seed    - seed generátora náhodných čísel (pre reprodukovateľnosť)
%
% OUTPUT : 
%   M               - štruktúra reprezentujúca trh 
%       M.N   
%       M.seed    
%       M.p         - pravdepodobnosť 
%       M.rf        - bezriziková úroková sadzba 
%       M.stocks    - akcie
%       M.calls     - call opcie
%       M.puts      - put opcie
%       M.Q         - kovariančná matica 
    
    M = create_empty_market(N, seed);
    M = generate_stocks(M);
    M = generate_calls(M);
    M = generate_puts(M);
    M = generate_Q(M);
end


