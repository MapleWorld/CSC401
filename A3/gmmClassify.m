%dir_test     = '/u/cs401/speechdata/Testing';
%dir_train    = '/u/cs401/speechdata/Training';

dir_test    = './Testing';
dir_train   = './Training';
dir_lik     = './lik';
max_iter       = 5;
epsilon        = 0.5;
M              = 8; % By default

gmms = gmmTrain(dir_train, max_iter, epsilon, M);
num_speakers = length(gmms);
num_utterances = 30;

% Keep track of accuracy
num_correct = 0;

test_ids = textread([dir_test, filesep, 'TestingIDs1-15.txt'], '%s', 'delimiter', '\n');
% Skip the first line
test_ids = test_ids(2:end);
% Reformat test_ids into list of id name only instead of the entire line
for i=1:size(test_ids, 1)
    split = strsplit(test_ids{i}, ':');
    test_ids(i) = strtrim(split(2));
end

for i=1:num_speakers

    % Load the unkn_*.mfcc files in the Testing folder
    mfcc_name = ['unkn_', int2str(i), '.mfcc'];
    mfcc_data = load([dir_test, filesep, mfcc_name]);
    
    % Initialize the variables to store likelihoods and names
    candidate_names = cell(1, 5);
    candidate_likelihood = zeros(1, 5) - Inf;
    
    for j=1:num_utterances
        theta_j = gmms{j};

        % Compute log likelihood with data and theta
        b = calculate_b(mfcc_data, theta_j, M);     % T x M
        sum_w_b = b * theta_j.weights';             % T x 1
        % Returns the sum horizontally
        Likelihood = sum(log(sum_w_b), 1);          % 1 x 1

        % Take the worst score in our top 5, and if the current is better
        % than the worst score, then replace it with the current.
        [min_val, min_index] = min(candidate_likelihood, [], 2);
        if Likelihood > min_val
            candidate_likelihood(min_index) = Likelihood;
            candidate_names{min_index} = theta_j.name;
        end
        
    end

    % Sort the likelihood 
    [sorted_likelihoods, sorted_indices] = sort(candidate_likelihood, 'descend');
    
    % Increment the correct counter
    % There are only 15 test ids available in the TestingIDs1-15.txt
    if i <= 15
        num_correct = num_correct + strcmp(test_ids{i}, candidate_names{sorted_indices(1)});
    end
    
    % Create the file name
    file_name = [dir_lik, filesep, 'unkn', int2str(i), '.lik'];
    
    % Open file
    file_output = fopen(file_name, 'w');

    % Write to file 
    fprintf(file_output, 'File Name: %s \n', mfcc_name);
    fprintf(file_output, 'Name     Likelihood \n');
    for k=1:5
        fprintf(file_output, '%s    %f\n', candidate_names{sorted_indices(k)}, sorted_likelihoods(k));
    end
    fclose(file_output);
end

accuracy = 100 * num_correct / 15;
fprintf('Accuracy: %f\n', accuracy);
