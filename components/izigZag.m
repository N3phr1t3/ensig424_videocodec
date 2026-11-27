function A = izigZag(Z, M, N)
%Inverse Zig-zag
A = zeros(M, N, 'like', Z);
k = 1;
for s = 0:M+N-2
    row_min = max(1, s-N+2);
    row_max = min(M, s+1);
    if mod(s,2) == 0
        for i = row_max:-1:row_min
            j = s-i+2;
            A(i,j) = Z(k);
            k = k+1;
        end
    else
        for i = row_min:row_max
            j = s-i+2;
            A(i,j) = Z(k);
            k = k+1;
        end
    end
end
end
