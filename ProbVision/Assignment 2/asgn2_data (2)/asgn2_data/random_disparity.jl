## generate a random disparity map ---------------------------
function random_disparity(s, a, b)

  # Create a random noise disparity map, sized s, with values in the range [a, b].
  # You can freely change the name/type/number of parameters of functions.

  disparity_map = rand(a:b, s)


  return disparity_map;		# return your results

end
