using Optim
#SEEMINGLY some conflicts with other packages - load Optim first

function stereo(I0, I1, sigma, alpha)

  #STOPPED HERE;
  #TO BE CONTINUED

  function f(x::Vector)
      return 2.*x
  end

  function g!(x::Vector, storage::Vector)
      storage[1] = 2
      storage[2] = 2
  end

  #implement gradient descent
  #cf. https://github.com/JuliaOpt/Optim.jl
  res = optimize(f, g!,
                 [0.0, 0.0],
                 method = GradientDescent(),
                 grtol = 1e-12,
                 iterations = 10,
                 store_trace = true,
                 show_trace = false)


  return res
end
