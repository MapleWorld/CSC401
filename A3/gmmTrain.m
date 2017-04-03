function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture

    main_folders = dir(dir_train);
    % Length = 3 to skip . and .. directory
    main_folders = main_folders(3:end);
    N = length(main_folders);
    gmms = cell(1, N);
    
    % Stack the lines vectors for every speaker and train every single
    % speaker against all other speakers
    for i=1:length(main_folders)
        sub_folder_path = strcat(dir_train, '/', main_folders(i).name);
        utterances_folder = dir([sub_folder_path, filesep, '*', '.mfcc']);

        % Stack the line vectors for all utterances from ONE speaker
        data = load([sub_folder_path, filesep, utterances_folder(1).name]);
        
        % Load other speaker's data and test against the current speaker
        for j=2:length(utterances_folder)
            file_name = utterances_folder(j).name;
            single_speaker_data = load([sub_folder_path, filesep, file_name]);
            
            % Data contains all mfcc data for all frames of all utterances
            % for one specific speaker
            data = [data; single_speaker_data];
        end
        % Train an m-component GMM per speaker
        theta = train(data, max_iter, epsilon, M);
        
        gmms{i}.name    = main_folders(i).name;
        gmms{i}.weights = theta.weights;
        gmms{i}.means   = theta.means;
        gmms{i}.cov     = theta.cov;
    end
    
end

% Initialize theta
function theta = initalize(data, M)

    %{
        theta.weights   = omega
        theta.means     = mu
        theta.cov       = sigma
    %}
    data_size = size(data);
    row = data_size(1);
    col = data_size(2);
    
    % Init omega with 1 row and 8 column
    % Set value to 1/M for each column
    theta.weights = ones(1,M) * 1 / M;  
    
    % Initialize each mu to a random vector from the data
    % Init a 1-D vector with size = M, where max value <= row
    random_matrix = ceil(rand(1, M) * row);
    
    % Randomly select a matrix of size M x row from the vectors
    % ' inverses the matrix, not sure if inverse is required or not
    % So means is a matrix of size row x M
    theta.means = data(random_matrix, :)';       
    
    % Initialize Sigma_m to a identity matrix
    % repmat repeat copies of the identify matrix
    % 1,1,M specifies how many times it repeats the eye(col) matrix
    % vertically, horizontally, and how many times
    theta.cov = repmat(eye(col),1,1,M);

end

% Input parameter X = data
function theta = train(X, max_iter, epsilon, M)
    % Input: MFCC data - T x D
    theta = initalize(X, M);
    
    % i := 0
    i = 0;
    
    % prev L := -Inf ; improvement = -Inf
    prev_L = -Inf;
    improvement = epsilon;
    
    % while i =< MAX ITER and improvement >= epsilon do
    while i <= max_iter && improvement >= epsilon
        
    %   L := ComputeLikelihood (X, theta)
        [L, prob] = computeLikelihood(X, theta, M);

    %   theta := UpdateParameters (theta, X, L) ; 
        theta = updateParameters(theta, X, prob, M);
        
    %   improvement := L - prev_L
        improvement = L - prev_L;
        
    %   prev L := L
        prev_L = L;
        
    %   i := i + 1 end
        i = i + 1;
    % end
    end
   
    
end

% Input parameter X = data
function [L, prob] = computeLikelihood(X, theta, M)
    % X: T x D
    % T is number of training cases
    T = size(X, 1);
    % wb
    b = calculate_b(X, theta, M); % T x M
    
    % Make T copies of theta.weights vertically
    rep_w = repmat(theta.weights, T, 1); % T x M
    w_b = rep_w .* b; % T x M
    
    % sum(wb)
    sum_w_b = b * theta.weights'; % T x 1
    % Make T copies of sum_w_b horizontally
    rep_sum_w_b = repmat(sum_w_b, 1, M); % T x M
    
    % Log Likelihood = sum(log(sum(w_b))
    L = sum(log(sum_w_b), 1); % 1 x 1
    
    prob = w_b ./ rep_sum_w_b; % T x M
end

function theta = updateParameters(theta, X, prob, M)
    % X     : T x D
    % prob  : T x M
    
    % T is number of training cases
    T = size(X, 1);
    % D is number of dimensions
    D = size(X, 2);

    % Weights
    % Sum of prob / T
    % 1 x M
    theta.weights = sum(prob, 1) ./ T;
    
    % Means    
    % Sum of pro * X / sum of prob
    % Make D copies of sum of prob 
    mean_numerator = X' * prob; % D x M
    mean_denominator = repmat(sum(prob, 1), D, 1); % D x M
    theta.means = mean_numerator ./ mean_denominator;
    
    % Covariance
    X_squared = X.^2; % T x D
    covariance_numerator = X_squared' * prob; % D x M
    covariance_denominator = repmat(sum(prob, 1), D, 1); % D x M
    covariance_fraction = covariance_numerator ./ covariance_denominator; % D x M
    
    % Variance
    means_squared = theta.means.^2; % D x M
    covariance = covariance_fraction - means_squared; % D x M

    for m=1:M
        theta.cov(:, :, m) = diag(covariance(:, m));
    end
end
