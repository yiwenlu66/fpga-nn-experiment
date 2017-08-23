% the path where MNIST dataset is located
DATA_DIR = '../../mnist';

addpath('../mnistHelper/');

% load images
X = loadMNISTImages(fullfile(DATA_DIR, 'train-images-idx3-ubyte'))';
y = loadMNISTLabels(fullfile(DATA_DIR, 'train-labels-idx1-ubyte'));

% preprocess inputs
X = [ones(size(X, 1), 1), X];   % add bias term
y = full(ind2vec(1 + y')');     % one-hot encoding

% define sizes
m = size(X, 1);
n = size(X, 2) - 1;
num_classes = size(y, 2);

% initialize weights
Theta = rand(n + 1, num_classes) * 1e-8;

% set hyperparameters
lr = 1e-4;
batch_size = 100;      % be sure m is divisible by batch_size
n_iter = 2000;

% start iterations
for i=1:n_iter
    start_idx = mod((i - 1) * batch_size + 1, m);
    range = start_idx:start_idx + batch_size - 1;
    X_batch = X(range, :);
    y_batch = y(range, :);
    [J, grad] = costFunction(X_batch, y_batch, Theta);
    fprintf('iter:%d\tcost:%f\n', i, J);
    Theta = Theta - lr * grad;
end

% save weights
save('weights.mat', 'Theta');