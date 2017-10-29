% the path where MNIST dataset is located
DATA_DIR = '../../mnist';

addpath('../mnistHelper/');

% load images
X = loadMNISTImages(fullfile(DATA_DIR, 't10k-images-idx3-ubyte'))';
y = loadMNISTLabels(fullfile(DATA_DIR, 't10k-labels-idx1-ubyte'));

% preprocess inputs
X = [ones(size(X, 1), 1), X];   % add bias term

% define sizes
m = size(X, 1);
n = size(X, 2) - 1;
num_classes = size(y, 2);

% PCA
if exist('PCA_SIZE', 'var')
    X = pca(X, PCA_SIZE);
end

% load weights
load('weights.mat');

% start inference
correct_count = 0;
for i = 1:m
    x = X(i, :);
    logits = x * Theta;
    [~, y_pred] = max(logits);
    y_pred = y_pred - 1;
    if y_pred == y(i)
        correct_count = correct_count + 1;
    end
end

acc = correct_count / m;
fprintf('accuracy: %f\n', acc);