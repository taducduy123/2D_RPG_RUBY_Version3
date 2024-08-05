require 'ruby2d'
require_relative 'HealthBar'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative 'Monster'
include CCHECK

class Minotaur < Monster
  def initialize(wordlX, worldY, width, height, player)
    super(wordlX, worldY, width, height)

    #1. Image and Animation
    @image = Sprite.new(
      'Image/Minotaur.png',
      x: @worldX - player.worldX + player.x,
      y: @worldY - player.worldY + player.y,
      width: width, height: height,
      # clip_width: width_Of('Image/cropskeleton.png') / 10,
      # clip_height: height_Of('Image/cropskeleton.png'),
      animations: {
        walk:
        [
           {
             x: 0, y: 0,
             width: 56, height: 49,
             time: 50, flip: :none
           },
           {
             x: 56, y: 0,
             width: 56, height: 49,
             time: 50, flip: :none
           },
           {
             x: 112, y: 0,
             width: 64, height: 49,
             time: 50, flip: :none
           },
           {
             x: 176, y: 0,
             width: 48, height: 49,
             time: 50, flip: :none
           },
           {
             x: 224, y: 0,
             width: 64, height: 49,
             time: 50, flip: :none
           },
           {
             x: 288, y: 0,
             width: 56, height: 49,
             time: 50, flip: :none
           },
           {
             x: 344, y: 0,
             width: 48, height: 49,
             time: 50, flip: :none
           },
           {
             x: 392, y: 0,
             width: 56, height: 49,
             time: 50, flip: :none
           }
         ]

       },
    )
    @image.play

    #2. Health Bar
    @healthBar = HealthBar.new(100, 100, -999, -999, 48)

    #3. Speed
    @speed = 1

    #3.1. Attack
    @attack = 25

    #4. Tool for finding the shortest path
    @pFinder = PathFinder.new()
    @showPathOn = true       #This is usefull for debuging. If you don't want show the shortest path, turn @showPathOn = false. Otherwise, true
    @path = []

    #This is used to find the shortest path
    #(if you want stop monster pursue you, let change @onPath = false)
    @onPath = false

    #5. This is used to determine when the monster gets aggro
    @aggro = false
    @speedUpTime = 0              #To calculate the time monster should speed up when it gets aggro
    @sppedUpFlag = true          #To determind when speed up, when slow down

    #6. This will be convenient for random move function
    @moveCounter = 0

    @attackDelay = 0

  end
  

#-------------------------------- Override Methods -----------------------------------------
  def updateMonster(player, map, items, npcs, monsters)
    if(@exist == true)

      #I. Show monster's related components
      self.DrawMonster(player)
      self.DrawHealthBar(player)

      #II. Define how monster moves and what speed should be:
      #When monster gets aggro, then pursue player. Otherwise, random move. Also, for each time monster gets aggro, 
      #the monster speeds up within first 120 steps,then it slows down 
      self.setAggro(player)
      self.resetPath
      if(@aggro == true)
        @speedUpTime = @speedUpTime + 1
        if(@speedUpFlag == true && @speedUpTime < 120)       
           @speed = 3                                      # <------------- monster speeds up when getting aggro
        else
          if(@speedUpFlag == true)
            @speedUpFlag = false
          end
          @speedUpTime = 0
          @speed = 1                                       # <------------- monster slows down
        end                                               
        self.moveForwardTo((player.worldY + player.solidArea.y) / CP::TILE_SIZE, (player.worldX + player.solidArea.x) / CP::TILE_SIZE,
                            player, map, items, npcs, monsters)
        self.showPath(player)
      else
        @speedUpFlag = true
        @speed = 1                                         # <------------- if monster does not get aggro, then its speed return origin
        @speedUpTime = 0                                           
        self.randMove(player, map, items, npcs, monsters)
      end   

      #III. Check if monster is dead or not then set @exist to corresponding statement
      if @healthBar.isDead?
        @exist = false
      end

      #IV. Attack the player
      # Check if collision with player then attack at right time
      if @onAttackBox
        if @attackDelay >= 20
          self.attackTarget(player)
          @attackDelay = 0
        end
        @attackDelay += 1
      end

    else
      self.resetPath
      self.removeMonster              #remove monster died
      @existFlag = true
    end
  end


 #------------------------------------ Define when monster get aggro, and pursue player
 def setAggro(player)
  @aggro = false

  #Distance between monster and player
  distanceX = (@worldX - player.worldX).abs
  distanceY = (@worldY - player.worldY).abs
  tileDistance  = (distanceX + distanceY) / CP::TILE_SIZE

  if(tileDistance <= 5)
    @aggro = true
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

  # If no collision is detected, then move the monster
  if(@collisionOn == false)
    if(self.upDirection == true)
      @worldY -= @speed
      self.runAnimation
    elsif(self.downDirection == true)
      @worldY += @speed
      self.runAnimationLeft
    elsif(self.leftDirection == true)
      @worldX -= @speed
      self.runAnimationLeft
    elsif(self.rightDirection == true)
      @worldX += @speed
      self.runAnimation
    end
  else
    self.stopAnimation
  end
end


