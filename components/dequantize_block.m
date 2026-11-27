function coefficients = dequantize_block(levels, params)

% Get the step sizes and the zigzag map
[qt, zag] = init_jpeg(params.quality);

% Multiply each level by its step size
values = levels .* qt;

% Put the coefficients back into an 8x8 block for the inverse DCT
coefficients = values(zag);

end