function [metrics, perFrame] = measure_quality(original, decoded, firstFrame)
% AI-WRITTEN: measure original-size, 8-bit Y samples without clipping them.
if nargin < 3
    firstFrame = 1;
end
if ~isnumeric(decoded) || ~isreal(decoded) || ~isequal(size(original), size(decoded))
    error('Framework:Decoded', 'Decoder must return numeric Y frames of the original size.');
end
if any(~isfinite(decoded(:))) || any(decoded(:) < 0 | decoded(:) > 255)
    error('Framework:Decoded', 'Decoded samples must be finite and in [0, 255].');
end
n = size(original, 3);
mse = zeros(n, 1);
for k = 1:n
    difference = double(original(:,:,k)) - double(decoded(:,:,k));
    mse(k) = mean(difference(:).^2);
end
psnr = 10 * log10(255^2 ./ mse); % Exact reconstruction gives Inf.
metrics.mse = mean(mse);
metrics.psnr = 10 * log10(255^2 / metrics.mse);
metrics.meanFramePSNR = mean(psnr);
perFrame = table((firstFrame:firstFrame+n-1)', mse, psnr, ...
    'VariableNames', {'SourceFrame','MSE','PSNR_dB'});
end
