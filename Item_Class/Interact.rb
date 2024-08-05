require 'ruby2d'

class InteractRange
  attr_accessor :image, :worldX,  :worldY, :solidArea, :upDirection, :downDirection, :leftDirection,
  :rightDirection, :collisionOn
  def initialize(worldX, worldY)
    @worldX = worldX
    @worldY = worldY
    @solidArea = Rectangle.new(
      x: -10, y: -10,            # Position
      width: 64, height: 64,  # Size
      opacity: 0
    )
  end
end
