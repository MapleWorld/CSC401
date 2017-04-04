%{
Log rule
log(a/b) = log(a) - log(b)
log(ab) = lob(a) + log(b)

b = numerator / denominator
log(b) = log(numerator / denominator)
log(b) = log(numerator) - log(denominator)

numerator = exp(-1/2 sum ((x - mean)^2 / cov))
log(numerator) = -1/2 sum ((x - mean)^2 / cov)

denominator = (2*pi)^(d/2) * (prod cov)^(1/2)
log(denominator) = d/2 * (2 * pi) + (1/2) * (sum log(cov))

%}
function b = calculate_b(X, theta, M)
    % X: T x D

    % T is number of training cases
    T = size(X, 1);
    % D is number of dimensions
    D = size(X, 2);
    
    % First compute log of numerator
    num = zeros(T, M);
    for i=1:D
        % Compute b per dimension
        data_m = X(:,i);
        rep_data_m = repmat(data_m, 1, M);
        
        mu_m = theta.means(i, :); % 
        rep_mu_m = repmat(mu_m, T, 1); % 
        
        cov_m = theta.cov(i, i, :); % 
        rep_cov_m = repmat(cov_m, 1, T, 1); % 
        
        num = num + (rep_data_m - rep_mu_m).^2 ./ squeeze(rep_cov_m);
    end
    
    num = -1/2 * num;

    % Simplifies the covariance matrix
    comp_covs = zeros(D,M);
    for i=1:M
        comp_covs(:, i) = diag(theta.cov(:, :, i));
    end

    % Log of denominator
    den = D/2*log(2*pi) + 1/2*repmat(sum(log(comp_covs), 1), T, 1);

    % Compute log(b)
    log_b = num - den;
    b = exp(log_b); % T x M
end