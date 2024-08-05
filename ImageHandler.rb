require 'fastimage' # to read dimemsion of image ==> must install fastimage by writing this syntax in terminal port:  gem install fastimage

#Finding width of imput image
def width_Of(imagePath)
    dimensions = FastImage.size(imagePath)
    return dimensions[0]
end

#Finding height of imput image
def height_Of(imagePath)
    dimensions = FastImage.size(imagePath)
    return dimensions[1]
end



