# COMPUTER VISION 2
# Assignment 1
# Problem 3
# Javier De Velasco Oriol - javo10portero@hotmail.com
# Christian Benz - christian.benz@stud.tu-darmstadt.de

using Images
using PyPlot
#using ImageView
using ImageMagick
using FixedPointNumbers

include("Common.jl")
using Common

#cd("C:/Users/Arbeit/Desktop/Computer Vision/Assignment 1/asgn1_data")

#------------Subtask 1------------
#get image
img = PyPlot.imread("a1p3.png")

#convert image into grayscale
img = rgb2gray(img)

#convert to double format (i.e. float64)
img = convert(Array{Float64,2}, img)

#scale to [0;255]
img = img.*255;

#------------Subtask 2------------
#correct aspect ration -> nothing to be done

#display image
imshow(img, "gray")
sleep(3)


#------------Subtask 3------------
#compute minimal pixel value
#short alternative: extrema(img)[1]
function minVal(img)#::type?!
	min = 255
	for i = 1:size(img)[1]
		for j = 1:size(img)[2]
			#in case current value is smaller
			if img[i,j] < min
				#substitute min
				min = img[i,j]
			end
		end
	end
	return min
end


#compute maximal pixel value
#short alternative: extrema(img)[2]
function maxVal(img)#::type?!
	max = 0
	for i = 1:size(img)[1]
		for j = 1:size(img)[2]
			#in case current value is larger
			if img[i,j] > max
				#substitute max
				max = img[i,j]
			end
		end
	end
	return max
end

#compute mean value (devectorized)
#short alternative: mean(img)
function meanValDevec(img)#::type?!
	#accumulator for mean
	mean = 0

	#total amount of pixels
	imgSize = size(img)[1]*size(img)[2]

	for i = 1:size(img)[1]
		for j = 1:size(img)[2]
			#accumulate value normalized by image size
			mean += img[i,j]
		end
	end
	return mean / imgSize
end

#provide console output
println("min value = ", minVal(img))
println("max value = ", maxVal(img))
println("mean value = ", meanValDevec(img))



#------------Subtask 4------------

#compute mean value (vectorized)
function meanValVec(img)
	mean = ones(1,480)*img*(1/(480*480).*ones(480,1))
	return mean[1]
end


#compare runtime of vectorized and devectorized
#MEAN computation
println("\nMEAN computation")
avgDevec = 0
avgVec = 0
tic()
for i = 1:10
	#devectorized
	tic()
	meanValDevec(img)
	avgDevec += toc()

	#vectorized
	tic()
	meanValVec(img)
	avgVec += toc()
end

#console output
println("\nDevectorized: ", avgDevec/10, "    Vectorized: ", avgVec/10)
#RESULT: Devectorized: 0.022549406    Vectorized: 0.0012350648000000002

# ANSWER: The vectorized version is clearly superior to the devectorized version
# in terms of runtime. That must be due to the fact that Julia is -- like other
# programming languages -- optimized for vetor and matrix operations. For
# problems with high computational effort it therefore is reasonable to use
# vectorized operations wherever possible.
