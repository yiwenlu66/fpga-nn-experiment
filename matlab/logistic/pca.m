function X_pca = pca(X, pca_size)
    m = size(X, 1);
    Sigma = (1/m) * (X' * X);
    [U, ~, ~] = svd(Sigma);
    Ureduce = U(:, 1:pca_size);
    X_pca = X * Ureduce;
end