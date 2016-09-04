using Images
using PyPlot

include("Common.jl")
include("a2p3.jl")
include("stereo.jl")

sigma = 1
alpha = 1
I0=Common.rgb2gray(PyPlot.imread("i0.ppm")/1.0)
I1=Common.rgb2gray(PyPlot.imread("i1.ppm")/1.0)
stereo(I0,I1,sigma,alpha)
