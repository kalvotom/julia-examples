include("mandelbrot.jl")

img = draw_image(remin=-2.3, remax=0.8, immin=-1.55, immax=1.55, width=4000, height=4000, maxiter=1000, radius=30.)
imwrite(img, "mandelbrot.png")

img = draw_image(remin=-0.79, remax=-0.73, immin=0.06, immax=0.12, width=2500, height=2500, maxiter=800, radius=20.)
imwrite(img, "mandelbrot_seahorse_valley.png")

img = draw_image(remin=-0.090, remax=-0.088, immin=0.654, immax=0.656, width=2500, height=2500, maxiter=800, radius=20.)
imwrite(img, "mandelbrot_triple_spiral.png")