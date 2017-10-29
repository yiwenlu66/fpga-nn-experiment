function [J, grad1, grad2] = costFunction(X, y, Theta1, Theta2)
    m = size(X, 1);
    n = size(X, 2);
    
    a1 = [ones(m, 1), X];
    z2 = a1 * Theta1';
    a2 = [ones(m, 1), sigmoid(z2)];
    z3 = a2 * Theta2';
    a3 = sigmoid(z3);
    J = (1 / m) * (-y' * log(a3) - (1 - y') * log(1 - a3));
    
    delta3 = a3 - y;
    delta2 = delta3 * Theta2 .* (a2 .* (1 - a2));
    
    Delta1 = delta2(:, 2:end)' * a1;
    Delta2 = delta3' * a2;
    
    grad1 = Delta1 / m;
    grad2 = Delta2 / m;
end