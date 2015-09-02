##
## Visualization of the Mandelbrot set in Julia
##
## Tomáš Kalvoda, FIT CTU, 2015
##

using Images, Colors, FixedPointNumbers
using ProgressMeter

function iter_to_color(i, maxiter)
    clr = convert(RGB, HSV(360.*i/maxiter,1,1))
    return [clr.r, clr.g, clr.b]
end

function getcolor(z::Complex{Float64}, maxiter, radius)
    i = 1; u = 0 + 0im;
    while i <= maxiter
        u = u^2 + z
        if abs(u) > radius
            return iter_to_color(i,maxiter)
        end
        i += 1
    end
    return [1., 1., 1.]
end

function draw_image(;remin=-3.0, remax=3.0, immin=-3.0, immax=3.0, width=400, height=400, maxiter=30, radius=20.)
    redelta = (remax-remin)/(width-1)
    imdelta = (immax-immin)/(height-1)

    img = colorim(Array(Float64, (width,height,3)))
    img["spatialorder"] = ["x", "y"]

    p = Progress(width, 1)

    for j = 0:width-1
        for k = 0:height-1
            img[j+1, k+1, :] = getcolor(remin + j*redelta + 1im*(immin + k*imdelta), maxiter, radius)
        end
        next!(p)
    end

    return fliplr(img)
end
