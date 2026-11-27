function check_support()
% AI-WRITTEN: small support checks; no codec algorithms or fake results.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'support'), fullfile(root, 'components'));
folder = tempname;
mkdir(folder);
cleanup = onCleanup(@() rmdir(folder, 's'));

% A nonsquare, non-block-aligned sequence catches transposition mistakes.
original = reshape(uint8(1:105), 5, 7, 3);
input.file = fullfile(folder, 'test.y');
input.width = 7;
input.height = 5;
input.startFrame = 1;
input.numFrames = 3;
fid = fopen(input.file, 'wb');
fwrite(fid, permute(original, [2 1 3]), 'uint8');
fclose(fid);
assert(isequal(read_y(input), original));
input.startFrame = 2;
input.numFrames = 1;
assert(isequal(read_y(input), original(:,:,2)));
input.numFrames = 3;
expect_error(@() read_y(input), 'Framework:Input');

% Count nested metadata and every extension, not just the main stream.
encoded = fullfile(folder, 'encoded');
mkdir(fullfile(encoded, 'side'));
fid = fopen(fullfile(encoded, 'stream.bin'), 'wb');
fwrite(fid, zeros(13, 1), 'uint8');
fclose(fid);
fid = fopen(fullfile(encoded, 'side', 'vectors.mat'), 'wb');
fwrite(fid, zeros(7, 1), 'uint8');
fclose(fid);
[bytes, list] = count_bytes(encoded);
assert(bytes == 20 && height(list) == 2);
assert(abs(8 * bytes / numel(original) - 160/105) < 1e-12);

[m, perFrame] = measure_quality(original, double(original) + 2, 4);
assert(m.mse == 4 && abs(m.psnr - 10*log10(255^2/4)) < 1e-12);
assert(isequal(perFrame.SourceFrame, [4;5;6]));
exact = measure_quality(original, original);
assert(isinf(exact.psnr));
expect_error(@() measure_quality(original, nan(size(original))), 'Framework:Decoded');
expect_error(@() measure_quality(original, 256*ones(size(original))), 'Framework:Decoded');
expect_error(@() measure_quality(original, original(:,:,1)), 'Framework:Decoded');
expect_error(@() encode_video(original, encoded, struct()), 'Codec:NotImplemented');
expect_error(@() decode_video(encoded), 'Codec:NotImplemented');
fprintf('Support checks passed. The codec is still unimplemented.\n');
end

function expect_error(action, identifier)
try
    action();
catch problem
    assert(strcmp(problem.identifier, identifier), 'Unexpected error: %s', problem.message);
    return;
end
error('Framework:Test', 'Expected error was not raised: %s', identifier);
end
