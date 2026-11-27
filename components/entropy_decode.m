function [M, bits_consumed] = entropy_decode(bitstream)
%Decode Exp-Golomb then un-zig-zag
pos = 1;
%first values are matrix size
[rows, pos] = ue_decode(bitstream, pos);
[cols, pos] = ue_decode(bitstream, pos);
zz = zeros(1, rows * cols); idx = 1;
while pos <= length(bitstream)
    [level_code, pos] = ue_decode(bitstream, pos);
    if level_code == 0
        break; %EOB
    end
    [run, pos] = ue_decode(bitstream, pos);
    if mod(level_code, 2) == 1
        val = (level_code + 1) / 2;
    else
        val = -level_code / 2;
    end
    idx = idx + run;
    zz(idx) = val;
    idx = idx + 1;
end
bits_consumed = pos - 1;
M = izigZag(zz, rows, cols);
end

function [x, pos] = ue_decode(bs, pos)
q = 0;
while bs(pos) == '0'
    q = q + 1;
    pos = pos + 1;
end
x = bin2dec(bs(pos : pos + q)) - 1;
pos = pos + q + 1;
end