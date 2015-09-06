##
## Particular divergent series with peculiar partial sums behaviour
##
## Tomáš Kalvoda, FIT CTU, 2015
##

using Images, Colors, FixedPointNumbers

# summands
u(n) = n*log(n)*sqrt(2)
z(n) = exp(2im*pi*u(n))

# first maxn partial sums
function partial_sums(maxn)
    out = Array(Complex{Float64}, maxn)
    out[1] = z(1)
    for j = 2:maxn
        out[j] = out[j-1] + z(j)
    end
    return out
end

# draw a point at coordinate p in image
function draw_point(p, image)
    x,y = p
    image[y, x, :] = [0.,0.,0.]
    image[y+1, x, :] = [0.,0.,0.]
    image[y, x+1, :] = [0.,0.,0.]
    image[y-1, x, :] = [0.,0.,0.]
    image[y, x-1, :] = [0.,0.,0.]
end

# draw a line connecting p1 and p2
function draw_line(p1, p2, image)
    x1,y1 = p1; x2,y2 = p2;
    d = convert(Int64, ceil(sqrt((x1-x2)^2 + (y1-y2)^2)))
    for j = 0:d
        x = convert(Int64, floor(x1 + j/d*(x2-x1)))
        y = convert(Int64, floor(y1 + j/d*(y2-y1)))
        draw_point((x,y), image)
    end
end

# create the image
function draw_image(sums, width, height)
    real_parts = real(sums)
    imag_parts = imag(sums)
    remin, remax = (1.05*minimum(real_parts), 1.05*maximum(real_parts))
    immin, immax = (1.05*minimum(imag_parts), 1.05*maximum(imag_parts))
    redelta, imdelta = ((remax - remin) / width, (immax - immin) / height)
    tox(re) = convert(Int64, ceil((re-remin)/redelta))
    toy(im) = convert(Int64, ceil((im-immin)/imdelta))

    img = Array(Float64, (height,width,3))
    fill!(img, 1.0)

    for j in 2:length(sums)
        p1 = (tox(real(sums[j-1])), toy(imag(sums[j-1])))
        p2 = (tox(real(sums[j])), toy(imag(sums[j])))
        draw_line(p1, p2, img)
    end

    return flipud(img)
end

# run the computation
function draw_sums(maxn; width=400, height=400)
    s = partial_sums(maxn)
    h = maximum(abs(s))

    img = draw_image(s, width, height)

    return img
end

