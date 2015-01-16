using Color, FixedPointNumbers, Images

@everywhere function slicefill(I, f, roots, colors, maxiter, eps, bounds, steps)
	remin, remax, immin, immax = bounds
	redelta, imdelta = steps

	yrange = I[1]
	xrange = I[2]
	
	slice = (size(yrange,1), size(xrange,1))
	tmp = Array(Vector{Float64}, slice)

	xmin = xrange[1]
	ymin = yrange[1]

	for x=xrange, y=yrange
		tmp[y-ymin+1, x-xmin+1] = f((remin + (x - 1/2)*redelta) + (immin + (y - 1/2)*imdelta)*1im, roots, colors, maxiter, eps)
	end

	return tmp
end

function paranewton(roots, colors, f, maxiter, eps, bounds, nre, nim)
	remin, remax, immin, immax = bounds
	steps = ((remax-remin)/nre, (immax-immin)/nim)

	mat = DArray(I -> slicefill(I, f, roots, colors, maxiter, eps, bounds, steps), (nim, nre))

	return convert(Array, mat)
end

function getimage(matrix)
	rgbmatrix = map(rgb -> RGB{Float64}(rgb[1],rgb[2],rgb[3]), matrix)
	return convert(Image, rgbmatrix)
end

println("Number of available workers: ",length(workers()))