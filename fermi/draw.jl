##
## Fermi-Ulam model
##
## Tomáš Kalvoda, FIT CTU, 2015
##
## usage:
## $ julia draw.jl
##

include("fermi.jl")

img = phase_space_image(width=4000, height=10000, tmin=0., tmax=period/2, vmin=.1, vmax=8., deltav=0.005, nmax=50000)
imwrite(colorim(img), "phase_space.png")

img = phase_space_image(width=2000, height=2000, tmin=0., tmax=period/2, vmin=2.8, vmax=3.8, deltav=0.001, nmax=50000)
imwrite(colorim(img), "zoom1.png")

img = phase_space_image(width=2000, height=3000, tmin=0., tmax=period/4, vmin=10.0, vmax=11.0, deltav=0.0005, nmax=50000)
imwrite(colorim(img), "zoom2.png")