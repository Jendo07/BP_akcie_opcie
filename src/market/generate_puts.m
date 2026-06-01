function M = generate_puts(M)
% Funkcia ktorá vygeneruje parametre put opcií 
%
% Každá opcia je reprezentovaná týmito hodnotami : 
%   k_i         - realizačná cena strike * ROVNAKÁ S CALL 
%   q_i         - rizikovo-neutrálna pravdepodobnosť * ROVNAKÁ S CALL
%   o_i         - cena put opcie v čase 0 
%   delta_i     - koeficient vystupujúci v kovarianciách
%   r_i^Put     - očakávaná výnosnosť put opcie

   
    N  = M.N;
    u  = M.stocks.u(:);
    d  = M.stocks.d(:);
    p  = M.p;
    rf = M.rf;
    k = M.calls.k(:);   
    q = M.calls.q(:);  

    o = zeros(N, 1);    
    delta = zeros(N, 1);
    rPut = zeros(N, 1);  

    for i = 1:N
        % Payoffy
        payoffU = max(k(i) - u(i), 0);
        payoffD = max(k(i) - d(i), 0);

        % Cena put opcie
         o(i) = (q(i) * payoffU + (1 - q(i)) * payoffD) / (1 + rf);

        % Delta
        delta(i) = (payoffU - payoffD) / o(i);

        % Očakávaná výnosnosť put opcie
        rPut(i) = p * (payoffU / o(i) - 1) + (1 - p) * (payoffD / o(i) - 1);
    end

    M.puts.k = k;
    M.puts.q = q;
    M.puts.o = o;
    M.puts.delta = delta;
    M.puts.r = rPut;
end