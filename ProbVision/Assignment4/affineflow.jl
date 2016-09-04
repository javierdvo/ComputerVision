using PyPlot
using Images

include("Common.jl")
include("readFlowFile.jl")
include("flowToColor.jl")

function endpoint(u,v,u_gt,v_gt)
    return sum(sqrt((u-u_gt).^2+(v-v_gt).^2))/length(u)
end

im1=Common.rgb2gray(PyPlot.imread("frame10.png")/1.0*255)
im2=Common.rgb2gray(PyPlot.imread("frame11.png")/1.0*255)
wsize=21
gt=readFlowFile("flow10.flo")


structTensor=[sum(ix.^2) sum(ix.^2.*x) sum(ix.^2.*y) sum(ix.*iy) sum(ix.*iy.*x) sum(ix.*iy.*y);
sum(ix.^2.*x) sum(ix.^2.*x.^2) sum(ix.^2.*y*.x) sum(ix.*iy.*x) sum(ix.*iy.*x.^2) sum(ix.*iy.*y.*x);
sum(ix.^2.*y) sum(ix.^2.*x.*y) sum(ix.^2.*y.^2) sum(ix.*iy.*y) sum(ix.*iy.*x.*y) sum(ix.*iy.*y.^2);
sum(ix.*iy) sum(ix.*iy.*x) sum(ix.*iy.*y) sum(iy.^2) sum(iy.^2.*x) sum(iy.^2.*y);
sum(ix.*iy.*x) sum(ix.*iy.*x.^2) sum(ix.*iy.*y.*x) sum(iy.^2.*x) sum(iy.^2.*x.^2) sum(iy.^2.*y.*x);
sum(ix*.iy.*y) sum(ix.*iy.*x.*y) sum(ix.*iy.*y.^2) sum(iy.^2.*y) sum(iy.^2.*x.*y) sum(iy.^2.*y.^2)
              ]
