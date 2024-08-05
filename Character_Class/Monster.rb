require 'ruby2d'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../FindingPath/Node'
require_relative '../FindingPath/PathFinder'

include CCHECK



class Monster 
  attr_reader :x, :y,
              :worldX, :worldY,
              :speed,
              :moveCounter,
              :deltax,
              :deltay,
              :canmove

  attr_writer :canmove

  attr_accessor :upDirection, :downDirection, :leftDirection, :rightDirection,
                :solidArea,
                :collisionOn,
                :collisionPlayerOn,
                :image,
                :onPath,
                :exist,
                :hitBox,
                :healthBar

  def initialize(worldX, worldY, width, height)

    #1. Image and Animation
    @image = nil
    @deltax = 0
    @deltay = 0

    #2. Health Bar
    @healthBar = nil

    #3. Speed
    @speed = nil
    @canmove = nil

    #3.1. Attack
    @attack = nil

    #4. Direction and Facing
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false

    # #5.  Screen Coordinate
    # @x = nil
    # @y = nil

    #5. World Coordinate
    @worldX = worldX
    @worldY = worldY

    #6. Solid Area to check collision with other objects
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )

    #7. Hit Boxes
    @hitBox = Rectangle.new(
      x: 8 , y: 16,
      width: 32, height: 32,
      opacity: 0.5
    )

    @attackBox = Rectangle.new(
      x: 18, y: 16,
      width: 62, height: 62,
      opacity:0.5,
      color: 'green'
    )

    #8. State of Collision
    @collisionOn = false
    @collisionPlayerOn = false             #Check if monster collides player
    @onAttackBox = false                   #Check if player is in attack box of monster

    #9. Existence of monster
    @exist = true
    @existFlag = true

  end




#-------------------------------- Very Usefull Methods -----------------------------------------
  #1.
  def DrawMonster(player)
    # Screen Coordinate of monster should be
    screenX = @worldX - player.worldX + player.x
    screenY = @worldY - player.worldY + player.y


    hitBox_screenX = screenX + @solidArea.x 
    hitBox_screenY = screenY + @solidArea.y

    attackBox_screenX = screenX + @solidArea.x - 15
    attackBox_screenY = screenY + @solidArea.y - 15


    #World Coordinate of Camera
    cameraWorldX = player.worldX - player.x
    cameraWorldY = player.worldY - player.y

    # Rendering game by removing unnessary images (we keep images in camera's scope, and remove otherwise)
    if(CCHECK.intersect(cameraWorldX, cameraWorldY, CP::SCREEN_WIDTH, CP::SCREEN_HEIGHT,
                        worldX, worldY, CP::TILE_SIZE, CP::TILE_SIZE) == true)  #Notice we want the dimension of camera is exactly same as our window
      @image.x = screenX + @deltax
      @image.y = screenY + @deltay
      @image.add

      @hitBox.x = hitBox_screenX
      @hitBox.y = hitBox_screenY
      @hitBox.add

      @attackBox.x = attackBox_screenX
      @attackBox.y = attackBox_screenY
      @attackBox.add
    else
      @image.remove
      @hitBox.remove
      @attackBox.remove
    end
  end

  #2.
  def DrawHealthBar(player)
    # Update the health bar
    @healthBar.update()

    # Screen Coordinate of Health Bar should be
    screenX = @worldX - player.worldX + player.x
    screenY = @worldY - player.worldY + player.y - (2/3* CP::TILE_SIZE + 9)

    #World Coordinate of Camera
    cameraWorldX = player.worldX - player.x
    cameraWorldY = player.worldY - player.y

    # Rendering game by removing unnessary images (we keep images in camera's scope, and remove otherwise)
    if(CCHECK.intersect(cameraWorldX, cameraWorldY, CP::SCREEN_WIDTH, CP::SCREEN_HEIGHT,
                        worldX, worldY, CP::TILE_SIZE, CP::TILE_SIZE) == true)  #Notice we want the dimension of camera is exactly same as our window
        @healthBar.heart.x = screenX - 15
        @healthBar.heart.y = screenY
        @healthBar.rec1.x =  screenX
        @healthBar.rec1.y =  screenY
        @healthBar.rec2.x =  @healthBar.rec1.x + 2
        @healthBar.rec2.y =  @healthBar.rec1.y + 2

        # If within the scope of camera, then add health bar to our screen
        @healthBar.heart.add
        @healthBar.rec1.add
        @healthBar.rec2.add
    else # remove otherwise
        @healthBar.heart.remove
        @healthBar.rec1.remove
        @healthBar.rec2.remove
    end
  end

  #3.
  def removeMonster()
      @exist = false
      @healthBar.move(-900,-900)
      @hitBox.x = -900
      @hitBox.y = -900

      @attackBox.x = -900
      @attackBox.y =-900


      @image.x = -900
      @image.y = -900

      @worldX = -900
      @worldY = -900
  end

  #4.
  def runAnimation
    @image.play animation: :walk
  end

  #5.
  def runAnimationLeft
    @image.play animation: :walk, flip: :horizontal
  end

  #6.
  def stopAnimation
    @image.stop
  end


  #7.
  def checkCollision(player, map, items, npcs, monsters)
    @collisionOn = false

    #1. Check if monster collides any wall
    CCHECK.checkTile(self, map)

    #2. Check if monster collides Player
    if (CCHECK.checkEntity_Collide_SingleTarget(self, player) == true)
      @collisionPlayerOn = true
    else
      @collisionPlayerOn = false
    end

    if CCHECK.intersect(player.hitBox.x, player.hitBox.y, player.hitBox.width, player.hitBox.height,
                        @attackBox.x, @attackBox.y, @attackBox.width, @attackBox.height)
      @onAttackBox = true
    else
      @onAttackBox = false
    end
    
    #3. Check if monster collides any Item in the map
    for i in 0..(items.length - 1)
      CCHECK.checkEntity_Collide_SingleTarget(self, items[i])
    end

    #4. Check if monster collides any NPC in the map
    for i in 0..(npcs.length - 1)
      CCHECK.checkEntity_Collide_SingleTarget(self, npcs[i])
    end

    #5. Check if monster collides any other monsters
    CCHECK.checkMonster_Collide_OtherMonsters(self, monsters)
  end

  #8.
  def beAttacked(ammounts)
    @healthBar.hp -= ammounts
  end
  #9.
  def attackTarget(player)
    player.healthBar.hp -= @attack
  end
  
end
