require 'ruby2d'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../WorldHandler'


include CCHECK
include WorldHandler




class NPC < Sprite
  attr_reader :x, :y, :speed, :worldX, :worldY, :moveCounter
  attr_accessor :upDirection, :downDirection, :leftDirection,
  :rightDirection, :solidArea, :collisionOn, :image, :onPath,
  :chatprogress

  def initialize(worldX, worldY, width, height)

    @image = nil

    #Direction and Speed
    @speed = nil
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false

    @interactRange = InteractRange.new(worldX,worldY)


    #World Coordinate
    @worldX = worldX
    @worldY = worldY
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )
    @collisionOn = false
  end

  def updateNPC(player, map, npcId)
    WorldHandler::DrawObject(self, player)
    checkCollision(player,map, npcId)
  end

  def checkCollision(player, map, npcId)
    CCHECK.checkTile(self, map)
    if CCHECK.checkEntity_Collide_SingleTarget(player, @interactRange) == true
      player.talktoNpc = npcId
    else
      player.talktoNpc = -1
    end
    startDialogue(player)

  end

  def startDialogue(with)
     # chat override
  end

end
