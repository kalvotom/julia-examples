# execution: julia -p 4 para_twindragon.jl

using Images

@everywhere include("Twindragon.jl")

@everywhere xmin=-1.7
@everywhere xmax=1.4
@everywhere ymin=-1.3
@everywhere ymax=2.2
@everywhere dx=0.01
@everywhere dy=0.01
@everywhere array_length=40

@everywhere dimx = floor(Int64, (xmax - xmin) / dx)
@everywhere dimy = floor(Int64, (ymax - ymin) / dy)

image = SharedArray(Float64, dimx, dimy)

@everywhere oldset = SimpleSet(array_length)
@everywhere newset = SimpleSet(array_length)


function run!()
  @sync @parallel for jx = 1:dimx for jy = 1:dimy
      @inbounds image[jx, jy] = twindragon([xmin + (jx - 0.5)*dx, ymin + (jy - 0.5)*dy], oldset, newset, ball)
    end
  end
  return image
end


println("Starting...")

tic()
save("twindragon_para.png", grayim(run!()))
toc()