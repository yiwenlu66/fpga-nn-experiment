M_TRAIN = 200;
M_TEST = 100;

% clusters 1, 3 belong to class 1; clusters 2, 4 belong to class 0
MU = [5, 3; 2, 6; -2, 3; 1, -1];
SIGMA = [1, 1, 1, 1];

X_train = zeros(M_TRAIN, 2);
y_train = zeros(M_TRAIN, 1);
X_test = zeros(M_TEST, 2);
y_test = zeros(M_TEST, 1);

for i = 1:M_TRAIN
    cluster = floor(4 * rand) + 1;
    y_train(i) = mod(cluster, 2);
    mu = MU(cluster, :);
    sigma = SIGMA(cluster);
    X_train(i, :) = mu + sqrt(sigma) * randn(1, 2);
end

for i = 1:M_TEST
    cluster = floor(4 * rand) + 1;
    y_test(i) = mod(cluster, 2);
    mu = MU(cluster, :);
    sigma = SIGMA(cluster);
    X_test(i, :) = mu + sqrt(sigma) * randn(1, 2);
end

save('dataset.mat', 'X_train', 'y_train', 'X_test', 'y_test');