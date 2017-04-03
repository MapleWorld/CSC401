function [SE, IE, DE] = compute_levenshtein(hyp, ref)
    % Input: REF: reference array of words
    % Input: HYP: hypothesis array of words

    % Variable that represent the operation using integer
    
    % DEL
    UP      = 1; 
    
    % SUB
    UP_LEFT_DIFF = 2;
    UP_LEFT_SAME = 3;
    
    % INS
    LEFT    = 4; 
    
    % begin
    % n = The number of words in REF
    n = length(ref);
    
    % m = The number of words in HYP
    m = length(hyp);

    % Matrix of distances
    % R = zeros(n + 1, m + 1)  
    R = zeros(n + 1, m + 1);
    
    % Backtracking matrix
    % B = zeros(n + 1, m + 1)
    B = zeros(n + 1, m + 1);

    % For all i, j s.t. i = 0 or j = 0, set R[i, j] = infinity, except R[0, 0] = 0
    R(1, :) = Inf;
    R(:, 1) = Inf;
    R(1, 1) = 0;

    % for i = 1..n do
    for i=2:n+1
        % for j = 1..m do
        for j=2:m+1
            % Use the value on the left
            % Number of insertion needed
            del = R(i - 1, j) + 1;

            % Use the value on the top-left
            % sub = R[i - 1, j - 1] + (REF[i] == HYP[j]) ? 0 : 1
            % If REF[i] == HYP[j] then it cost 0
            % + 1 otherwise
            if strcmp(ref{i - 1}, hyp{j - 1})
                sub = R(i - 1, j - 1);
            else
                sub = R(i - 1, j - 1) + 1;
            end

            % Use the value on the top
            % Number of deletion needed
            ins = R(i, j - 1) + 1;

            % R[i, j] = Min ( del, sub, ins )
            R(i, j) = min([del, sub, ins]);

            % Check and determine the type of the operation
            if R(i, j) == del
                B(i, j) = UP;    
            elseif R(i, j) == ins
                B(i, j) = LEFT; 
            elseif R(i, j) == R(i - 1, j - 1)
                B(i, j) = UP_LEFT_SAME;
            else
                B(i, j) = UP_LEFT_DIFF;
            end
        end
    end

    % Count up the different types of errors as we backtrack
    i = n + 1;
    j = m + 1;
    
    % SE: proportion of substitution errors over all the hypotheses
    % IE: proportion of insertion errors over all the hypotheses
    % DE: proportion of deletion errors over all the hypotheses

    SE = 0;
    IE = 0;
    DE = 0;
    
    % Backtracking, count the number of operation for each
    % Only increment SE iff ref{col - 1} != hyp{row - 1}
    while ((i ~= 1) || (j ~= 1))
        
        if B(i, j) == UP                    % 1
            DE = DE + 1;
            i = i - 1;
        elseif B(i, j) == UP_LEFT_DIFF      % 2
            SE = SE + 1;
            j = j - 1;
            i = i - 1;
        elseif B(i, j) == UP_LEFT_SAME      % 3
            j = j - 1;
            i = i - 1;
        elseif B(i, j) == LEFT              % 4
            IE = IE + 1;
            j = j - 1;
        end
    end

end