load('dataset.mat');
load('weights.mat');

X = X_test;
y = y_test;

[m, n] = size(X);

batch_size = 100;      % be sure m is divisible by batch_size
n_batches = m / batch_size;

correct_count = 0;

for i=1:n_batches
    start_idx = (i - 1) * batch_size + 1;
    range = start_idx:start_idx + batch_size - 1;
    X_batch = X(range, :);
    y_batch = y(range, :);
    
    m_batch = size(X_batch, 1);
    
    a1 = [ones(m_batch, 1), X_batch];
    z2 = a1 * Theta1';
    a2 = [ones(m_batch, 1), sigmoid(z2)];
    z3 = a2 * Theta2';
    a3 = sigmoid(z3);
    correct_count = correct_count + sum(y_batch == round(a3));
end

disp(correct_count);