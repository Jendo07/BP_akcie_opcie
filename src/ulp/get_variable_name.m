function name = get_variable_name(index, caseType, N)
% GET_VARIABLE_NAME
% Vráti názov premennej podľa jej indexu a typu prípadu.
%
% INPUTS:
%   index    - index premennej vo vektore váh
%   caseType - typ prípadu: 'call', 'put' alebo 'all'
%   N        - počet akcií
%
% OUTPUT:
%   name     - textový názov premennej, napr. x_1, y_2 alebo z_3

    caseType = lower(caseType);

    if index <= N
        name = sprintf('x_%d', index);
        return;
    end

    switch caseType
        case 'call'
            name = sprintf('y_%d', index - N);

        case 'put'
            name = sprintf('z_%d', index - N);

        case 'all'
            if index <= 2*N
                name = sprintf('y_%d', index - N);
            else
                name = sprintf('z_%d', index - 2*N);
            end

        otherwise
            error('Neznámy caseType. Použi ''call'', ''put'' alebo ''all''.');
    end
end