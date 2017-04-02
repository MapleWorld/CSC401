warning('off', 'MATLAB:nargchk:deprecated')
% For mk_dbn function
% Have to reverse the order of strsplit() after adding BNT package
%addpath('/u/cs401/A3_ASR/code');
%addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7'));
addpath(genpath('./bnt'));

% The directory of where the trained data for phonemes are located
dir_hmm     = './hmms';

% The directory of where the testing data are located
%dir_test     = '/u/cs401/speechdata/Testing';
dir_test    = './Testing';

% Load phoneme data
phn_dir = dir( [ dir_test, filesep, '*', 'phn' ] );
mfcc_dir = dir( [ dir_test, filesep, '*', 'mfcc' ] );

% Create an empty struct for phonemes
% Keep track of correct and total # for every phoneme
phoneme_struct = struct();

% Keep track of the total number of correct and total count
total   = 0;
correct = 0;

% For each utterance 
for i=1:length(mfcc_dir)

    file_name_phn = phn_dir(i).name;
    file_name_mfcc = mfcc_dir(i).name;

    % Load mfcc data
    mfcc_data = load([dir_test, filesep, file_name_mfcc]);

    % Read phoneme data for this speaker's utterance
    phoneme_transcription = textread([dir_test, filesep, file_name_phn], '%s', 'delimiter', '\n');
    
    % For each phoneme in utterance
    for k=1:length(phoneme_transcription)
        % Read phoneme data line by line
        % Separate out the start, end, and phoneme
        [phoneme_start, phoneme_end, phoneme]  = strread(phoneme_transcription{k}, '%d %d %s', 'delimiter', ' ');
        phoneme = char(phoneme);
        
        % Manipulate indices such that
        % 0   - 256 maps to [1, 2]
        % 256 - 512 maps to [3, 4]
        % The MFCC filtered with a windows of 256 consecutive samples 
        % of the speech waveforms, so each frame represents 256 = 16000 = 0:016 seconds of speech. 
        % These windows are moved in increments of 128 samples

        % The start index can't be less than 0
        % The end index can't exceed the number row of the matrix
        phoneme_start = max(1, round(phoneme_start / 128));
        phoneme_end   = min(phoneme_end / 128, size(mfcc_data, 1));

        % h# Marker for start and end
        if strcmp(phoneme, 'h#')
            phoneme = 'sil';
        end

        % Slice the row from index start to end
        % Each row contains all its column
        % Basically, slice the data horizontally
        mfcc_slice = mfcc_data(phoneme_start:phoneme_end, :);

        % Calculate log probability of MFCC in each trained HMM
        trained_hmms = dir([dir_hmm, filesep]);
        
        % Skip . and ..
        trained_hmms = trained_hmms(3:end); 

        max_likelihood = -Inf;
        max_probable_phoneme = '';
        
        % Go through every trained hmm and check every phoneme and see
        % which phoneme has the highest likelihood
        for k=1:length(trained_hmms)
            curr_hmm_name = trained_hmms(k).name;
            load([dir_hmm, filesep, curr_hmm_name], 'HMM', '-mat');
            data = mfcc_slice';
            likelihood = loglikHMM(HMM, data);

            if likelihood > max_likelihood
                max_likelihood  = likelihood;
                max_probable_phoneme = curr_hmm_name;
            end
        end
        
        if ~isfield(phoneme_struct, phoneme)
            phoneme_struct.(phoneme).correct = 0;
            phoneme_struct.(phoneme).total = 0;
        end
        
        % Correct if they are the same, wrong otherwise
        if strcmp(phoneme, max_probable_phoneme)
            correct = correct + 1;
            phoneme_struct.(phoneme).correct = phoneme_struct.(phoneme).correct + 1;
        end
        
        total = total + 1;
        phoneme_struct.(phoneme).total = phoneme_struct.(phoneme).total + 1;

        %break;
    end
    %break;
end

% Report the accuracy for every phoneme
phoneme_list = fields(phoneme_struct);
for i=1:length(phoneme_list)
    phoneme_name = phoneme_list{i};
    data = phoneme_struct.(phoneme_name);
    phoneme_accuracy = data.correct / data.total;
    %fprintf('Phoneme: %s, #correct: %d, # total: %d, accuracy: %f \n', phoneme_name, data.correct, data.total, phoneme_accuracy);
end

% Report on the proportion of correct classifications
% Divide the correct # phonemes over the total # phonemes in all *.phn files in Testing/
percent_correct = correct / total;
fprintf('Final accuracy of classificaiton: %f \n', percent_correct);

%rmpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7'));
rmpath(genpath('./bnt'));
