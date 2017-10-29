load('dataset.mat');

X = X_train;
y = y_train;

% define sizes
[m, n] = size(X);

% initialize weights
n_hidden = 5;
Theta1 = rand(n_hidden, n + 1) * 1e-8;
Theta2 = rand(1, n_hidden + 1) * 1e-8;

% set hyperparameters
lr = 1;
batch_size = 20;      % be sure m is divisible by batch_size
n_iter = 10000;

% start iterations
for i=1:n_iter
    start_idx = mod((i - 1) * batch_size + 1, m);
    range = start_idx:start_idx + batch_size - 1;
    X_batch = X(range, :);
    y_batch = y(range, :);
    [J, grad1, grad2] = costFunction(X_batch, y_batch, Theta1, Theta2);
    fprintf('iter:%d\tcost:%f\n', i, J);
    Theta1 = Theta1 - lr * grad1;
    Theta2 = Theta2 - lr * grad2;
end

% save weights
save('weights.mat', 'Theta1', 'Theta2');