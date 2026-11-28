%Uniform scalar quantizer plus deadzone

%params.qstep = step size, params.rounding = offset
%params.decimate = threshold for almost empty blocks 

%If a block's levels add up (abs value) to the threshold or less,
%the whole block is sent as zeros (skipped if <=0 [to much info to equate to 0]) 
function quantizedLevels = quantize_block(transformCoefficients, params)

% Divide by step size, add rounding offset, round down, restore sign smaller offset=wider dead zone
% Information is purposely lost to reduce file size (cheap trade off)
quantizedLevels = sign(transformCoefficients).*floor(abs(transformCoefficients)/params.qstep + params.rounding);

% Block decimation is used as a block thats almost zero are not worth sending
% For cheaper at roughly the same quality we send it as all zeros

if params.decimate > 0
    blockSize = params.transformBlockSize(1);
    [frameHeight, frameWidth] = size(quantizedLevels);
    numBlockRows = frameHeight/blockSize;
    numBlockCols = frameWidth/blockSize;

% Rearrange the frame so each column holds the levels of one block
% Cut the frame into blocks where rows and columns are each split into two parts 
% (Where we are inside a block and which block we are in)
    blocksGrid = reshape(quantizedLevels, blockSize, numBlockRows, blockSize, numBlockCols);

% Reorder the four numbers so the inside the block term ones come first:
%(row in block, column in block, block row, block column)
    blocksGrid = permute(blocksGrid, [1 3 2 4]);

%Flatten each block into one column
    levelsPerBlock = reshape(blocksGrid, blockSize*blockSize, []);

%Zero every block whose absolute levels add up to the threshold or less
    absLevelSumPerBlock = sum(abs(levelsPerBlock), 1);
    levelsPerBlock(:, absLevelSumPerBlock<= params.decimate) = 0;

%Undo the rearrangement to get the frame back
    blocksGrid = reshape(levelsPerBlock, blockSize, blockSize, numBlockRows, numBlockCols);
    blocksGrid = permute(blocksGrid, [1 3 2 4]);
    quantizedLevels = reshape(blocksGrid, frameHeight, frameWidth);
end
end

% end of quantize_block
