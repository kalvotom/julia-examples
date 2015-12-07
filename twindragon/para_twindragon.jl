# execution: julia -p 4 para_twindragon.jl

using Images

@everywhere include("Twindragon.jl")

@everywhere xmin=-3.
@everywhere xmax=3.
@everywhere ymin=-3.
@everywhere ymax=3.
@everywhere dx=0.01
@everywhere dy=0.01
@everywhere array_length=40
  
@everywhere dimx = floor(Int64, (xmax - xmin) / dx)
@everywhere dimy = floor(Int64, (ymax - ymin) / dy)

image = SharedArray(Float64, dimx, dimy)
  
@everywhere oldset = SimpleSet(array_length)
@everywhere newset = SimpleSet(array_length)

function run!()
  @parallel for jx in 1:dimx
    for jy in 1:dimy
      image[jx, jy] = twindragon([xmin + (jx - 0.5)*dx, ymin + (jy - 0.5)*dy], oldset, newset, ball)
    end
  end

  return image
end


save("twindragon.png", grayim(run!()))
