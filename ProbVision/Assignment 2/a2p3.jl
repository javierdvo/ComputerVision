# COMPUTER VISION 2
# Assignment 2
# Problem 3
# Javier De Velasco Oriol - javo10portero@hotmail.com
# Christian Benz - christian.benz@stud.tu-darmstadt.de

### [ Important information !! ]
### You can directly use the script below with the defined functions in the same folder.
### Also, you can freely modified the script & parameters of the functions as you want.
### Or, you can totally ignore the whole codes & descriptions below and make your own implementation from the scratch.
### The most important thing is to show that your code is correctly running!

### Include / import----------------------------------------------

using Images
using PyPlot
#cd("C:/Users/Arbeit/OneDrive/Computer Vision/Assignment 2/asgn2_data")

# You can use the pre-defined files or make your own files.
include("mrf_log_prior.jl");
include("random_disparity.jl");
include("constant_disparity.jl");

# If you want, you can use the Common.jl module from HW1,
#push!(LOAD_PATH, pwd())
#import Common

#cd("C:/Users/Arbeit/Desktop/Computer Vision/Assignment 2/asgn2_data")

### param setting ------------------------------------------------

sigma = 1;
alpha = 1;



### Task 1 -------------------------------------------------------
## 1) Implement the MRF Log-prior with Student-t potentials (in 'mrf_log_prior.jl') (Mandatory)
## 2) Check the result of the toy example (Optional, self-verification).

println("[Task1] Log-prior of a toy example");

# a toy example
img_task1 = [1 1 1;1 1 1;1 1 2];

lp_task1 = mrf_log_prior(img_task1, sigma, alpha);
println(" Log Prior is = $lp_task1");
#RESULT = -0.8109302162163289




### Task 2 -------------------------------------------------------
## 1) Load 'gt.pgm'
## 2) Appropriately scale the input map in the double format (see the pdf file.).
## 3) Compute the Log-prior of the input map.

println("[Task2] Log-prior of ground truth disparity map of Tsukuba dataset");


# load and convert ground truth image
img_task2 = PyPlot.imread("gt.pgm")
img_task2 = convert(Array{Float64}, img_task2)
# divide by 16
img_task2 /= 16


lp_task2 = mrf_log_prior(img_task2, sigma, alpha);
println(" Log Prior is = $lp_task2");
#RESULT = -9595.861196209871



### Task 3 -------------------------------------------------------
## 1) Create a random disparity map. (complete the file 'random_disparity.jl')
## 2) Compute the Log-prior of the map.


println("[Task3] Log-prior of random disparity map");

#get random disparity image
img_task3 = random_disparity(size(img_task2), 0, 16)

lp_task3 = mrf_log_prior(img_task3, sigma, alpha);
println(" Log Prior is = $lp_task3");
#RESULT = -537079.6999975442



### Task 4 -------------------------------------------------------
## 1) Create a constant disparity map. (complete the file 'constant_disparity.jl')
## 2) Compute the Log-prior of the map.


println("[Task4] Log-prior of constant disparity map");

#constant_val = 8;
img_task4 = constant_disparity(size(img_task2),8)


lp_task4 = mrf_log_prior(img_task4, sigma, alpha);
println(" Log Prior is = $lp_task4");
#RESULT = 0.0


#ANSWER:
# The log-prior of a constant disparity has log-prior of zero hence a prior of one.
# That seems reasonable since an image shifted by constant disparities still stays
# the same image only translated in a certain direction. Such diaparity maps are
# reasonable to occur.
# The noisy disparity map on the other hand shows a pretty low log-prior, i.e.
# the prior of this disparity map is virutally zero. According to this prior (which
# is based on the student-t potential function, a function more robust to outliers
# than e.g. the gaussian). This low prior for noisy disparities is also reasonable
# since the pixels representing one objects or surfaces of the world have the same
# (or similar) disparity values. Erratic disparities (like in the random case)
# on the other hand are way more unnatural to occur.
# The ground truths disparity map is by factor 50 more likely than the noisy map
# but also way more unlikely than the constant disparity. This result is surprising
# since we know that the ground truth disparity map is the actual disparity map.
# However, for the MAP estimate the absolute probabilities are not very relevant,
# rather the relative differences of the prior in combination with the likelihood
# determine what is a more and less appropriate disparity map.
