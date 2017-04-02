function myTrainFn = myTrainFn(M, Q, P, D)
    % M : The number of Gaussian mixture components per state (default 8)
    % Q : The number of hidden states (default 3)
    % P : The amount of training data used. (proportion default 1) 
    % D : The dimensions of the mfcc data (Default 14)

    warning('off', 'MATLAB:nargchk:deprecated')
    % For mk_dbn function
    % Have to reverse the order of strsplit() after adding BNT package
    %addpath('/u/cs401/A3_ASR/code');
    %bntPath = '/u/cs401/A3_ASR/code/FullBNT-1.0.7';
    bntPath = './bnt';
    addpath(genpath(bntPath));
    
    dir_train   = './Training';

    % Load phoneme data
    main_folders = dir(dir_train);

    % Length = 3 to skip . and .. directory
    main_folders = main_folders(3:end);

    % Create an empty struct for phonemes
    phoneme_struct = struct();

    % For each speaker
    for i=1:length(main_folders)
        sub_dir_path = strcat(dir_train, '/', main_folders(i).name);

        % Load each utterance folder for *.mfcc and *.phn files

        phn_dir = dir( [ sub_dir_path, filesep, '*', 'phn' ] );
        mfcc_dir = dir( [ sub_dir_path, filesep, '*', 'mfcc' ] );

        % For each utterance folder
        for j=1:length(mfcc_dir)

            file_name_phn = phn_dir(j).name;
            file_name_mfcc = mfcc_dir(j).name;

            % Load mfcc data
            mfcc_data = load([sub_dir_path, filesep, file_name_mfcc]);

            % Resize mfcc data's dimensionaility
            mfcc_data = mfcc_data(1:end,1:D);

            % Read phoneme data for this speaker's utterance
            phoneme_transcription = textread([sub_dir_path, filesep, file_name_phn], '%s', 'delimiter', '\n');

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

                % Create an empty structure if never seen this phoneme before
                if ~isfield(phoneme_struct, phoneme)
                    phoneme_struct.(phoneme) = cell(0);
                end

                % Add relevant mfcc slice of this phoneme to th array
                num = length(phoneme_struct.(phoneme)) + 1;

                % Add the inverse of the mfcc data matrix
                phoneme_struct.(phoneme){num} = mfcc_slice';

                %break;
            end
            %break;
        end
        %break;
    end

    % max_iter : The maximum iterations of EM
    max_iter = 15;

    % initType : 'rnd' or 'kmeans' (default 'kmeans')
    initType = 'kmeans';
    
    % Init and train an HMM for each of the unique phonemes seen
    phoneme_list = fields(phoneme_struct);

    % Train each phoneme
    for i=1:length(phoneme_list)
        phoneme_name = phoneme_list{i};
        data = phoneme_struct.(phoneme_name);
        amount_of_training_data = ceil(P * length(phoneme_struct.(phoneme_name)));
        data = data(1:amount_of_training_data);

        HMM = initHMM(data, M, Q, initType);
        [HMM, LL] = trainHMM(HMM, data, max_iter);
        folder_name = strcat('./hmms', filesep, 'M', num2str(M), 'Q', num2str(Q),'P', num2str(P * 100), 'D', num2str(D));

        % Create the folder if it doesn't exist already.
        if ~exist(folder_name, 'dir')
            mkdir(folder_name);
        end

        file_path = strcat(folder_name, filesep, phoneme_name);
        save(file_path, 'HMM', '-mat');
    end

    rmpath(genpath(bntPath));
end

