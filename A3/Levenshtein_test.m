function [SE IE DE LEV_DIST] = Levenshtein_test(hypothesis,annotation_dir)
    % Input:
    %   hypothesis: The path to file containing the the recognition hypotheses
    %   annotation_dir: The path to directory containing the annotations
    %           (Ex. the Testing dir containing all the *.txt files)
    % Outputs:
    %   SE: proportion of substitution errors over all the hypotheses
    %   IE: proportion of insertion errors over all the hypotheses
    %   DE: proportion of deletion errors over all the hypotheses
    %   LEV_DIST: proportion of overall error in all hypotheses

    fid = fopen(hypothesis);
    SE = 0;
    IE = 0;
    DE = 0;
    LEV_DIST = 0;
    ref_words = 0;
    l = 1;

    % read hypothesis file line by line
    tline = fgetl(fid);
    while ischar(tline)
       % then open a corresponding unkn_i.txt file
       unk_fp = strcat(annotation_dir, '/', 'unkn_', int2str(l), '.txt');
       unk_fid = fopen(unk_fp);
       annotation_line = fgetl(unk_fid);

       tokenized_ref = strread(annotation_line, '%s');
       tokenized_hyp = strread(tline, '%s');

       % skip first 2 items, as they are [begin] and [end] markers
       tokenized_ref = tokenized_ref(3:end);
        tokenized_hyp = tokenized_hyp(3:end);

        N = length(tokenized_ref)+1; % length of reference
        M = length(tokenized_hyp)+1; % length of hypothesis

        % count total number of words
        ref_words = ref_words + length(tokenized_ref);

        B = {}; % backtrack matrix
        % initialize R
        R = [];
        R(1, 1) = 0;
        for x=1:N
            R(x, 1) = 0;
        end
        for y=1:M
            R(1, y) = 0;
        end

        % calculate distances
        for x=2:N
            for y=2:M
                if (strcmp(tokenized_ref(x-1), tokenized_hyp(y-1)) == 1)
                    R(x,y)=R(x-1,y-1);
                else
                    cur_SE = R(x-1,y-1) + 1;
                    cur_IE = R(x, y-1) + 1;
                    cur_DE = R(x-1, y) + 1;
                    lev_arr = [cur_SE cur_IE cur_DE];
                    [elem idx] = min(lev_arr);
                    R(x,y) = elem;

                    % register word errors into backtrack matrix
                    if (idx == 1)
                       B{x, y} = 'up-left';
                    elseif (idx == 2)
                       B{x, y} = 'left';
                    elseif (idx == 3)
                       B{x, y} = 'up';
                    else
                       B{x, y} = 'none';
                    end
                end;
            end
        end

        lev = 100*R(N,M)/N;

        %fprintf('lev dist: %d\n\n', lev);
        %disp(B);

        % Start backtracking
        p = size(B, 1);
        q = size(B, 2);

        while ((p ~= 2) || (q ~= 2))

            % this is needed b/c for some reason the loop guard above
            % is being ignored sometimes
            if (p == 2 || q == 2)
                break;
            end

            % insertion
            if (strcmp(B(p,q), 'left') == 1)
                IE = IE + 1;
                q = q-1;

            % deletion
            elseif (strcmp(B(p,q), 'up') == 1)
                DE = DE + 1;
                p = p-1;
            % substitution
            elseif (strcmp(B(p,q), 'up-left') == 1)
                SE = SE + 1;
                p = p-1;
                q = q-1;

            % default case, just move diagonally
            else
                p = p-1;
                q = q-1;
            end
        end

        tline = fgetl(fid);
        l = l + 1;
    end
    fclose(fid);

    SE = SE/ref_words;
    IE = IE/ref_words;
    DE = DE/ref_words;
    LEV_DIST = SE + IE + DE;
    
    disp(SE);
    disp(IE);
    disp(DE);
    disp(LEV_DIST);
end