using JLD
using PyPlot

# -------------SUBTASK 1----------------
# load data
d_train = load("train_data.jld")

# NOTE: input data are transposed
X = d_train["X"]'
Z = d_train["Z"]'

rows,cols = size(X)


# plot the measurement-hidden state pairs
for i = 1:cols
  plot([X[1,i],Z[1,i]],[X[2,i],Z[2,i]], "b")
end



# -------------SUBTASK 2----------------

# compute the A,W,H,Q parameter
X_curr = X[:,2:cols]
X_prev = X[:,1:cols-1]

A = (X_curr*X_prev') * inv(X_prev*X_prev')

W = 1/(cols-1) * (X_curr*X_curr' - A * (X_prev*X_curr'))

H = Z*X' * pinv(X*X')

Q = 1/cols * (Z*Z' - H * X*Z')



# -------------SUBTASK 3----------------
# load data
d_test = load("test_data.jld")

# store the states and measurements
X = d_test["X"]'
Z = d_test["Z"]'

# compute the Kalman prediction
include("kalman_filter.jl")
X_pred = kalman_filter(Z,A,W,H,Q)



# -------------SUBTASK 4----------------

# plot the results
for i = 1:cols
  plot([X[1,i],Z[1,i]],[X[2,i],Z[2,i]], "b")
  plot([X_pred[1,i],Z[1,i]],[X_pred[2,i],Z[2,i]], "r")
end

# Since the first state is naively initialized with zeros, the first
# few estimates are not very accurate. But once the estimates are on
# track, only minor deviations occur. As it can be seen the learning parameters obtained with the training set extrapolate really well to describe the test set.
