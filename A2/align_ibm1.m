function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
%
%  This function implements the training of the IBM-1 word alignment algorithm.
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider.
%       maxIter      : (integer) The maximum number of iterations of the EM
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
%
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz

global CSC401_A2_DEFNS

AM = struct();

% Read in the training data
[eng, fre] = read_hansard(trainDir, numSentences);

% Initialize AM uniformly
AM = initialize(eng, fre);

% Iterate between E and M steps
for iter=1:maxIter
    AM = em_step(AM, eng, fre);
end

% Save the alignment model
save( fn_AM, 'AM', '-mat');

end



% --------------------------------------------------------------------------------
%
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
%eng = {};
%fre = {};

% TODO: your code goes here.

line_count = 1;

eng = {};
fre = {};

% TODO: your code goes here.

% Get list of english and french files they will be aligned as the OS returns alphabetical order)
DE = dir([mydir, filesep, '*', 'e']);
DF = dir([mydir, filesep, '*', 'f']);

for iFile=1:length(DE)
    english_sentence = textread([mydir, filesep, DE(iFile).name], '%s','delimiter','\n');
    french_sentence = textread([mydir, filesep, DF(iFile).name], '%s','delimiter','\n');
    for i=1:length(english_sentence)
        eng{line_count} = strsplit(' ', preprocess(english_sentence{i}, 'e'));
        fre{line_count} = strsplit(' ', preprocess(french_sentence{i}, 'f'));
        line_count = line_count + 1;
        if line_count > numSentences
            return
        end
    end
end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
AM = {}; % AM.(english_word).(foreign_word)

% TODO: your code goes here

% Initialize the struct AM.(english_word).(french_word)
% Loop each sentence
for l=1:length(eng)
    % Loop each word in the sentence
    % Skip SENTSTART and SENTEND
    for e=1:length(eng{l})
        for f=1:length(fre{l})
            english_word = char(eng{l}(e));
            french_word = char(fre{l}(f));
            AM.(english_word).(french_word) = 1;
        end
    end
end

% Set the probabilitiy for each field in the AM struct
english_field_names = fieldnames(AM);
for l=1:length(english_field_names)
    french_field_names = fieldnames(AM.(english_field_names{l}));
    for k=1:length(french_field_names)
        probability = 1/length(french_field_names);
        AM.(english_field_names{l}).(french_field_names{k}) = probability;
    end
end

AM.SENTSTART.SENTSTART = 1;
AM.SENTEND.SENTEND = 1;
end

function t = em_step(t, eng, fre)
%
% One step in the EM algorithm.
%

% TODO: your code goes here

% Initialize stuff
tcount = struct();
total = struct();

% for each sentence pair (F, E) in training corpus
for l=1:length(eng)
    uniq_fr = unique(fre{l});
    uniq_eng = unique(eng{l});
    
    % for each unique word f in F:
    for i=1:length(uniq_fr)
        denom_c = 0;
        % for each unique word e in E:
        for j=1:length(uniq_eng)
            % denom_c += P(f|e) * F.count(f)
            e = uniq_eng{j};
            f = uniq_fr{i};
            denom_c = denom_c + t.(e).(f) * sum(strcmp(fre{l},f));
        end
        
        % for each unique word e in E:
        for j=1:length(uniq_eng)
            e = uniq_eng{j};
            f = uniq_fr{i};
            
            % Initialize struct if haven't initialize  yet,
            if ~isfield(tcount, f)
                tcount.(f) = struct();
            end
            if ~isfield(tcount.(f), e)
                tcount.(f).(e) = 0;
            end
            if ~isfield(total, e)
                total.(e) = 0;
            end
            
            % Compute P(f|e) * F.count(f) * E.count(e) / denom_c
            factor = t.(e).(f) * sum(strcmp(fre{l},f)) * sum(strcmp(eng{l},e)) / denom_c;
            
            %tcount(f,e) += P(f|e) * F.count(f) * E.count(e) / denom_c
            tcount.(f).(e) = tcount.(f).(e) + factor;
            %total(e) += P(f|e) * F.count(f) * E.count(e) / denom_c
            total.(e) = total.(e) + factor;
        end
    end
end

% Update our model
eng_word_list = fieldnames(t);
% for each e in domain(total(:)):
for i=1:length(eng_word_list)
    e = eng_word_list{i};
    fr_word_list = fieldnames(t.(e));
    % for each f in domain(tcount(:,e)):
    for j=1:length(fr_word_list)
        f = fr_word_list{j};
        % P(f|e) = tcount(f, e) / total(e)
        t.(e).(f) = tcount.(f).(e) / total.(e);
    end
end
end










