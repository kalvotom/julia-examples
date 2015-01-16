
@everywhere const roots_sin = Complex64[-2*pi,-pi,0.0,pi,2*pi]
@everywhere const colors_sin = ([1.0,1.0,0.0],[0.0,1.0,1.0],[1.0,0.0,1.0],[0.0,0.0,1.0],[1.0,0.0,0.0])

@everywhere function fsin(z0, roots, colors, maxiter, eps)
	n = 1
	z = z0 - sin(z0)/cos(z0)
	while n <= maxiter
		for j in 1:length(roots)
			if abs2(z - roots[j]) <= eps*eps
				return (1.0 - (n-1)/(maxiter-1))*colors[j]
			end
		end
		z -= sin(z)/cos(z)
		n += 1
	end
	return [0.0,0.0,0.0]
end
