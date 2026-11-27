function levels = quantize_block(coefficients, params)

% Get the step sizes in zigzag order
[qt, ~] = init_jpeg(params.quality);

% Divide each coefficient by its step size and round
levels = round(coefficients ./ qt);
end