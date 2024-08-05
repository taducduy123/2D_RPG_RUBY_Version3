require 'ruby2d'
require_relative 'HealthBar'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative 'Monster'
include CCHECK

class Bat < Monster
  def initialize(wordlX, worldY, width, height, player)
    super(wordlX, worldY, width, height)
    
    #1. Image and Animation
    @image = Sprite.new(
      'Image/Bat.png',
      x: @worldX - player.worldX + player.x,
      y: @worldY - player.worldY + player.y,
      width: width, height: height,
      clip_width: width_Of('Image/Bat.png') / 2,
      animations: {fly: 1..2},
      loop: true,
      time: 200
    )
    @image.play

    #2. Health Bar
    @healthBar = HealthBar.new(100, 100, -999, -999, 48)

    #3. Speed
    @speed = 1

    #3.1. Attack
    @attack = 10

    #4. This will be convenient for random move function
    @moveCounter = 0
    @attackDelay = 0
  end


#-------------------------------- Override Methods -----------------------------------------
  def updateMonster(player, map, items, npcs, monsters)  
    if(@exist == true)
      self.DrawMonster(player)
      self.DrawHealthBar(player)
      self.randMove(player, map, items, npcs, monsters)
      # self.moveForwardTo((player.worldY + player.solidArea.y) / CP::TILE_SIZE, (player.worldX + player.solidArea.x) / CP::TILE_SIZE, 
      #                     player, map, pFinder, items, npcs, monsters)

      if @healthBar.isDead?
        @exist = false
      end
      # Check if collision with player then attack at right time
      if @onAttackBox
        if @attackDelay >= 20
          self.attackTarget(player)
          @attackDelay = 0
        end
        @attackDelay += 1
      end
    elsif @existFlag
      self.removeMonster
      @existFlag = false
    end
  end





#------------------------------ Random Move ---------------------------------------------------
  def randMove(player, map, items, npcs, monsters)

    @moveCounter = @moveCounter + 1
    # generate a random number after every 120 steps
    if(@moveCounter == 120)
      @upDirection = false
      @downDirection = false
      @leftDirection = false
      @rightDirection = false

      ranNum = rand(1..100)
      if(1 <= ranNum && ranNum <= 25)
        @upDirection = true
      elsif(25 < ranNum && ranNum <= 50)
        @downDirection = true
      elsif(50 < ranNum && ranNum <= 75)
        @leftDirection = true
      else
        @rightDirection = true
      end
    @moveCounter = 0 #reset moveCounter
    end


    # Checking collision before moving
    self.checkCollision(player, map, items, npcs, monsters)

    # If no collison is detected, then move monster
    if(@collisionOn == false)
      if(self.upDirection == true)
        @worldY -= @speed
      elsif(self.downDirection == true)
        @worldY += @speed
      elsif(self.leftDirection == true)
        @worldX -= @speed
      elsif(self.rightDirection == true)
        @worldX += @speed
      end
    end

  end

end


