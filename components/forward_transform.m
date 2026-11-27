function M_coeff = forward_transform(inframe, params, frameIdx)
%Extract frame data from .y file
H0 = params.height; W0 = params.width;
frame_size = H0 * W0;
frame = fopen(inframe, 'rb');
fseek(frame, frame_size * (frameIdx - 1), 'bof');
data = fread(frame, frame_size, 'uint8');
fclose(frame);
blockData = double(reshape(data, W0, H0).');
%Generate DCT matrix
n = params.transformBlockSize(1);
H = n * ceil(H0 / n);
W = n * ceil(W0 / n);
block = blockData(min(1:H, H0), min(1:W, W0)); 
M_coeff = zeros(H, W);
for i = 1:n:H
    for j = 1:n:W
        M_coeff(i:i+n-1, j:j+n-1) = dct2(block(i:i+n-1, j:j+n-1));
    end
end
