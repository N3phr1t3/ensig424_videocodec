% Takes in the reference frame, the motion vectors, frame size, and block
% size then returns the predicted frame
function prediction = motion_compensate(reference, vectors, outputSize, params)

% Obtain block size and motion vectors
blky = params.motionBlockSize(1);
blkx = params.motionBlockSize(2);

mvx = double(vectors.mvx);
mvy = double(vectors.mvy);

% Initialize blank frame
prediction = zeros(outputSize);

% Determine how many blocks fit in X and Y direction of frame
nBlocksX = outputSize(2) / blkx;
nBlocksY = outputSize(1) / blky;

%% for each block of the prediction frame
% for each block row
for blockY = 1:nBlocksY
    % get its pixel rows
    rows = (blockY-1)*blky + (1:blky);
    
    %  for each block column
    for blockX = 1:nBlocksX
        % determine its pixel columns
        cols = (blockX-1)*blkx + (1:blkx);
        
        % determine the reference pixel block from motion vectors
        refRows = rows + mvy(blockY, blockX);
        refCols = cols + mvx(blockY, blockX);
    
        % copy the selected reference frame block to the predicted frame
        prediction(rows, cols) = reference(refRows, refCols);
    end
end
end