function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

    output_file_name = 'levenshtein_output.txt';
    %output_file = fopen(output_file_name, 'w');
    %fclose(output_file);

    hyp_file = textread(hypothesis, '%s', 'delimiter', '\n');

    SE = 0;
    IE = 0;
    DE = 0;
    num_reference_words = 0;

    for i=1:1%length(hyp_file)
        ref_file_name = ['unkn_', int2str(i), '.txt'];
        ref_file = textread([annotation_dir, filesep, ref_file_name], '%s', 'delimiter', '\n');

        % Split by space
        ref_word_list = strsplit(ref_file{1}, ' ');
        hyp_word_list = strsplit(hyp_file{i}, ' ');
        
        % The first two are BEGINE and END index
        ref_text = ref_word_list(3:end);
        hyp_text = hyp_word_list(3:end);

        num_reference_words = num_reference_words + length(ref_text);
        
        fprintf('Reference : %s\n',  strjoin(ref_text, ' '));
        fprintf('Hypothesis: %s\n', strjoin(hyp_text, ' '));
        
        %[se_toAdd, ie_toAdd, de_toAdd] = compute_levenshtein(hyp_sent, ref_sent);
        %fprintf(output_file, 'SE: %f\n', se_toAdd / length(ref_text));
        %fprintf(output_file, 'IE: %f\n', ie_toAdd / length(ref_text));
        %fprintf(output_file, 'DE: %f\n\n', de_toAdd / length(ref_text));
        %fprintf(output_file, 'Total: %f\n\n', (se_toAdd + ie_toAdd + de_toAdd) / length(ref_text));
        
        %SE = SE + se_toAdd;
        %IE = IE + ie_toAdd;
        %DE = DE + de_toAdd;
    end
    
    SE = SE / num_reference_words;
    IE = IE / num_reference_words;
    DE = DE / num_reference_words;
    
    LEV_DIST = SE + IE + DE;
    
    %disp(SE);
    %disp(IE);
    %disp(DE);
    %disp(LEV_DIST);
end