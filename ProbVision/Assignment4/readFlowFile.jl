function readFlowFile(filename)

TAG_FLOAT = 202021.25;  # check for this when READING the file

# sanity check
if isempty(filename) == 1
    error("readFlowFile: empty filename");
    return 0;
end

idx = search(filename, ".");
idx = idx[end];

if length(filename[idx:end]) == 1
    println("readFlowFile: extension required in filename" + filename);
    return 0;
end

if (filename[idx:end] == ".flo") != 1
    println("readFlowFile: filename %s should have extension .flow" + filename);
    return 0;
end



fid = open(filename, "r");
isopen(fid)
if (isopen(fid) != true)
    println("readFlowFile: could not open: " + filename);
    return 0;
end

tag     = read(fid, Float32);
width   = read(fid, Int32);
height  = read(fid, Int32);

# sanity check

if (tag != TAG_FLOAT)
    println("readFlowFile(" + filename + "): wrong tag (possibly due to big-endian machine?)")
    return 0;
end

if (width < 1 || width > 99999)
    println("readFlowFile(" + filename + "): illegal width " + width);
    return 0;
end

if (height < 1 || height > 99999)
    println("readFlowFile(" + filename + "): illegal height " + height);
    return 0;
end

nBands = 2;

# arrange into matrix form
tmp = read(fid, Float32, height * width* nBands);
tmp = convert(Array{Float32}, tmp);
tmp = reshape(tmp, (Int64(width*nBands), Int64(height)));
tmp = tmp';
img = similar(tmp,Int64(height),Int64(width),Int64(nBands));
img[:,:,1] = tmp[:, (1:width)*nBands-1];
img[:,:,2] = tmp[:, (1:width)*nBands];

close(fid)
return img;

end
