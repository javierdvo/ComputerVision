


# I suppose you don't not need to do anything with the dirac pulse etc.
function gradientascent(x, M, sigma, alpha)
  eta = 5
  iters = 1000
  x_next = x
  x_clone = copy(x)

  for i = 1:iters
    # set smaller eta for finetuning
    if iters - i < 200
      eta = 0.1
    end
    x = x_next
    x_next = x + eta * M .* mrf_grad_log_prior(x,sigma,alpha)
  end

  imshow(x_next, "gray")

  return x_next
end


# there for sure is a much easier way to do this
function rand_mask(size,amount)
  rows,cols = size
  numbOnes = convert(UInt16,round(rows*cols*amount))
  numbZeros = convert(UInt16,rows*cols - numbOnes)
  mask = [ones(numbOnes); zeros(numbZeros)]
  mask = shuffle(mask)
  return reshape(mask,rows,cols)
end

img = PyPlot.imread("./images/castle.png")
img = convert(Array{Float64},img) * 255
mask = rand_mask(size(img), 0.5)
#apply mask on image
imgMasked = img .* -(mask - 1) + mask * 127


test = gradientascent(imgMasked, mask, sigma, alpha)
