include("newton.jl")

include("cubic_poly.jl")

@time matrix = paranewton(roots3,colors3,cubic,20,0.01,(-1.0,1.0,-1.0,1.0),500,500);
@time matrix = paranewton(roots3,colors3,cubic,20,0.01,(-1.0,1.0,-1.0,1.0),500,500);

imwrite(convert(Image,getimage(matrix)), "img_cubic.png")

include("sin.jl")

@time matrix = paranewton(roots_sin,colors_sin,fsin,20,0.01,(-3.0,3.0,-3.0,3.0),500,500);
@time matrix = paranewton(roots_sin,colors_sin,fsin,20,0.01,(-3.0,3.0,-3.0,3.0),500,500);

imwrite(convert(Image,getimage(matrix)), "img_sin.png")