#--------------------------------------- Target Move -----------------------------------------
def moveForwardTo(goalRow, goalCol, player, map, items, npcs, monsters)
  @upDirection = false
  @downDirection = false
  @leftDirection = false
  @rightDirection = false

  #Search path
  self.searchPath(goalRow, goalCol, player, map, items, npcs, monsters)

  #if path found
  if(@onPath == true)

    # Checking collision before moving
    self.checkCollision(player, map, items, npcs, monsters)

    # If no collision is detected, then move the monster
    if(@collisionOn == false)
      if(self.upDirection == true)
        @worldY -= @speed
        self.runAnimation
      elsif(self.downDirection == true)
        @worldY += @speed
        self.runAnimationLeft
      elsif(self.leftDirection == true)
        @worldX -= @speed
        self.runAnimationLeft
      elsif(self.rightDirection == true)
        @worldX += @speed
        self.runAnimation
      end
    else
      self.stopAnimation
    end
  end
end


#---------------------------- Let monster follow the selected shortest path -----------------------------
# This function changes @onPath = true whenever there exists a path. Also, this function navigate the
# monster so that the monster follows the found path.
def searchPath(goalRow, goalCol, player, map, items, npcs, monsters)
  startRow = (@worldY + @solidArea.y) / CP::TILE_SIZE
  startCol = (@worldX + @solidArea.x) / CP::TILE_SIZE

  # Convert data of map into data of graph
  @pFinder.setNodes(startRow, startCol, goalRow, goalCol, map)

  if (@pFinder.search() == true)       # if found path
    @onPath = true

    # next worldX and worldY
    nextX = @pFinder.pathList[0].col * CP::TILE_SIZE
    nextY = @pFinder.pathList[0].row * CP::TILE_SIZE

    # Entity's solid area
    enLeftX   = @worldX + @solidArea.x
    enRightX  = @worldX + @solidArea.x + @solidArea.width
    enTopY    = @worldY + @solidArea.y
    enBottomY = @worldY + @solidArea.y + @solidArea.height

    # Navigate monster
    if(enTopY > nextY && enLeftX >= nextX && enRightX < nextX + CP::TILE_SIZE)
      @upDirection = true
    elsif(enTopY < nextY && enLeftX >= nextX && enRightX < nextX + CP::TILE_SIZE)
      @downDirection = true
    elsif(enTopY >= nextY && enBottomY < nextY + CP::TILE_SIZE)
      # should go left or go right ?
      if(enLeftX > nextX)
        @leftDirection = true
      end
      if(enLeftX < nextX)
        @rightDirection = true
      end
    elsif(enTopY > nextY && enLeftX > nextX)
      # should go up or go left ?
      @upDirection = true                     # <<<<<<------------------------------------------- carefull
      self.checkCollision(player, map, items, npcs, monsters)
      if(@collisionOn == true)
        @leftDirection = true
        @upDirection = false
      end
    elsif(enTopY > nextY && enLeftX < nextX)
      # should go up or go right ?
      @upDirection = true                     # <<<<<<------------------------------------------- carefull
      self.checkCollision(player, map, items, npcs, monsters)
      if(@collisionOn == true)
        @rightDirection = true
        @upDirection = false
      end
    elsif(enTopY < nextY && enLeftX > nextX)
      # should go down or go left ?
      @downDirection = true                   # <<<<<<------------------------------------------- carefull
      self.checkCollision(player, map, items, npcs, monsters)
      if(@collisionOn == true)
        @leftDirection = true
        @downDirection = false
      end
    elsif(enTopY < nextY && enLeftX < nextX)
      # should go down or go right ?
      @downDirection = true                   # <<<<<<------------------------------------------- carefull
      self.checkCollision(player, map, items, npcs, monsters)
      if(@collisionOn == true)
        @rightDirection = true
        @downDirection = false
      end
    end

    # #Stop when catching the goal
    # nextRow = @pFinder.pathList[0].row
    # nextCol = @pFinder.pathList[0].col
    # if(nextRow == goalRow && nextCol == goalCol)
    #   @onPath = false
    # end
  end
end


def showPath(player)
  if(@exist == true)
    if (@showPathOn == true)
        for i in 0..(@pFinder.pathList.length - 1)

            # World Coordinate of path[i]
            worldX = @pFinder.pathList[i].col * CP::TILE_SIZE
            worldY = @pFinder.pathList[i].row * CP::TILE_SIZE

            # Screen Coordinate of path[i] should be
            screenX = worldX - player.worldX + player.x
            screenY = worldY - player.worldY + player.y

            #World Coordinate of Camera
            cameraWorldX = player.worldX - player.x
            cameraWorldY = player.worldY - player.y

            # Rendering game by removing unnessary images (we keep images in camera's scope, and remove otherwise)
            if(CCHECK.intersect(cameraWorldX, cameraWorldY, CP::SCREEN_WIDTH, CP::SCREEN_HEIGHT,
                                worldX, worldY, CP::TILE_SIZE, CP::TILE_SIZE) == true)  #Notice we want the dimension of camera is exactly same as our window
                if(@path != nil)
                  @path.push(Rectangle.new(x: screenX,
                                        y: screenY,
                                        width: CP::TILE_SIZE,
                                        height: CP::TILE_SIZE,
                                        color: 'red',
                                        z: -1,
                                        opacity: 0.5
                                        )
                            )
                end
            end
        end
    end
  end
end


def resetPath
  if(@showPathOn == true)
    for i in 0..(@path.length - 1)
      @path[i].remove
    end
    @path.clear
  end
end



end
