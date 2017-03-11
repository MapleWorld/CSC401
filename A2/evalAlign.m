%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in
%  Task 5.

% some of your definitions
trainDir     = './Training';%'/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = './Testing/Task5';%'/u/cs401/A2_SMT/data/Hansard/Testing/Task5';
fn_LME       = './part5_LM_e.mat';
fn_LMF       = './part5_LM_f.mat';
fn_AM        = './part5_AM.mat';
lm_type      = '';
delta        = 0.01;
vocabSize    = 0;
numSentences = 1000;
sizes        = {10000};%1000, 10000, 15000, 30000, 100000};

% Train your language models. This is task 2 which makes use of task 1
%LME = lm_train( trainDir, 'e', fn_LME );
%LMF = lm_train( trainDir, 'f', fn_LMF );

LME = load(fn_LME, 'LM', '-mat');
LME = LME.LM;
%LMF = load(fn_LMF, 'LM', '-mat');

% Train your alignment model of French, given English
AMFE = {};
for i=1:length(sizes)
    AMFE{i} = align_ibm1(trainDir, sizes{i}, 10, strcat(fn_AM, int2str(sizes{i}/1000), 'K'));
end

% ... TODO: more

% TODO: a bit more work to grab the English and French sentences.
%       You can probably reuse your previous code for this

fre_lines = textread(strcat(testDir, '.f'), '%s','delimiter', '\n');
eng_lines = textread(strcat(testDir, '.e'), '%s','delimiter', '\n');

% Decode the test sentence 'fre'
for model=1:length(AMFE)
    fprintf('Trained on : %d sentences\n', sizes{model});
    correct_sum = 0;
    
    for i=1:25
        eng_sentence = strsplit(' ', preprocess(eng_lines{i}, 'e'));
        translation = decode2(preprocess(fre_lines{i}, 'f'), LME, AMFE{model}, '', delta, vocabSize);
        translation = strsplit(' ', translation);
        correct = 0;
        
        % Compare words at each position of the 2 sentences
        % Skip SENTSTART and SENTEND
        for k=2:min(length(translation), length(eng_sentence)) - 1
            if (k < length(eng_sentence))
                if strcmp(translation{k}, eng_sentence{k})
                    correct = correct + 1;
                end
            end
        end
        
        correct_sum = correct_sum + correct/(length(translation) - 2);
    end
    fprintf('Average accuracy: %f\n', correct_sum/25);
end


% TODO: perform some analysis
% add BlueMix code here

%[status, result] = unix('')
