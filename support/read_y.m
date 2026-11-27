function frames = read_y(input)
% AI-WRITTEN: read headerless 8-bit, row-major luminance frames.
validateattributes(input.width, {'numeric'}, {'scalar','integer','positive'});
validateattributes(input.height, {'numeric'}, {'scalar','integer','positive'});
validateattributes(input.startFrame, {'numeric'}, {'scalar','integer','positive'});
validateattributes(input.numFrames, {'numeric'}, {'scalar','integer','positive'});
fid = fopen(input.file, 'rb');
if fid < 0
    error('Framework:Input', 'Cannot open Y file: %s', input.file);
end
cleanup = onCleanup(@() fclose(fid));
pixels = double(input.width) * double(input.height);
fseek(fid, 0, 'eof');
fileBytes = ftell(fid);
if mod(fileBytes, pixels) ~= 0
    error('Framework:Input', 'File size does not match complete Y frames. Check resolution.');
end
lastFrame = input.startFrame + input.numFrames - 1;
if lastFrame > fileBytes / pixels
    error('Framework:Input', 'Requested through frame %d; file contains %d frames.', ...
        lastFrame, fileBytes / pixels);
end
status = fseek(fid, (input.startFrame - 1) * pixels, 'bof');
if status ~= 0
    error('Framework:Input', 'Could not seek to the requested first frame.');
end
[raw, count] = fread(fid, pixels * input.numFrames, '*uint8');
if count ~= pixels * input.numFrames
    error('Framework:Input', 'Input read was incomplete.');
end
frames = permute(reshape(raw, input.width, input.height, input.numFrames), [2 1 3]);
end
