require 'ruby2d'

class Grass
  attr_accessor :image
  attr_reader :isSolid
  def initialize(x, y, width, height)
    @image = Image.new('Image/Grass.png',
     x: x,
     y: y,
     width: width,
     height: height,
     z: -1
     )
     isSolid = false
  end
end