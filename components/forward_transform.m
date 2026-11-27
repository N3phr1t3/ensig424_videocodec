function coefficients = forward_transform(block, params)
n = params.transformBlockSize(1);
[H0, W0] = size(block); 
H = 8 * ceil(H0 / 8);
W = 8 * ceil(W0 / 8);
block = block(min(1:H, H0), min(1:W, W0));
coefficients = zeros(H, W);
[H0, W0] = size(block); 
H = n * ceil(H0 / n);
W = n * ceil(W0 / n);
block = block(min(1:H, H0), min(1:W, W0)); 
coefficients = zeros(H, W);
for i = 1:n:H
    for j = 1:n:W
        coefficients(i:i+n-1, j:j+n-1) = dct2(block(i:i+n-1, j:j+n-1));
    end
end
end
