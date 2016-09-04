### [ Important information !! ]
### You can directly use the script below with the defined functions in the same folder.
### Also, you can freely modified the script & parameters of the functions as you want.
### Or, you can totally ignore the whole codes & descriptions below and make your own implementation from the scratch.
### The most important thing is to show that your code is correctly running!



### Include / import----------------------------------------------

using Images

# You can use the pre-defined files or make your own files.
include("mrf_log_prior.jl");
include("random_disparity.jl");
include("constant_disparity.jl");

# If you want, you can use the Common.jl module from HW1,
push!(LOAD_PATH, pwd())
import Common



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




### Task 2 -------------------------------------------------------
## 1) Load 'gt.pgm'
## 2) Appropriately scale the input map in the double format (see the pdf file.).
## 3) Compute the Log-prior of the input map.

println("[Task2] Log-prior of ground truth disparity map of Tsukuba dataset");

# ----- your code here -----
img_task2 = PyPlot.imread("gt.pgm")/16



lp_task2 = mrf_log_prior(img_task2, sigma, alpha);
println(" Log Prior is = $lp_task2");



### Task 3 -------------------------------------------------------
## 1) Create a random disparity map. (complete the file 'random_disparity.jl')
## 2) Compute the Log-prior of the map.

println("[Task3] Log-prior of random disparity map:");

# ----- your code here -----
img_task3=random_disparity(size(img_task2),0,16)
lp_task3 = mrf_log_prior(img_task3, sigma, alpha);





lp_task3 = mrf_log_prior(img_task3, sigma, alpha);
println(" Log Prior is = $lp_task3");



### Task 4 -------------------------------------------------------
## 1) Create a constant disparity map. (complete the file 'constant_disparity.jl')
## 2) Compute the Log-prior of the map.


println("[Task4] Log-prior of constant disparity map");

# ----- your code here -----
constant_val = 8;
img_task4 = constant_disparity(img_task2,constant_val)





lp_task4 = mrf_log_prior(img_task4, sigma, alpha);
println(" Log Prior is = $lp_task4");
# A value of zero means there is no disparity difference, thus a higher value means there is way more variance in the image ( or that the neighbouring pixels are not compatible)
# This is very useful because in the real world objects and surfaces tend to have similar values when the pixels are close to each other.
#Thus the MRF log prior manages to encode this previous information about the world in the measurement of how coherent the image is and thus the actual probability of it occuring naturally.
# A good image should neither lie close to a value of zero nor go too high. This way we can choose an image that is actually interesting and gives us information without being totally random.
