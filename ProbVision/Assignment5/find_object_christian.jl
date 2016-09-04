# NOTE: tested on sequence/13.png
# I recommand (and I've already started) a new cleaner implementation of this;
# the current version is only a
# major Drawbacks: margin treatment, fix searching region
function find_object(img,ball,prior_x,prior_y)

  # determine the sizes of image and template
  rows,cols = size(img)
  ball_size = size(ball,1)

  # initialize the error and positions
  error = Inf
  min_y = prior_y
  min_x = prior_x

  # size of the region of interest
  r_size = 50

  # define region of interest
  roi_left = max(prior_x-r_size,1)
  roi_right = min(prior_x+r_size,cols)
  roi_upper = max(prior_y-r_size,1)
  roi_lower = min(prior_y+r_size,rows)
  res=[0,0]
  # match the template for the whole region of interest
  for i = roi_upper:roi_lower-ball_size
    for j = roi_left:roi_right-ball_size

      # compute the difference between the template and current patch
      # (img has same values across all 3 dimensions)
      diff = img[ i:i+ball_size-1,
                  j:j+ball_size-1,1] - ball

      # compute the error for the current patch
      ssd = sum(diff.^2)

      # if current patch has least error, take it as the new best match
      if error > ssd
        error = ssd
        min_y = i+floor(ball_size/2)
        min_x = j+floor(ball_size/2)
        res=[min_x,min_y]
      end
    end
  end
  return res
end
