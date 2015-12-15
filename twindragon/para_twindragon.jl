# execution: julia -p 4 para_twindragon.jl

using Images
using PyPlot
using ProgressMeter
using LatexPrint

############
# settings #
############

# number system setting
@everywhere const mat    = Float64[-1 -1 ; 1 -1]  #[-1 -1; 1 -1]
@everywhere const digits = Float64[[0,0] [0,1] [0,-1]]
#magic constants
@everywhere const array_length=500 #yet to be documented
@everywhere const radius = 20. #not used
#bounds
@everywhere const xmin=-3.
@everywhere const xmax=3.
@everywhere const ymin=-3.
@everywhere const ymax=3.
#sampling
@everywhere const dx=0.1
@everywhere const dy=0.1
#picture
const picture_title = "Twindragon"
const picture_dpi = 1000
#file
const filename = "twindragon_para" #warning, files will be overwritten without mercy (or questions)

###################
# end of settings #
###################

@everywhere include("Twindragon.jl")

@everywhere dimx = floor(Int64, (xmax - xmin) / dx)
@everywhere dimy = floor(Int64, (ymax - ymin) / dy)
@everywhere const number_of_digits = size(digits,2)

image = SharedArray(Float64, dimx, dimy)

@everywhere oldset = SimpleSet(array_length)
@everywhere newset = SimpleSet(array_length)


# function run!()
#   @sync @parallel for jx = 1:dimx for jy = 1:dimy
#       @inbounds image[jx, jy] = twindragon([xmin + (jx - 0.5)*dx, ymin + (jy - 0.5)*dy], oldset, newset, ball)
#     end
#   end
#   return image
# end

# println("Starting...")
# tic()
# run!()
# toc()

@everywhere function compute_chunk!(image, jx, jy)
    @inbounds image[jx, jy] = twindragon([xmin + (jx - 0.5)*dx, ymin + (jy - 0.5)*dy], oldset, newset, ball)
end

np = nprocs()  # determine the number of processes available

pm = Progress(dimx*dimy, 1)

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

println("Starting...")
tic()
    @sync begin
        for p=1:np
            if p != myid() || np == 1
                @async begin
                    while true
                        idx = nextidx()
                        if idx[1] > dimx
                            break
                        end
                        #results[idx[0]*dimx+idx[1]] =
                        remotecall_fetch(compute_chunk!, p, image, idx[1], idx[2])
                        next!(pm)
                    end
                end
            end
        end
    end
toc()

save("$(filename).png", grayim(transpose(flipdim(image,2))))
#,cmap="RdGy"

PyPlot.matplotlib[:rc]("text", usetex=true)
PyPlot.matplotlib[:rc]("text.latex",preamble="\\usepackage{amsmath}") #to print matrices in latex
PyPlot.matplotlib[:rcParams]["text.latex.unicode"] = true #probably not needed
set_delims("(", ")") #set array delimiters for latex printing
imshow(transpose(flipdim(image,2)),interpolation="None",extent=[xmin,xmax,ymin,ymax])
title(picture_title)
s = string("M = ",latex_form(mat),",D = \\left \\{ ",latex_form(digits[:,1]))
for d in 2:number_of_digits
    s = string(s,",",latex_form(digits[:,d]))
end
s = string(s," \\right \\} ")
text(xmin,ymin - (ymax-ymin)/10,latexstring(replace(s,"\n","")),fontsize=8)
savefig("$(filename)_pyplot.png",dpi = picture_dpi)