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
      'Image/Bat_full.png', #768 * 320 :: (64)*64
      x: @worldX - player.worldX + player.x,
      y: @worldY - player.worldY + player.y,
      width: -width*2.5, height: height*2.5, #
      # clip_width: width_Of('Image/cropskeleton.png') / 10,
      # clip_height: height_Of('Image/cropskeleton.png'),
      animations: {
        walk:
        [
           {
             x: 64*0, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*1, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*2, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*3, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*4, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*5, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*6, y: 64*4,
             width: 64, height: 64,
             time: 100
           },

           {
             x: 64*7, y: 64*4,
             width: 64, height: 64,
             time: 100
           }
         ],

        attackFirst:[
           {
             x: 64*0, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

           {
             x: 64*1, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

           {
             x: 64*2, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

           {
             x: 64*3, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

           {
             x: 64*4, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

           {
             x: 64*5, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

        ],
        attackSecond:[
          {
             x: 64*6, y: 64*0,
             width: 64, height: 64,
             time: 50
           },

           {
             x: 64*7, y: 64*0,
             width: 64, height: 64,
             time: 50
           }
        ],

        idle: [
          {
             x: 64*0, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*1, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*2, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*3, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*4, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*5, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*6, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*7, y: 64*3,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*8, y: 64*3,
             width: 64, height: 64,
             time: 50
          }
         ],

        hurt: [
          {
             x: 64*0, y: 64*2,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*1, y: 64*2,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*2, y: 64*2,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*3, y: 64*2,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*4, y: 64*2,
             width: 64, height: 64,
             time: 50
          }
         ],

        death: [
          {
             x: 64*0, y: 64*1,
             width: 64, height: 64,
             time: 50
          },
          
          {
             x: 64*1, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*2, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*3, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*4, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*5, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*6, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*7, y: 64*1,
             width: 64, height: 64,
             time: 50
          },

          {
             x: 64*8, y: 64*1,
             width: 64, height: 64,
             time: 50
          }
         ]
       }
    )
    @image.play(animation: :idle, loop: true)
    @deltax = 85
    @deltay = -35

    #2. Health Bar
    @healthBar = HealthBar.new(100, 100, -999, -999, 48)

    #3. Speed
    @speed = 2

    #3.1. Attack
    @attack = 20 #balancing attack damage for skeleton

    #4. This will be convenient for random move function
    @moveCounter = 0
    @canmove = true


    @test = false
  end
  

#-------------------------------- Override Methods -----------------------------------------
def updateMonster(player, map, items, npcs, monsters)  
  if(@exist == true)
    if @healthBar.isDead?
      @exist = false
    end
    self.DrawMonster(player)
    self.DrawHealthBar(player)
    self.checkCollision(player, map, items, npcs, monsters)
    if @onAttackBox && @canmove
      # Checking collision before attacking      
      @canmove = false
      if @hitBox.x >= CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2)
        @image.play(animation: :attackFirst, flip: :horizontal) do
          if @onAttackBox
            self.attackTarget(player)
          end
          @image.play(animation: :attackSecond, flip: :horizontal) do
            @canmove = true
          end
        end
      else
        @image.play(animation: :attackFirst) do
          if @onAttackBox
            self.attackTarget(player)
          end
          @image.play(animation: :attackSecond) do
            @canmove = true
          end
        end
      end
    else
      if @canmove
        self.randMove(player, map, items, npcs, monsters)
      end
    end
    # self.moveForwardTo((player.worldY + player.solidArea.y) / CP::TILE_SIZE, (player.worldX + player.solidArea.x) / CP::TILE_SIZE, 
    #                     player, map, pFinder, items, npcs, monsters)

    
    # Check if collision with player then attack at right time
  else
    if @existFlag
      @image.play(animation: :death) do      
        removeMonster
      end
    end
    @canmove = false
    @existFlag = false
    self.DrawMonster(player)
    self.DrawHealthBar(player)
  end
end


#------------------------------ Random Move ---------------------------------------------------
  def randMove(player, map, items, npcs, monsters)

    @moveCounter = @moveCounter + 1
    # generate a random number after every 120 steps
    if(@moveCounter == 100)
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
      @image.play(animation: :idle)
    end
  end


end
