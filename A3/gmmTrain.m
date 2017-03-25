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
    for i=1:3 %length(main_folders)
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
    while i < max_iter && improvement >= epsilon
        
    %   L := ComputeLikelihood (X, theta)
        [L, p_m_given_x] = computeLikelihood(X, theta, M);
        
        disp(L);
        disp(size(p_m_given_x));
    %   theta := UpdateParameters (theta, X, L) ; 
        theta = updateParameters(theta, X, p_m_given_x, M);
        
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
function [L, p_m_given_x] = computeLikelihood(X, theta, M)
    % X: T x D
    
    X_size = size(X);
    T = X_size(1);
    
    % wb
    b = calculate_b_test(X, theta, M); % T x M
    rep_w = repmat(theta.weights, T, 1); % T x M
    %disp(size(rep_w));
    w_b = rep_w .* b; % T x M
    
    % sum(wb)
    sum_w_b = b * theta.weights'; % T x 1
    rep_sum_w_b = repmat(sum_w_b, 1, M); % T x M
    
    % Log Likelihood = sum(log(sum(wb))
    L = sum(log(sum_w_b), 1); % 1 x 1
    
    p_m_given_x = w_b ./ rep_sum_w_b; % T x M
end

function theta = updateParameters(theta, X, p_m_given_x, M)
    % X: T x D
    % p_m_given_x: T x M
    
    X_size = size(X);
    T = X_size(1);
    D = X_size(2);

    % Weights
    sum_p = sum(p_m_given_x, 1); % 1 x M
    theta.weights = sum_p ./ T;
    
    % Means    
    rep_sum_p = repmat(sum_p, D, 1); % D x M
    sum_p_X = X' * p_m_given_x; % D x M
    theta.means = sum_p_X ./ rep_sum_p;
    
    % Variance
    mu_squared = theta.means .* theta.means; % D x M
    
    X_squared = X .* X; % T x D
    sum_p_X_squared = X_squared' * p_m_given_x; % D x M
    
    E_X_squared = sum_p_X_squared ./ rep_sum_p; % D x M
    var = E_X_squared - mu_squared; % D x M
    assert(0 == any(any(var < 0)))

    for m=1:M
        theta.cov(:, :, m) = diag(var(:, m));
    end
end
