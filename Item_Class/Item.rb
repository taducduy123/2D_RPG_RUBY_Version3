require 'ruby2d'
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../WorldHandler'
require_relative '../ImageHandler'
require_relative 'Loot_item'
require_relative '../WorldHandler'


class Item
  attr_accessor :image, :worldX,  :worldY, :solidArea, :collisionOn

  def initialize(worldX, worldY, inside_The_Chest)
     @image = Sprite.new(
      'Image/Chest.png',
      x: worldX,
      y: worldY,
      width: CP::TILE_SIZE,
      height: CP::TILE_SIZE,
      clip_width: width_Of('Image/chest.png') / 5,
      clip_height: height_Of('Image/chest.png'),
      animations: {open: 1..4},

     )

     @opened = false
     @Inside_The_Chest = inside_The_Chest
     @worldX = worldX
     @worldY = worldY

     @solidArea = Rectangle.new(
      x: 0, y: 0,             # Position
      width: 48, height: 48,  # Size
      opacity: 0
    )
     @collisionOn = false
  end

  def PlayerInteract (player)
    if @opened == false
     @image.play animation: :open

      if player.myInventory.IsFull
        @image.play animation: :close
        puts "player is full"
      else
        player.myInventory.add_to_inventory(@Inside_The_Chest)
        removeItem

      end
    end
  end

  def updateItem(player)
    WorldHandler::DrawObject(self, player)
    if CCHECK.checkEntity_Collide_SingleTarget(player, self) == true
      PlayerInteract(player)
      # put "hi"
    end
  end

  def removeItem()
    @Inside_The_Chest.remove
  end
end
