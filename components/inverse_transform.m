function block = inverse_transform() % Inputs: coefficients, params
n = params.transformBlockSize(1);
block = zeros(size(coefficients));
for i = 1:n:size(coefficients, 1)
    for j = 1:n:size(coefficients, 2)
        block(i:i+n-1, j:j+n-1) = idct2(coefficients(i:i+n-1, j:j+n-1));
    end
end
end
