function hor_E = horizontal_energy(im)
    [M, N, ~] = size(im);
    im = rgb2gray(im);
    im = double(im);

    % horizontal
    hor_E = zeros(M, N);
    hor_m = zeros(M, N);

    L = circshift(im, [0, 1]); % Left
    U = circshift(im, [1, 0]); % Up
    D = circshift(im, [-1, 0]); % Down
    
    % cost
    hor_cL = abs(U - D);
    hor_cU = abs(U - L) + hor_cL;
    hor_cD = abs(D - L) + hor_cL;

    for j = 2: N
        hor_mL = hor_m(:, j - 1);
        hor_mU = circshift(hor_mL, [1, 0]);
        hor_mD = circshift(hor_mL, [-1, 0]);

        mLUD = [hor_mL, hor_mU, hor_mD];
        cLUD = [hor_cL(:, j), hor_cU(:, j), hor_cD(:, j)];
        mLUD = mLUD + cLUD;
        
        [hor_m(:, j), argmins] = min(mLUD, [], 2);
        for i = 1: M
            hor_E(i, j) = cLUD(i, argmins(i));
        end
    end
end