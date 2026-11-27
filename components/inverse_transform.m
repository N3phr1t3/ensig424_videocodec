function inverse_transform(M_coeff, params, outfile)
n = params.transformBlockSize(1);
mData = zeros(size(M_coeff));
for i = 1:n:size(M_coeff, 1)
    for j = 1:n:size(M_coeff, 2)
        mData(i:i+n-1, j:j+n-1) = idct2(M_coeff(i:i+n-1, j:j+n-1));
    end
end
v = mData.';
v = v(:);
fid = fopen(outfile, 'a');
fwrite(fid, v, 'ubit8');
fclose(fid);
end
