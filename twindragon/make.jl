using Images

include("twindragon.jl")

image = plot_twindragon()

save("twindragon.png", grayim(image))
