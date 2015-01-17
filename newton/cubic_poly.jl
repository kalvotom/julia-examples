
@everywhere const roots3 = Complex64[1.0, exp(2im*pi/3), exp(4im*pi/3)]
@everywhere const colors3 = ([1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0])

@everywhere function cubic(z0, roots, colors, maxiter, eps)
	n = 1
	z = z0 - (z0*z0*z0 - 1)/(3.0*z0*z0)
	while n <= maxiter
		for j in 1:length(roots)
			if abs2(z - roots[j]) <= eps*eps
				return (1.0 - (n-1)/(maxiter-1))*colors[j]
			end
		end
		z -= (z*z*z - 1)/(3.0*z*z)
		n += 1
	end
	return [0.0,0.0,0.0]
end
