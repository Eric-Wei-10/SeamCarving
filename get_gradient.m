function energy = get_gradient(im)

    im = rgb2gray(im);
    im = double(im);
    
    [partial_x, partial_y] = gradient(im);
    % energy = abs(partial_x) + abs(partial_y);
    energy = sqrt(partial_x.*partial_x + partial_y.*partial_y);
    
end

