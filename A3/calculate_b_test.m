
function b = calculate_b_test(X, theta, M)
    % X: T x D
    X_size = size(X);
    T = X_size(1);
    D = X_size(2);

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

    % More compact/easy form to use covs in
    comp_covs = zeros(D,M);
    for i=1:M
        comp_covs(:, i) = diag(theta.cov(:, :, i));
    end

    % Log of denominator
    den = D/2*log(2*pi) + 1/2*repmat(sum(log(comp_covs), 1), T, 1);

    % Compute b
    b = num - den;
end