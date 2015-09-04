include("partial_sum.jl")

img = draw_sums(50000, width=1800, height=1800)
imwrite(colorim(img), "partial_sums.png")