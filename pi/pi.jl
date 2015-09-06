##
## Fun with pi!
##
## Tomáš Kalvoda, KAM FIT ČVUT, 2015
##

##
## References: J. Gibbons, Unbounded Spigot Algorithms for the Digits of pi 
##
## http://www.cs.ox.ac.uk/people/jeremy.gibbons/publications/spigot.pdf
##

function nextdigit(state)
    q,r,t,i = state
    u, y = (3*(3*i+1)*(3*i+2), div(q*(27*i-12)+5*r, 5*t))
    return (y, [10*q*i*(2*i-1), 10*u*(q*(5*i-2)+r-y*t), t*u, i+1])
end

function pidigits(n)
    dig = Int[]
    d, state = nextdigit(BigInt[1, 180, 60, 2])
    for j in 1:n
        push!(dig,d)
        d, state = nextdigit(state)
    end
    return dig
end

##
## Progression
##

const ndigits = 2000

info("Computing first $(ndigits) digits of pi...")
mypi = pidigits(ndigits)

info("Counting number occurances of each digit...")
dcount = Dict{Int64,Int64}({i => 0 for i in 0:9})
ddrawn = Dict{Int64,Int64}({i => 0 for i in 0:9})

for d in mypi
    dcount[d] += 1
end

digit_angle = 0.85 * (360. / 10.)
space_angle = 0.15 * (360. / 10.)
delta_angle = Dict{Int64,Float64}({d => digit_angle / (dcount[d] - 1) for d in 0:9})

radius  = 4
opacity = 0.7

# tex head

texout = "\\documentclass{standalone}
\\usepackage[T1]{fontenc}
\\usepackage{tikz}

\\definecolor{d0}{RGB}{253,253,150}
\\definecolor{d1}{RGB}{174,198,207}
\\definecolor{d2}{RGB}{244,154,194}
\\definecolor{d3}{RGB}{255,105,97}
\\definecolor{d4}{RGB}{130,105,83}
\\definecolor{d5}{RGB}{255,179,71}
\\definecolor{d6}{RGB}{3,192,60}
\\definecolor{d7}{RGB}{207,207,196}
\\definecolor{d8}{RGB}{119,158,203}
\\definecolor{d9}{RGB}{203,153,201}

\\begin{document}
\\begin{tikzpicture}\n"

# connections

for i in 1:(length(mypi)-1)
    d1 = mypi[i]
    d2 = mypi[i+1]
    angled1 = d1*(36.) + ddrawn[d1] * delta_angle[d1]
    outd1 = angled1 + 180.
    angled2 = d2*(36.) + ddrawn[d2] * delta_angle[d2]
    outd2 = angled2 + 180.
    texout = string(texout, "\\draw[thin, opacity=$(opacity), d$(d1)] ($(angled1):$(radius)) to[out=$(outd1),in=$(outd2)] ($(angled2):$(radius));\n")
    ddrawn[d1] += 1
end

# legend

for d in 0:9
    angle1 = d*36
    angle2 = (d+1)*36 - space_angle
    texout = string(texout, "\\draw[very thick, d$(d)] ($(angle1):$(radius)) arc ($(angle1):$(angle2):$(radius));\n")
    texout = string(texout, "\\node at ($(angle1 + 18):{1.1*$(radius)}) {$(d)};\n")
end

# tail

texout = string(texout,"\\end{tikzpicture}\n\\end{document}\n")

# output

info("Writing .tex file...")
fileout = open("pi.tex","w")
write(fileout, texout)
close(fileout)

