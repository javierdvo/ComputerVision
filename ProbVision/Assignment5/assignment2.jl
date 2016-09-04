using JLD
using PyPlot
#OTHER ONE IS THE GOOD ONE
d_train = load("train_data.jld")

X = d_train["X"]'
Z = d_train["Z"]'

rows,cols = size(X)


# plot the measurement-hidden state pairs
#for i = 1:rows
#  plot([X[i,1],Z[i,1]],[X[i,2],Z[i,2]], "b")
#end


# compute the A,W,H,Q parameter
X_curr = X[:,2:cols]
X_prev = X[:,1:cols-1]

# NOTE: the transposes are tricky; opposite to slides due to data storage
A = (X_curr*X_prev') * pinv(X_prev*X_prev')

W = 1/(cols-1) * (X_curr*X_curr' - A * (X_prev*X_curr'))

H = Z*X' * pinv(X*X')
include("kalman_filter.jl")

Q = 1/cols * (Z*Z' - H * X*Z')
#X_init=X[:,1]
X_init=[0,0]
X_esti = kalman_filter(X[:,1],Z,A,W,H,Q)

# plot the true and the kalman filtered measure-state pairs
for i = 1:cols
  plot([X[1,i],Z[1,i]],[X[2,i],Z[2,i]], "b")
  plot([X_esti[1,i],Z[1,i]],[X_esti[2,i],Z[2,i]], "r")
end


d_test = load("test_data.jld")

X = d_test["X"]'
Z = d_test["Z"]'

rows,cols = size(X)

# assume first state to be given
# NOTE: not working properly
X_esti = kalman_filter(X[:,1],Z,A,W,H,Q)

# plot the true and the kalman filtered measure-state pairs
for i = 1:cols
  plot([X[1,i],Z[1,i]],[X[2,i],Z[2,i]], "b")
  plot([X_esti[1,i],Z[1,i]],[X_esti[2,i],Z[2,i]], "r")
end
