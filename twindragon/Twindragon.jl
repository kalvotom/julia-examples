##
#
# Twindragon fractal
#
# Tomáš Kalvoda
# KAM FIT ČVUT, 2015
#

# helper type and functions
type SimpleSet
  container::Array{Float64}
  maxlen::Int64
  length::Int64

  SimpleSet(maxlen) = new(zeros(Float64, 2, maxlen), maxlen, 0)
end

@inline function empty!(set::SimpleSet)
  set.length = 0
end

@inline function append!(set::SimpleSet, x::Vector{Float64})
  set.length += 1
  @inbounds set.container[1, set.length] = x[1] # devectorization
  @inbounds set.container[2, set.length] = x[2]
end

@inline function initiate!(set::SimpleSet, x::Vector{Float64})
  empty!(set)
  append!(set, x)
end

@inline function multiply!(set::SimpleSet, m::Array{Float64}) #m is expected to by 2x2
  @fastmath @inbounds @simd for j in 1:length(set)
    a = set.container[1, j]; b = set.container[2, j];
    set.container[1, j] = m[1,1] * a + m[1,2] * b
    set.container[2, j] = m[2,1] * a + m[2,2] * b
  end
end

@inline length(set::SimpleSet) = set.length

@inline ball(z::Vector{Float64}) = z[1]^2 + z[2]^2 < 20

# twindragon iteration
function twindragon(z::Vector{Float64}, oldset::SimpleSet, newset::SimpleSet, in_domain::Function, jmax::Int64=50)
  initiate!(oldset, z)
  empty!(newset)
  y = Float64[0.0, 0.0]
  j = 0

  while j < jmax && length(oldset) > 0
    multiply!(oldset, mat)
    @fastmath @inbounds for d in 1:number_of_digits
      @simd for k in 1:length(oldset)
        y[1] = mdigits[1, d] + oldset.container[1, k]
        y[2] = mdigits[2, d] + oldset.container[2, k]

        if in_domain(y)
          append!(newset, y)
          
          if length(newset) == newset.maxlen #TO FIX
            return 1.
          end
        end
      end
    end

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
end
