function S = sigmoid(A)
    % compute sigmoid element-wise for a matrix of any shape
    S = 1 ./ (1 + exp(-A));
end