require 'ruby2d'

class Water
  attr_accessor :image
  attr_reader :isSolid
  def initialize(x, y, width, height)
    @image = Image.new('Image/Water.png',
     x: x,
     y: y,
     width: width,
     height: height,
     z: -1
     )
     @isSolid = false
  end
end