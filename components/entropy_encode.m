function bitstream = entropy_encode(M)
%Zig-zag then Exp-Golomb encoder for any 1xN vector.
Mzz = zigZag(M); [rows, cols] = size(M);
bitstream = blanks((nnz(Mzz)+2)*65+1); %each non-zero number is max 65 bits
pos = 1;
[bitstream, pos] = ue_encode(bitstream, pos, rows);
[bitstream, pos] = ue_encode(bitstream, pos, cols);
run = 0;
for i = 1:length(Mzz)
    if Mzz(i) == 0
        run = run + 1;
    else
        if Mzz(i) > 0
            level_code = 2 * Mzz(i) - 1;
        else
            level_code = -2 * Mzz(i);
        end
        [bitstream, pos] = ue_encode(bitstream, pos, level_code);
        [bitstream, pos] = ue_encode(bitstream, pos, run);
        run = 0;
    end
end
bitstream(pos) = '1';
bitstream = bitstream(1:pos);
end

function [bitstream, pos] = ue_encode(bitstream, pos, x)
q = floor(log2(x + 1));
bitstream(pos : pos +  2*q) = [repmat('0', 1, q), dec2bin(x + 1, q + 1)];
pos = pos + 1 + 2*q;
end