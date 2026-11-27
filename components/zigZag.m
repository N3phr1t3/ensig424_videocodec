function Z = zigZag(A)
%Zig-zag Matrix to order coeffcients descendantly
[M, N] = size(A);
Z = zeros(1, M*N);
k = 1;
for s = 0:M+N-2
    row_min = max(1, s-N+2);
    row_max = min(M, s+1);
    if mod(s,2) == 0
        for i = row_max:-1:row_min
            j = s-i+2;
            Z(k) = A(i,j);
            k = k+1;
        end
    else
        for i = row_min:row_max
            j = s-i+2;
            Z(k) = A(i,j);
            k = k+1;
        end
    end
end
end