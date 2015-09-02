include("mandelbrot.jl")

img = draw_image(remin=-2.5, remax=1.0, immin=-1.75, immax=1.75, width=4000, height=4000, maxiter=100, radius=10.)
imwrite(img, "mandelbrot.png")

img = draw_image(remin=-0.79, remax=-0.73, immin=0.02, immax=0.12, width=2000, height=2000, maxiter=150, radius=10.)
imwrite(img, "mandelbrot_seahorse_valley.png")

img = draw_image(remin=-0.090, remax=-0.088, immin=0.654, immax=0.656, width=2500, height=2500, maxiter=800, radius=20.)
imwrite(img, "mandelbrot_triple_spiral.png")