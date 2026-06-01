function M = generate_stocks(M)
    % Funkcia ktorá vygeneruje parametre akcií 
    %
    % Každá akcia je reprezentovaná týmito hodnotami : 
    %   u_i     - multiplikátor ceny udalosti U
    %   d_i     - multiplikátor ceny udalosti D 
    %   r_i     - očakávaná výnosnosť akcie.
    %
    % Súvislosť multiplikátorov je nasledovná : 
    %   u_i = 1/d_i pre každú akciu
    %
    % Prvá akcia je kladne orientovaná a platí : 
    %   u_1 - d_1 > 0
    % Druhá akcia je záporné orientovaná a platí: 
    %   u_2 - d_2 < 0 
    % Zabezpečí sa tým, že existujú aktíva s opačnou orientáciou,
    % čo je potrebné pre zostavenie portfólia s nulovým rizikom. 
    % 
    % Orientácia každej ďalšej akcie je náhodná.

    N = M.N;
    p = M.p;
    seqMin = 0.51;  
    seqMax = 0.99;

    % Náhodná postupnosť dlžky N v rozmedzí <seqMin, seqMax>
    seq = sort(seqMin + (seqMax - seqMin) * rand(N, 1));  
    
    d = zeros(N, 1);

    % Prvá akcia : kladná orientácia
    d(1) = seq(1);       

    % Druhá akcia : záporná orientácia
    d(2) = 1 / seq(2);    


    % Ďalšie akcie : náhodná orientácia 
    for i = 3:N
        if rand < 0.5
            d(i) = seq(i);       
        else
            d(i) = 1 / seq(i);   
        end
    end

    u = 1 ./ d;

    % Očakávaná výnosnosť akcie  
    r = p * (u - 1) + (1 - p) * (d - 1);

    M.stocks.d = d;
    M.stocks.u = u;
    M.stocks.r = r;
end

