##
## Bifurcations in Logistic Map
##
## Tomáš Kalvoda, 2015
##

using ProgressMeter, Images, Color

lm(x, a) = max(0.0, min(a*x*(1-x), 1.0))
tobin(x, delta, nbins) = max(1, min(convert(Int64, ceil(x/delta)), nbins))

function cmpreq(b1, b2)
    for j = 1:length(b1)
        if (b1[j] == 0 && b2[j] > 0) || (b1[j] > 0 && b2[j] == 0)
            return false
        end
    end
    return true
end

function fillbins(bins, x, delta, steps, a)
    for j = 1:steps
        bins[tobin(x, delta, length(bins))] = 1
        x = lm(x, a)
    end
    return x
end

function accpts(a, nbins, steps)
    delta = 1.0/nbins
    maxrun = 30
    r = 1

    x = 0.5
    acc1 = zeros(Int, nbins)
    acc2 = zeros(Int, nbins)
    x = fillbins(acc1, x, delta, steps, a)
    x = fillbins(acc2, x, delta, steps, a)

    while !(cmpreq(acc1, acc2)) && r <= maxrun
        acc1 = zeros(Int, nbins)
        acc2 = zeros(Int, nbins)
        x = fillbins(acc1, x, delta, steps, a)
        x = fillbins(acc2, x, delta, steps, a)
        r += 1
    end

    return reverse(acc2)
end

function getmat(nbins, steps, asteps)
    a = asteps
    mat = accpts(a, nbins, steps)

    p = Progress(convert(Int64, 4.0/asteps), 1)

    while a < 4.0
        a += asteps
        mat = [mat accpts(a, nbins, steps) ]
        next!(p)
    end
    return mat
end

function getimage(nbins, steps, asteps)
    mat = getmat(nbins, steps, asteps)
    mat = map(rgb -> RGB{Float64}(1-rgb,1-rgb,1-rgb), 1/maximum(mat)*mat)
    imwrite(convert(Image, mat), "out.png")
end
