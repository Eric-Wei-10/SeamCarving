function ver_E = vertical_energy(im)

[M, N, ~] = size(im);
im = rgb2gray(im);
im = double(im);
    
% vertical
ver_E = zeros(M, N);
ver_m = zeros(M, N);

U = circshift(im, [1, 0]); % Up
L = circshift(im, [0, 1]); % Left
R = circshift(im, [0, -1]); % Right
    
% cost
ver_cU = abs(R - L);
ver_cL = abs(U - L) + ver_cU;
ver_cR = abs(U - R) + ver_cU;

for i = 2: M
    ver_mU = ver_m(i - 1, :);
    ver_mL = circshift(ver_mU, [0, 1]);
    ver_mR = circshift(ver_mU, [0, -1]);

    mULR = [ver_mU; ver_mL; ver_mR];
    cULR = [ver_cU(i, :); ver_cL(i, :); ver_cR(i, :)];
    mULR = mULR + cULR;
        
    [ver_m(i, :), argmins] = min(mULR);
    for j = 1: N
        ver_E(i, j) = cULR(argmins(j), j);
    end
end 
