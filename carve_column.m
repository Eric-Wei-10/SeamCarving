clear all;

im = imread('./images/waterfall/waterfall.png');
[M, N, n] = size(im);

ori_M = M; ori_N = N;
new_M = M; new_N = uint16(3*N/4);

delta = ori_N - new_N;

% 开始carve
H = zeros(M, N);

for k = 1:delta
    energy = vertical_energy(im);

    dp = zeros(M, N);
    dp(1, :) = energy(1, :);
    from = zeros(M, N);
    from(1, :) = 1:N;

    for i = 2:M
        for j = 1:N
%             dp(i, j) = dp(i-1, j) + energy(i, j);
%             if j > 1 && dp(i-1, j-1) + energy(i, j) < dp(i, j)
%                 dp(i, j) = dp(i-1, j-1) + energy(i, j);
%             end
%             if j < N && dp(i-1, j+1) + energy(i, j) < dp(i, j)
%                 dp(i, j) = dp(i-1, j+1) + energy(i, j);
%             end
            p1 = j;
            while (p1 >= 1) && (H(i-1, p1) > 0)
                    p1 = p1 - 1;
            end
            % 找到一个p1
            if p1 > 0
                dp(i, j) = dp(i-1, p1) + energy(i, j);
                from(i, j) = p1;
            else
                p1 = j;
                while(p1 <= N) && (H(i-1, p1) > 0)
                    p1 = p1 + 1;
                end
                dp(i, j) = dp(i-1, p1) + energy(i, j);
                from(i, j) = p1;
            end
            % 找p1的左邻居p2
            p2 = p1 - 1;
            while (p2 >= 1) && (H(i-1, p2) > 0)
                p2 = p2 - 1;
            end
            if p2 >= 1
                if dp(i-1, p2) + energy(i, j) < dp(i, j)
                    dp(i, j) = dp(i-1, p2) + energy(i, j);
                    from(i, j) = p2;
                end
            end
            % 找p1的右邻居p3
            p3 = p1 + 1;
            while (p3 <= N) && (H(i-1, p3) > 0)
                p3 = p3 + 1;
            end
            if p3 <= N
                if dp(i-1, p3) + energy(i, j) < dp(i, j)
                    dp(i, j) = dp(i-1, p3) + energy(i, j);
                    from(i, j) = p3;
                end
            end
        end
    end
    
    %找到seam的尾
    min_energy = 1e12;
    index = 1;
    for j = 1:N
        if (dp(M, j) < min_energy) && (H(M, j) == 0)
            min_energy = dp(M, j);
            index = j;
        end
    end
    
    for i = M:-1:1
        H(i, index) = k;
        index = from(i, index);
    end
end

mask = zeros(M, N);
mask(H == 0) = 255;
figure; imshow(mask);
imwrite(mask, './images/waterfall/waterfall_mask.jpg', 'jpg')

new_im = zeros(M, new_N, n);

for i = 1:M
    l = 1;
    for j = 1:new_N
        while H(i, l) > 0
            l = l + 1;
        end
        new_im(i, j, :) = im(i, l, :);
        l = l + 1;
    end
end

figure; imshow(uint8(new_im));
imwrite(uint8(new_im), './images/waterfall/waterfall_result.jpg', 'jpg')