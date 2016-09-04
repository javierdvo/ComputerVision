using Images
using PyPlot
using JLD
using Optim

# Load features and labels from file
function loaddata(path::ASCIIString)

  @assert length(labels) == size(features,2)
  return features::Array{Float64,2}, labels::Array{Float64,1}
end

# Show a 2-dimensional plot for the given features with different colors according
# to the labels.
function showbefore(features::Array{Float64,2},labels::Array{Float64,1})

  return nothing::Void
end

# Show a 2-dimensional plot for the given features with decision boundary and margins
function showafter(features::Array{Float64,2},labels::Array{Float64,1},w::Array{Float64,1},b::Float64)

  return nothing::Void
end

# Evaluates the loss function of the SVM:
# L(w,b,X,y) = 0.5*|w|² + C*sum(max(0,1-y(w^T*x +b)))
# theta = [w; b]
function svmloss(theta::Array{Float64,1}, X::Array{Float64,2}, y::Array{Float64,1}, C::Float64)

  return loss::Float64
end

# Evaluate the gradient of the SVM loss w.r.t. w and b
# The gradient should be stored in the vector 'storage'
# theta = [w; b]
function svmlossgrad(theta::Array{Float64,1}, storage::Array{Float64,1}, X::Array{Float64,2}, y::Array{Float64,1}, C::Float64)

  return storage::Array{Float64,1}
end

# Use BFGS to optmize w and b of the SVM loss
function train(trainfeatures::Array{Float64,2}, trainlabels::Array{Float64,1}, C::Float64)

  return w::Array{Float64,1},b::Float64
end

# Predict the classes of the given data points using w and b.
# The class should be either -1 or 1
# Data points on the decision boundary should be treated as class -1
function predict(features::Array{Float64,2}, w::Array{Float64,1}, b::Float64)

  return predictions::Array{Float64,1}
end


# Problem 2: Support Vector Machines

function problem2()
  # LINEAR SEPARABLE DATA

  # load data
  features,labels = loaddata("../data-julia/separable.jld")

  # show data points
  showbefore(features,labels)
  title("Data for Separable Case")

  # train SVM
  C = 1000.0
  w,b = train(features,labels,C)

  # show optimum and plot decision boundary and margins
  println("w = $(w[1]) $(w[2])   b = $b")
  showafter(features,labels,w,b)
  title("Learned Decision Boundary for Separable Case")


  # LINEAR NON-SEPARABLE DATA

  features2,labels2 = loaddata("../data-julia/nonseparable.jld")
  showbefore(features2,labels2)
  title("Data for Non-Separable Case")
  C = 100.0
  w,b = train(features2,labels2,C)
  println("w = $(w[1]) $(w[2])   b = $b")
  showafter(features2,labels2,w,b)
  title("Learned Decision Boundary for Non-Separable Case")


  # PLANE-BIKE-CLASSIFICATION FROM PROBLEM 1
  
  # Task: Find a good value for C
  C = 0

  # load data
  trainfeatures,trainlabels = loaddata("../data-julia/imgstrain.jld")
  testfeatures,testlabels = loaddata("../data-julia/imgstest.jld")
  # train SVM and predict classes
  w,b = train(trainfeatures,trainlabels,C)
  trainpredictions = predict(trainfeatures, w, b)
  testpredictions = predict(testfeatures, w, b)
  # show error
  trainerror = sum(trainpredictions.!=trainlabels)/length(trainlabels)
  testerror = sum(testpredictions.!=testlabels)/length(testlabels)
  println("Training Error Rate: $(round(100*trainerror,2))%")
  println("Testing Error Rate: $(round(100*testerror,2))%")

  return
end
