##
## Fermi-Ulam model
##
## Tomáš Kalvoda, FIT CTU, 2015
##

##
## Related articles
##
## E. Fermi, On the Origin of the Cosmic Radiation, Phys. Rev. 75 (8), 1949, 1169-1174.
##
## S. Ulam, On the Statistical Properties of Dynamical Systems, Proc. 4th Berkeley Symp. Math. Stat. Probab. 3, 1961, 315-320.
##


using FixedPointNumbers, Colors, Images

using ProgressMeter

# parameters of the model

const period = 1.0
const L = 1.3

wall_prime(t) = 0.2 * ( abs((t % period) - period/2) - period/4 )

# computation of trajectory

function fermi(t, v, n)
    output = Array(Float64, (n,2))
    for j in 1:n
        t = (t + (2*L/v)) % period
        v = abs(-v + 2*wall_prime(t))
        output[j,:] = [t v]
    end
    return output
end

# draw the trajectory

function draw_trajectory(data, image, tox, toy, color)
    height, width = size(image)
    for j in 1:size(data)[1]
        x,y = (tox(data[j,1]), toy(data[j,2]))
        if 1 <= x <= width && 1 <= y <= height
            image[y,x,:] = color
        end
    end
end

# draw the phase space

function phase_space_image(;width=800, height=1600, tmin=0., tmax=period, vmin=1., vmax=100., deltav=1.1, nmax=10000)
    img = Array(Float64, (height,width,3))
    fill!(img, 1.)
    tox(t) = convert(Int64, floor(width*(t-tmin)/(tmax-tmin)))
    toy(v) = convert(Int64, floor(height*(v-vmin)/(vmax-vmin)))
    number_of_trajectories = convert(Int64, ceil((vmax-vmin)/deltav))
    getcolor(j) = convert(RGB, HSV(360.*j/number_of_trajectories, 1, 1))
    v = vmin + deltav
    j = 1

    info("Computing trajectories...")
    p = Progress(number_of_trajectories, 1)

    while v <= vmax
        trajectory = fermi(tmin+rand()*(tmax-tmin), v, nmax)
        if isodd(j)
            clr = getcolor(j)
        else
            clr = getcolor(number_of_trajectories-j)
        end
        draw_trajectory(trajectory, img, tox, toy, [clr.r, clr.g, clr.b])
        v += deltav
        j += 1
        next!(p)
    end

    return flipud(img)
end