include("find_object_christian.jl")


function kalman_filter(x_init,Z,A,W,H,Q)
  # initialize P and K
  P = eye(2,2)
  K = zeros(2,2)

  rows,cols = size(Z)

  # predicted states
  X_pred = zeros(rows,cols)
  X_pred[:,1]=x_init
  for i = 2:cols
    # time update
    x = A * X_pred[:,i-1]
    P = A * P * A' + W

    # measurement update
    K = P * H' * inv(H * P * H' + Q)
    P = (eye(2,2) - K * H) * P
    x = x + K * (Z[:,i] - H * x)

    # store predicted state
    X_pred[:,i] = x
  end
  return X_pred
end
function kalman_filter(Z,A,W,H,Q)
  # initialize P and K
  P = eye(2,2)
  K = zeros(2,2)

  rows,cols = size(Z)

  # predicted states
  X_pred = zeros(rows,cols)

  for i = 2:cols
    # time update
    x = A * X_pred[:,i-1]
    P = A * P * A' + W

    # measurement update
    K = P * H' * inv(H * P * H' + Q)
    P = (eye(2,2) - K * H) * P
    x = x + K * (Z[:,i] - H * x)

    # store predicted state
    X_pred[:,i] = x
  end
  return X_pred
end

function kalman_motion(images,object,A,W,H,Q)
  # initialize P and K
  P = eye(4,4)
  K = zeros(4,4)

  # predicted states

  X_pred = zeros(4,size(images,3))
  X_pred[:,1]=[350,150,-1,0]
  for i = 2:size(images,3)
    # time update
    x = A * X_pred[:,i-1]
    P = A * P * A' + W
    # measurement update
    K = P * H' * inv(H * P * H' + Q)
    P = (eye(4,4) - K * H) * P
    fff=find_object(images[:,:,i],object,round(x[1]),round(x[2]))#Z
    x = x + K * (fff - H * x)
    # store predicted state
    X_pred[:,i] = x
  end
  return X_pred
end
