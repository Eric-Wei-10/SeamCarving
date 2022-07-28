clear all ;

im = imread('./images/messi/messi.jpg') ;
[M, N, chn] = size(im) ;

imshow(im);
p = drawfreehand;

mask = createMask(p);

% 保证不会被删掉太多
new_M = M ; new_N = max(N - length(find(sum(mask))), 5*N/6);
FM = M ; FN = N;

% OM = M ; ON = N ;
N_rem = new_N - (FN - new_N);
 [Y, X] = meshgrid(1:N, 1:M) ;
removed = zeros(M, N);

% 删
while N > new_N || M > new_M
    energy = horizontal_energy(im);
    energy(mask==1) = -1e5;
    
    dp = zeros(M, N);
    dp(1, :) = energy(1, :);
    from = zeros(M, N);
    from(1, :) = 1:N;
    
    for i = 2:M
        for j = 1:N
            tmp = dp(i-1, j);
            from(i, j) = j;
            if j > 1 && dp(i-1, j-1) < tmp
                tmp = dp(i-1, j-1);
                from(i, j) = j-1;
            end
            if j < N && dp(i-1, j+1) < tmp
                tmp = dp(i-1, j+1);
                from(i, j) = j+1;
            end
            dp(i, j) = tmp + energy(i, j);
        end
    end
    
    [~, idx] = min(dp(M, :));
    for i = M:-1:1
        im(i, idx:N-1,:) = im(i, idx+1:N, :);
        mask(i, idx:N-1, :) = mask(i, idx+1:N, :);
        idx = from(i, idx);
    end
    
    im = im(:, 1:N-1, :);
    mask = mask(:, 1:N-1, :);
    N = N-1;
end

imshow(im)
imwrite(uint8(im), './images/messi/tmp_messi.jpg', 'jpg')

O_im = im;
[OM, ON, chn] = size(im);
%恢复原大小
while N > N_rem
    energy = horizontal_energy(im) ;
    dp = zeros(M, N) ;
    from = zeros(M, N) ;
    dp(1, :) = energy(1, :) ;
    from(1, :) = 1:N;
    
    for i = 2:M
        for j = 1:N
            tmp = dp(i-1, j);
            from(i, j) = j;
            if j > 1 && dp(i-1, j-1) < tmp
                tmp = dp(i-1, j-1);
                from(i, j) = j-1;
            end
            if j < N && dp(i-1, j+1) < tmp
                tmp = dp(i-1, j+1);
                from(i, j) = j+1;
            end
            dp(i, j) = tmp + energy(i, j);
        end
    end
    
    [~, idx] = min(dp(M, :)) ;
    for i = M : -1 : 1
        removed(i, Y(i, idx)) = 1 ;
        im(i, idx:N-1, :) = im(i, idx+1:N, :) ;
        Y(i, idx:N-1) = Y(i, idx+1:N) ;
        idx = from(i, idx) ;
    end
    im = im(:, 1:N-1, :) ;
    Y = Y(:, 1:N-1) ;
    N = N-1 ;
    imshow(im);
end

im = double(O_im) ;
new_im = zeros(FM, FN, chn) ;

for i = 1 : OM
    k = 1 ;
    
    for j = 1 : ON
        new_im(i, k, :) = im(i, j, :) ;
        k = k + 1 ;
        if removed(i, j) == 1
            
            if (j > 1) && (j < N)
                new_im(i, k, :) = (im(i, j-1, :) + im(i, j, :) + im(i, j+1, :)) / 3 ;
            else
                new_im(i, k, :) = im(i, j, :) ;
            end
            k = k + 1 ;
        end
    end
end

imshow(uint8(new_im)) ;
imwrite(uint8(new_im), './images/messi/new_messi.jpg', 'jpg')