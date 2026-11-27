%gemini-made entropy enc/dec test
M_test = [14, -2,  0,  0;
           1,  0,  0,  0;
           0,  0, -1,  0;
           0,  0,  0,  0];

bs = entropy_encode(M_test);
[M_rec, bits_used] = entropy_decode(bs);

assert(isequal(M_test, M_rec) && bits_used == length(bs));
fprintf('Success! Compressed %d elements into %d bits.\n', numel(M_test), bits_used);