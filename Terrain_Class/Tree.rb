require 'ruby2d'

class Tree
  attr_accessor :image
  attr_reader :isSolid
  def initialize(x, y, width, height)
    @image = Image.new('Image/Tree.png',
     x: x,
     y: y,
     width: width,
     height: height,
     z: -1
     )
     @isSolid = true
  end
end
