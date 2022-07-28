% 试试poisson image editing优化一下边缘
clear all;

im = imread('./images/lady/lady.png');
[M, N, n] = size(im);

ori_M = M; ori_N = N;
new_M = 4*M/5; new_N = N;

while N > new_N || M > new_M
    energy = horizontal_energy(im);
    % carve a column
    dp_column = zeros(M, N);
    dp_column(1, :) = energy(1, :);
    from_column = zeros(M, N);
    from_column(1, :) = 1:N;
    
    for i = 2:M
        for j = 1:N
            tmp_column = dp_column(i-1, j);
            from_column(i, j) = j;
            if j > 1 && dp_column(i-1, j-1) < tmp_column
                tmp_column = dp_column(i-1, j-1);
                from_column(i, j) = j-1;
            end
            if j < N && dp_column(i-1, j+1) < tmp_column
                tmp_column = dp_column(i-1, j+1);
                from_column(i, j) = j+1;
            end
            dp_column(i, j) = tmp_column + energy(i, j);
        end
    end
    
    % carve a row
    dp_row = zeros(M, N);
    dp_row(:, 1) = energy(:, 1);
    from_row = zeros(M, N);
    from_row(:, 1) = 1:M;
    
    for j = 2:N
        for i = 1:M
            tmp_row = dp_row(i, j-1);
            from_row(i, j) = i;
            if i > 1 && dp_row(i-1, j-1) < tmp_row
                tmp_row = dp_row(i-1, j-1);
                from_row(i, j) = i-1;
            end
            if i < M && dp_row(i+1, j-1) < tmp_row
                tmp_row = dp_row(i+1, j-1);
                from_row(i, j) = i+1;
            end
            dp_row(i, j) = tmp_row + energy(i, j);
        end
    end
    
    [~, idx_column] = min(dp_column(M, :));
    [~, idx_row] = min(dp_row(:, N));
    energy_per_cell_column = dp_column(M, idx_column) / M;
    energy_per_cell_row = dp_row(idx_row, N) / N;
    if energy_per_cell_column < energy_per_cell_row
        if N > new_N
            for i = M:-1:1
                im(i, idx_column:N-1,:) = im(i, idx_column+1:N, :);
                idx_column = from_column(i, idx_column);
            end
            im = im(:, 1:N-1, :);
            N = N-1;
            imshow(im);
        else
            for j = N:-1:1
                im(idx_row:M-1, j, :) = im(idx_row+1:M, j, :);
                idx_row = from_row(idx_row, j);
            end
            im = im(1:M-1, :, :);
            M = M-1;
            imshow(im);
        end
        
    else
        if M > new_M
            for j = N:-1:1
                im(idx_row:M-1, j, :) = im(idx_row+1:M, j, :);
                idx_row = from_row(idx_row, j);
            end
            im = im(1:M-1, :, :);
            M = M-1;
            imshow(im);
        else
            for i = M:-1:1
                im(i, idx_column:N-1,:) = im(i, idx_column+1:N, :);
                idx_column = from_column(i, idx_column);
            end
            im = im(:, 1:N-1, :);
            N = N-1;
            imshow(im);
        end
    end
end
imshow(im)
imwrite(uint8(im), './images/lady/lady_edit.png', 'png')
