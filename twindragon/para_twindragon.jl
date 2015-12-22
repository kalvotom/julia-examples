# execution: julia -p 4 para_twindragon.jl

using Images
using PyPlot
using ProgressMeter
using LatexPrint

############
# settings #
############

# type
@everywhere const T = Float64

# number system setting
@everywhere const mat  = T[-1 -1 ; 1 -1]  #[-1 -1; 1 -1]
@everywhere const digs = T[[-1,-1] [1,-1]]

#magic constants
@everywhere const array_length = 500 #yet to be documented
@everywhere const radius = T(20)

#bounds
@everywhere const xmin= T(-1.7)
const xmax = T(1.4)

@everywhere const ymin= T(-1.3)
const ymax = T(2.2)

#sampling
@everywhere const dx = T(0.01)
@everywhere const dy = T(0.01)

#picture
const picture_title = "Twindragon"
const picture_dpi = 1000

#file
const filename = "twindragon_para" #warning, files will be overwritten without mercy (or questions)

###################
# end of settings #
###################

@everywhere include("Twindragon.jl")

const dimx = floor(Int, (xmax - xmin) / dx)
const dimy = floor(Int, (ymax - ymin) / dy)

image = SharedArray(T, dimx, dimy)

@everywhere oldset = SimpleSet()
@everywhere newset = SimpleSet()

@everywhere const mdigits = -1 * digs
@everywhere const number_of_digits = size(digs, 2)

@everywhere function compute_chunk!(image, jx, jy)
    @inbounds image[jx, jy] = twindragon([xmin + (jx - T(0.5))*dx, ymin + (jy - T(0.5))*dy], oldset, newset, ball)
end

jx = 1
jy = 1

# function to produce the next work item from the queue
function nextidx()
  global jx; global jy; global dimy; idx=(jx, jy); jy+=1;
  if jy > dimy
    jy = 1; jx+=1;
  end
  return idx
end

function run!(img)
  np = nprocs()  # determine the number of processes available
  progress_meter = Progress(dimx * dimy, 1)

  @sync begin
    for p in 1:np
      if p != myid() || np == 1
        @async begin
          while true
            idx = nextidx()
            if idx[1] > dimx
              break
            end
            remotecall_fetch(compute_chunk!, p, image, idx[1], idx[2])
            next!(progress_meter)
          end
        end
      end
    end
  end
end

println("Starting...")
tic()
run!(image)
toc()

# raw image
save("$(filename).png", grayim(transpose(flipdim(image,2))))

# pyplot insanity
PyPlot.matplotlib[:rc]("text", usetex=true)
PyPlot.matplotlib[:rc]("text.latex",preamble="\\usepackage{amsmath}") #to print matrices in latex
PyPlot.matplotlib[:rcParams]["text.latex.unicode"] = true #probably not needed
set_delims("(", ")") #set array delimiters for latex printing

imshow(transpose(flipdim(image,2)), cmap="Reds", interpolation="lanczos", extent=[xmin,xmax,ymin,ymax])

title(picture_title)

s = string("M = ",latex_form(mat),",D = \\left \\{ ",latex_form(digs[:,1]))
for d in 2:number_of_digits
    s = string(s,",",latex_form(digs[:,d]))
end
s = string(s," \\right \\} ")
text(xmin,ymin - (ymax-ymin)/10,latexstring(replace(s,"\n","")),fontsize=8)

savefig("$(filename)_pyplot.png", dpi = picture_dpi)
