function LucasKanade(img1,img2,winSize = 21)
  # get the image sizes
  rows, cols = size(img1)

  # compute offset for border padding
  offset = convert(Integer,floor(winSize/2))

  # compute x-y-gradient
  im1Grad = imgradients(img1)

  # store x gradient
  im1Gradx = zeros(rows+winSize, cols+winSize)
  im1Gradx[(1+offset):rows+offset, (1+offset):cols+offset] = im1Grad[1]

  # store y gradient
  im1Grady = zeros(rows+winSize, cols+winSize)
  im1Grady[(1+offset):rows+offset, (1+offset):cols+offset] = im1Grad[2]

  # compute t gradient
  imGradT = zeros(rows+winSize, cols+winSize)
  imGradT[(1+offset):rows+offset, (1+offset):cols+offset] = img1 - img2


  # container for flow
  flow = zeros(size(img1)[1], size(img1)[2],2)

  # iterate over all pixels
  for i = (1+offset):rows+offset
    for j = (1+offset):cols+offset

        # get the gradients for current sliding window
        I_x = im1Gradx[i-offset:i+offset, j-offset:j+offset]
        I_y = im1Grady[i-offset:i+offset, j-offset:j+offset]
        I_t = imGradT[i-offset:i+offset, j-offset:j+offset]

        # compute the structure tensor
        struc_tens = [  sum(I_x.^2) sum(I_x.*I_y)
                        sum(I_x.*I_y) sum(I_y.^2)]

        # invert structure tensor
        inv_struc_tens = pinv(struc_tens)

        # compute optical flow in x and y direction
        u,v = -inv_struc_tens * -[sum(I_x.*I_t) ; sum(I_y.*I_t)]

        # store the values for optical flow
        flow[i-offset,j-offset,1] = u
        flow[i-offset,j-offset,2] = v
    end
  end
  return flow
end


function LucasKanadeOffset(img1,img2,winSize = 21,offx,offy)
  # get the image sizes
  rows, cols = size(img1)

  # compute offset for border padding
  offset = convert(Integer,floor(winSize/2))


  # compute x-y-gradient
  im1Grad = imgradients(img1)

  # store x gradient
  im1Gradx = zeros(rows+winSize, cols+winSize)
  im1Gradx[(1+offset):rows+offset, (1+offset):cols+offset] = im1Grad[1]

  # store y gradient
  im1Grady = zeros(rows+winSize, cols+winSize)
  im1Grady[(1+offset):rows+offset, (1+offset):cols+offset] = im1Grad[2]

  # compute t gradient
  imGradT = zeros(rows+winSize, cols+winSize)
  img2values=zeros(size(img2))
  for k1=1:length(img2)
    indexi=k+round(offy[k])+size(img2,1)*round(offx[k])
    if indexi>=1&&indexi<=length(img2)
      img2values[k]=img2[indexi]
    end
  end
  imGradT[(1+offset):rows+offset, (1+offset):cols+offset] = img1 - img2values
  # container for flow
  flow = zeros(size(img1)[1], size(img1)[2],2)

  # iterate over all pixels
  for i = (1+offset):rows+offset
    for j = (1+offset):cols+offset

        # get the gradients for current sliding window
        I_x = im1Gradx[i-offset:i+offset, j-offset:j+offset]
        I_y = im1Grady[i-offset:i+offset, j-offset:j+offset]
        I_t = imGradT[i-offset:i+offset, j-offset:j+offset]

        # compute the structure tensor
        struc_tens = [  sum(I_x.^2) sum(I_x.*I_y)
                        sum(I_x.*I_y) sum(I_y.^2)]

        # invert structure tensor
        inv_struc_tens = pinv(struc_tens)

        # compute optical flow in x and y direction
        u,v = -inv_struc_tens * -[sum(I_x.*I_t) ; sum(I_y.*I_t)]

        # store the values for optical flow
        flow[i-offset,j-offset,1] = u
        flow[i-offset,j-offset,2] = v
    end
  end
  return flow
end
