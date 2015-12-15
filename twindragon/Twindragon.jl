##
#
# Twindragon fractal
#
# Tomáš Kalvoda
# KAM FIT ČVUT, 2015
#

export draw_twindragon, twindragon

# helper type and functions
type SimpleSet
  container::Array{Float64}
  maxlen::Int64
  length::Int64

  SimpleSet(maxlen) = new(zeros(Float64, 2, maxlen), maxlen, 0)
end

function empty!(set::SimpleSet)
  set.length = 0
end

function append!(set::SimpleSet, x::Vector{Float64})
  set.length += 1
  set.container[:, set.length] = x # @inbounds would be unwise here
end

function initiate!(set::SimpleSet, x::Vector{Float64})
  empty!(set)
  append!(set, x)
end

function multiply!(set::SimpleSet, m::Array{Float64}) #m is expected to by 2x2
  @inbounds @fastmath set.container[:, 1:set.length] = m*set.container[:, 1:set.length]
end

function copy!(source::SimpleSet, target::SimpleSet)
  empty!(target)
  for j in 1:length(source)
    append!(target, source.container[:, j])
  end
end

length(set::SimpleSet) = set.length

ball(z::Vector{Float64}) = z[1]^2 + z[2]^2 < 20

# twindragon iteration
function twindragon(z::Vector{Float64}, oldset::SimpleSet, newset::SimpleSet, in_domain::Function, jmax::Int64=50)
  initiate!(oldset, z)
  empty!(newset)
  y = Float64[0.0, 0.0]
  j = 0

  while j < jmax && length(oldset) > 0
    multiply!(oldset, mat)
    @fastmath @simd for k in 1:length(oldset)
      yy = oldset.container[:, k]

      for d in 1:number_of_digits
        y = yy - digits[:,d]
        if in_domain(y)
          append!(newset, y)
          if length(newset)==newset.maxlen #TO FIX
            return 1.
          end
        end
      end
    end

    # if length(oldset) > 1000
    #   return 1.
    # end

    j += 1
    temp = oldset
    oldset = newset
    newset = temp
    empty!(newset)
  end

  if j < jmax
    return 0.
  else
    return 1.
  end
  # return convert(Float64, j / (jmax - 1.))
end

# outputs a matrix
function draw_twindragon(xmin=-3., xmax=3., ymin=-3., ymax=3., dx=0.001, dy=0.001, array_length=40)
  dimx = floor(Int64, (xmax - xmin) / dx)
  dimy = floor(Int64, (ymax - ymin) / dy)

  image = zeros(Float64, dimx, dimy)
  oldset = SimpleSet(array_length)
  newset = SimpleSet(array_length)

  for jx in 1:dimx
    for jy in 1:dimy
      image[jx, jy] = twindragon([xmin + (jx - 0.5)*dx, ymin + (jy - 0.5)*dy], oldset, newset, ball)
    end
  end

  return image
end
