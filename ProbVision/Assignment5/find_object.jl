function SSD(img,object)
  window=35-1
  offset=int(window/2)
  imgext=zeros(size(img,1)+window,size(img,2)+window)
  imgext[offset+1:end-offset,offset+1:end-offset]=img
  minerr=Inf
  position=zeros(1,2)
  for x=offset+1:size(img,1)+offset
    for y=offset+1:size(img,2)+offset
      error=sum((object-imgext[x-offset:x+offset,y-offset:y+offset]).^2)
      if (error<minerr)
        minerr=error
        position=[x-offset,y-offset]
      end
    end
  end
  return position,minerr
end

function SSD(img,object,priorx,priory,interest)
  img=img[priorx]
  window=35-1
  offset=int(window/2)
  imgext=zeros(size(img,1)+window,size(img,2)+window)
  imgext[offset+1:end-offset,offset+1:end-offset]=img
  minerr=Inf
  position=zeros(1,2)
  for x=offset+1:size(img,1)+offset
    for y=offset+1:size(img,2)+offset
      error=sum((object-imgext[x-offset:x+offset,y-offset:y+offset]).^2)
      if (error<minerr)
        minerr=error
        position=[x-offset,y-offset]
      end
    end
  end
  return position,minerr
end
