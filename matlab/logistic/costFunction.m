function [J, grad] = costFunction(X, y, Theta)
    % compute cost for logistic regression
    m = size(X, 1);
    h = sigmoid(X * Theta);
    J = (1 / m) * (-y' * log(h) + (1 - y') * log(1 - h));
    J = sum(sum(J));
    grad = (1 / m) * X' * (h - y);
end