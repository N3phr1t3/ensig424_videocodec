% Dequantize block 
% reconstruction level = quantizedlevel * stepsize

function reconstructedCoefficients = dequantize_block(quantizedLevels, params)
reconstructedCoefficients = quantizedLevels * params.qstep;
end
