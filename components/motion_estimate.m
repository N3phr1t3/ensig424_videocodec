function [vectors, sideInfo] = motion_estimate(current, reference, params)

% Obtain block size and search range
blky = params.motionBlockSize(1);
blkx = params.motionBlockSize(2);
range = params.searchRange;

current = double(current);
reference = double(reference);

% Extract size of current frame
[height, width] = size(current);

% Determine how many blocks fit in X and Y direction of frame
nBlocksY = height / blky;
nBlocksX = width / blkx;

% Initialize the motion vectors
vectors.mvx = zeros(nBlocksY, nBlocksX);
vectors.mvy = zeros(nBlocksY, nBlocksX);
sideInfo = [];

%% For each block in the current frame
% for each block row
for blockY = 1:nBlocksY
    % get its pixel rows
    rows = (blockY-1)*blky + (1:blky);

    %  for each block column
    for blockX = 1:nBlocksX
        % determine its pixel columns
        cols = (blockX-1)*blkx + (1:blkx);

        % block is the group of pixels to match
        block = current(rows, cols);
        
        % the first candidate will become the best match at the start
        bestSAD = Inf;
        bestDistance = Inf;
    
        % determine the maximum movement in each direction
        % while the search remains within frame
        minY = max(-range, 1 - rows(1));
        maxY = min(range, height - rows(end));
        minX = max(-range, 1 - cols(1));
        maxX = min(range, width - cols(end));
    
        %% For all possible motion vectors
        for dy = minY:maxY
            for dx = minX:maxX
                % read the reference block
                candidate = reference(rows + dy, cols + dx);
                difference = block - candidate;
                % determine sum of absolute pixel differences
                sad = sum(abs(difference(:)));
                distance = dx^2 + dy^2;
                
                % Save the motion vector is the SAD is better
                % if tied, choose based off of smaller distance
                if sad < bestSAD || (sad == bestSAD && distance < bestDistance)
                    bestSAD = sad;
                    bestDistance = distance;
                    vectors.mvx(blockY, blockX) = dx;
                    vectors.mvy(blockY, blockX) = dy;
                end
            end
        end
    end
end
end