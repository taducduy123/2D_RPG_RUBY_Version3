require 'ruby2d'
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../WorldHandler'
require_relative '../ImageHandler'
require_relative 'Loot_item'
require_relative '../WorldHandler'
require_relative '../Dialogue/ChatBubble'
require_relative 'Interact'

class Chest
  attr_accessor :image, :worldX,  :worldY, :solidArea, :upDirection,
  :downDirection, :leftDirection, :rightDirection, :collisionOn, :interactRange, :activemess

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
      time: 300

     )
     @Inside_The_Chest = []

     @Inside_The_Chest << inside_The_Chest

     @worldX = worldX

     @worldY = worldY

     @interactRange = InteractRange.new(worldX,worldY)

     @isEmpty = @Inside_The_Chest.empty?
     @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )
     @collisionOn = false
     @activemess = ChatBubble.new( 0, Window.height - Window.height / 11,
     Window.width ,Window.height / 5,"Press E to open")
     @activemess.hide
  end

  def playerInteract (player)
    @image.play animation: :open
    if !(@isEmpty)
      if player.myInventory.IsFull
        @activemess.set_text("Your inventory is full!")
      else
        #puts "item ad"
        player.myInventory.add_to_inventory(@Inside_The_Chest)
        @activemess.set_text("Item added to your inventory")
        removeItem
      end
    else
       @activemess.set_text ("Chest is emty")
    end
  end

  def updateChest(player, chestId)
    WorldHandler::DrawObject(self, player)
      if CCHECK.checkEntity_Collide_SingleTarget(player,@interactRange) == true
        @activemess.show
        player.interacting = chestId
      else
        @activemess.hide
        @activemess.set_text("Press E to open")
        player.interacting = -1
      end

  end

  def removeItem()
    @Inside_The_Chest.clear
    @isEmpty = true
  end
end
