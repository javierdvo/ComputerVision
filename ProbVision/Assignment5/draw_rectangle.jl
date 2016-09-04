function draw_rectangle(img,x_min,y_min,x_max,y_max)
# determine the size of the image
  rows,cols = size(img)

  # copy image for storing the results
  res = copy(img)

  # check all pixels, whether they must be colored or not
  for y = 1:rows
    for x = 1:cols
      # in case the current pixel lies on the box boundary
      if x >= x_min && x <= x_max && (y == y_min || y == y_max) ||
        (x == x_min || x == x_max) && y >= y_min && y <= y_max
        # set r channel to zero
        res[y,x,1] = 0
        # set g channel to one (so the boundary should be green)
        res[y,x,2] = 1
        # set b channel to zero
        res[y,x,3] = 0
      end
    end
  end
  return res
end
