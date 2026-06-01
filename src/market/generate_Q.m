function M = generate_Q(M)
%Funkcia ktorá vygeneruje kovariančnú maticu Q (3N x 3N) pre všetky aktíva:
%
% 1..N        - akcie
% N+1..2N     - call opcie
% 2N+1..3N    - put opcie

    p = M.p;
    d = M.stocks.d(:);
    u = M.stocks.u(:);
    gamma = M.calls.gamma(:);
    delta = M.puts.delta(:);

    % 1..N: akcie
    vStocks = (sqrt(p * (1 - p))) * (u - d);
   
    % N+1..2N: call
    vCalls  = (sqrt(p * (1 - p))) * gamma;

    % 2N+1..3N: put
    vPuts   = (sqrt(p * (1 - p))) * delta;

    v = [vStocks; vCalls; vPuts];
    M.Q = v * v.';
end