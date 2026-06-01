function M = generate_calls(M)
% Funkcia ktorá vygeneruje parametre call opcií 
%
% Každá opcia je reprezentovaná týmito hodnotami : 
%   k_i         - realizačná cena strike
%   q_i         - rizikovo-neutrálna pravdepodobnosť
%   c_i         - cena call opcie v čase 0 
%   gamma_i     - koeficient vystupujúci v kovarianciách
%   r_i^Call    - očakávaná výnosnosť call opcie


    N = M.N;
    u = M.stocks.u(:);
    d = M.stocks.d(:);
    p = M.p;
    rf = M.rf;

    k = zeros(N,1); 
    q = zeros(N,1);
    c = zeros(N,1);   
    gamma = zeros(N,1);
    rCall = zeros(N,1);

    for i = 1:N
        % Strike v intervale medzi u a d 
        low = min(d(i), u(i));
        high = max(d(i), u(i));
        k(i) = low + (high - low) * rand;

        % Rizikovo-neutrálna pravdepodobnosť
        q(i) = ((1 + rf) - d(i)) / (u(i) - d(i));

        % Payoffy 
        payoffU = max(u(i) - k(i), 0);
        payoffD = max(d(i) - k(i), 0);

        % Cena call opcie
        c(i) = (q(i) * payoffU + (1 - q(i)) * payoffD) / (1 + rf);

        % Gamma
        gamma(i) = (payoffU - payoffD) / c(i);

        % Očakávaná výnosnosť call opcie
        rCall(i) = p * (payoffU /c(i) - 1) + (1 - p) * (payoffD / c(i) - 1);
    end

    M.calls.k = k;
    M.calls.q = q;
    M.calls.c = c;
    M.calls.gamma = gamma;
    M.calls.r = rCall;
end