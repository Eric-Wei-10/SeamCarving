function E = get_entropy(im)
    
    im = rgb2gray(im);
    
    E =  entropyfilt(im) ;

end
