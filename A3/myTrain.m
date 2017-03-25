dir_train   = './Training';
M           = 8;
Q           = 3;
initType    = 'kmeans';
max_iter    = 15;
output_file = './hmm';
bnt_path    = './bnt';

% 1. Load phoneme data
main_folders = dir(dir_train);
% Length = 3 to skip . and .. directory
main_folders = main_folders(3:end);
   
phoneme_struct = struct();

% For each speaker
for i=1:length(main_folders)
    sub_folder_path = strcat(dir_train, '/', main_folders(i).name);
    utterances_folder = dir([sub_folder_path, filesep, '*', '.mfcc']);

    % For each utterance folder
    for j=1:length(utterances_folder)
        file_name = utterances_folder(j).name;
        split = strsplit(file_name, '.');
        % Re-name file name from *.mfcc to *.phn
        split{2} = 'phn';
        phn_file = strjoin(split, '.');
        
        %disp(split);
        %disp(file_name);
        %disp(phn_file);

        % Load mfcc data
        mfcc_data = load([sub_folder_path, filesep, file_name]);
        mfcc_rows = size(mfcc_data, 1);

        % Read phoneme data for this speaker's utterance
        phoneme_transcription = textread([sub_folder_path, filesep, phn_file], '%s', 'delimiter', '\n');
        disp(phoneme_transcription);
        
        % For each phoneme in utterance
        for k=1:length(phoneme_transcription)
            phoneme_data  = strsplit(phoneme_transcription{k}, ' ');
            disp(phoneme_data);
            
            % Manipulate indices such that
            % 0   - 256 maps to [1, 2]
            % 256 - 512 maps to [3, 4]
            phoneme_start = str2num(phoneme_data{1});
            phoneme_start = (phoneme_start / 128) + 1;
            phoneme_end   = str2num(phoneme_data{2});
            phoneme_end   = min(phoneme_end / 128, mfcc_rows);
            
            phoneme       = phoneme_data{3};
            if strcmp(phoneme, 'h#')
                phoneme = 'sil';
            end
            
            mfcc_slice = mfcc_data(phoneme_start:phoneme_end, :);
            
            % If we haven't seen this phoneme yet, create an empty
            % cell array
            if ~isfield(phoneme_struct, phoneme)
                phoneme_struct.(phoneme) = cell(0);
            end
            
            % Take the relevant mfcc slice, and append to cell array for
            % this phoneme
            num_phn_sequences = length(phoneme_struct.(phoneme));
            phoneme_struct.(phoneme){num_phn_sequences + 1} = mfcc_slice';
            break;
        end
        break;
    end
    break;
end

%addpath(genpath(bnt_path));

% Init and train an HMM for each of the unique phonemes seen
%{
phonemes_seen = fields(phoneme_struct);
num_phonemes_seen = length(phonemes_seen);
for i_phn=1:num_phonemes_seen
    curr_phn_name = phonemes_seen{i_phn};
    data = phoneme_struct.(curr_phn_name);
    
    HMM = initHMM(data, M, Q, initType);
    [HMM, LL] = trainHMM(HMM, data, max_iter);
    
    save([output_file, filesep, 'hmm_', curr_phn_name], 'HMM', '-mat');
end

rmpath(genpath(bnt_path));
%}