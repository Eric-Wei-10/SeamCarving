clear all;

im = imread('./images/messi/messi.jpg');
[M, N, chn] = size(im);
new_im = zeros(N, M, chn);
for d = 1:chn
    new_im(:, :, d) = im(:, :, d)';
end

imshow(uint8(new_im));