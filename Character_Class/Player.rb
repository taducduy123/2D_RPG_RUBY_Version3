require 'ruby2d'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../Item_Class/Player_Inventory'


require_relative 'HealthBar'
require_relative 'MagicBar'
include CCHECK




class Player
  attr_reader :x, :y,
              :worldX, :worldY,
              :speed,
              :collision_with_monster_index
              :collision_with_npc_index
              :collision_with_item_index
              :attack

  attr_accessor :upDirection, :downDirection, :leftDirection, :rightDirection,
                :solidArea,
                :collisionOn,
                :myInventory,
                :interacting,
                :talktoNpc,
                :healthBar,
                :magicBar,
                :hitBox


  def initialize(worldX, worldY, width, height)

    #1. Image and Animation
    @image = Sprite.new(
      'Image/Player.png',
      x: CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - 25, # (768/2) - (48/2) = 360
      y: CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) - 20, # (576/2) - (48/2) = 264
      z: 2,                                                            #Precedence of show
      width: width*2, height: height*2,
      animations: {
        static: [
          {
            x: 0, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 192, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 384, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 576, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 768, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 960, y: 0,
            width: 192, height: 192,
            time: 100
          }
        ],

        walk: [
          {
            x: 0, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 192, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 384, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 576, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 768, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 960, y: 192,
            width: 192, height: 192,
            time: 100
          }
        ],

        attackSideFirst: [
          {
            x: 0, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 384, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 576, y: 192*2,
            width: 192, height: 192,
            time: 50
          },
        ],

        attackSideSecond: [
          {
            x: 768, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 960, y: 192*2,
            width: 192, height: 192,
            time: 50
          },
        ],

        attackSpecial: [
          {
            x: 192, y: 192*4,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192*2, y: 192*4,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192*3, y: 192*4,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192*3, y: 192*6,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192*4, y: 192*6,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192*5, y: 192*6,
            width: 192, height: 192,
            time: 50
          }
        ]
      }

    )
    @image.play(animation: :static, loop: true)

    #2. World Coordinate
    @worldX = worldX
    @worldY = worldY

    #3. Screen Coordinate
    @x =  CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2)
    @y = CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2)

    #4. Speed
    @speed = 3

    #5. Attack damage
    @attack = 25

    #6. Health Bar
    @healthBar = HealthBar.new(
      200,
      200,
      CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3),
      CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) - 10,
      100
    )
    @healthBar.heart.x = CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3) - 15

    #7. MP Bar
    @magicBar = MagicBar.new(
      100,
      100,
      CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3),
      CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) - 10 - 11,
      100
    )
    @magicBar.mana.x = CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3) - 15


    #8. Direction and Facing
    @facing = 'right'
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false


    #9. Solid Area to check collision with other objects
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )

    #10. Hit box
    @hitBox = Rectangle.new(
      x: @x + @solidArea.x,
      y: @y + @solidArea.y,            # Position
      width: 32, height: 32,  # Size
      opacity: 1
    )

    #11. State of Collision
    @collisionOn = false                            # Whenever player collides any objects (NPCs, Items, Monsters), this will turn true, otherwise false.
    @collision_with_monster_index = -1              # When collision with Monster. The collided Monster is identified by array index
    @collision_with_npc_index = -1                  # When collision with NPC. The collided NPC is identified by array index
    @collision_with_item_index = -1                 # When collision with Item. The collided Item is identified by array index

    #12. State of interaction
    @interacting = -1
    @talktoNpc

    #13. Inventory
    @myInventory = Inventory.new()

    #14. Attack boxes
    @attackBoxRight = Rectangle.new(
      x: 360+48-15, y: 264-48+40,
      width: 40 , height: 50+10,
      opacity: 0
    )

    @attackBoxLeft = Rectangle.new(
      x: 360-48 + 15 + 10, y: 264-48+40,
      width: 40, height: 50+10,
      opacity: 0
    )

    @attackBoxSpecial = Rectangle.new(
      x: 360-10, y: 264-10,
      width: 70, height: 80,
      opacity: 0
    )

  end


#-------------------------------- Very Usefull Methods -----------------------------------------

  def checkCollision(monsters, map, items, npcs)

    @collisionOn = false
    @collision_with_monster_index = -1
    @collision_with_npc_index = -1
    @collision_with_item_index = -1

    #1. Check if player collides any wall
    CCHECK.checkTile(self, map)

    #2. Check if player collides any Monster
    @collision_with_monster_index = CCHECK.checkEntity_Collide_AllTargets(self, monsters)

    #3. Check if monster collides any Item in the map
    @collision_with_item_index = CCHECK.checkEntity_Collide_AllTargets(self, items)

    #4. Check if player collides any NPC in the map
    @collision_with_npc_index = CCHECK.checkEntity_Collide_AllTargets(self, npcs)

  end


#-------------------------------- Update -----------------------------------------
  def updatePlayer(monsters, map, npcs, items)

    #1. Update Health bar
    self.healthBar.update()
    #2. Update Magic bar
    self.magicBar.update()
    #3. Move
    self.move(monsters, map, npcs, items)

  end



#-------------------------------- Move -----------------------------------------
  def move(monsters, map, npcs, items)

    #Check Collision before moving
    checkCollision(monsters, map, items, npcs)

    #If no collision is detected, then let player move
    if(@collisionOn == false)
      if(self.upDirection == true)
        @worldY -= @speed
      end
      if(self.downDirection == true)
        @worldY += @speed
      end
      if(self.leftDirection == true)
        @worldX -= @speed
      end
      if(self.rightDirection == true)
        @worldX += @speed
      end
    end
  end


#-------------------------------- Attack and Special Skills -----------------------------------------

  def attackInBox(monsters)

    case @facing
    when 'right'
      @image.play(animation: :attackSideFirst) do
        monsters.each do |monster|
          if CCHECK.intersect(@attackBoxRight.x,@attackBoxRight.y,@attackBoxRight.width,@attackBoxRight.height,
            monster.hitBox.x,monster.hitBox.y,monster.hitBox.width,monster.hitBox.height)
            monster.beAttacked(@attack)
            if monster.is_a?(Skeleton) && monster.exist
              monster.canmove = false
              monster.image.play(animation: :hurt) do
                monster.canmove = true
              end
            end
          end
        end
        @image.play(animation: :attackSideSecond) do
          self.stop
        end
      end
    when 'left'
      @image.play(animation: :attackSideFirst, flip: :horizontal) do
        monsters.each do |monster|
          if CCHECK.intersect(@attackBoxLeft.x,@attackBoxLeft.y,@attackBoxLeft.width,@attackBoxLeft.height,
            monster.hitBox.x,monster.hitBox.y,monster.hitBox.width,monster.hitBox.height)
            monster.beAttacked(@attack)
            if monster.is_a?(Skeleton) && monster.exist
              monster.canmove = false
              monster.image.play(animation: :hurt) do
                monster.canmove = true
              end
            end
          end
        end
        @image.play(animation: :attackSideSecond, flip: :horizontal) do
          self.stop()
        end
      end
    end
  end

  def attackSpecial(monsters)
    if @magicBar.canUseSkill?
      @image.play(animation: :attackSpecial) do
        monsters.each do |monster|
          if CCHECK.intersect(@attackBoxSpecial.x,@attackBoxSpecial.y,@attackBoxSpecial.width,@attackBoxSpecial.height,
            monster.hitBox.x,monster.hitBox.y,monster.hitBox.width,monster.hitBox.height)
            monster.beAttacked(@attack*2.5)
            if monster.is_a?(Skeleton) && monster.exist
              monster.canmove = false
              monster.image.play(animation: :hurt) do
                monster.canmove = true
              end
            end
          end
        end
        @magicBar.useSpecialskill
        self.stop()
      end
    end
  end

  def beAttacked(ammounts)
    @healthBar.hp -= ammounts
  end

#-------------------------------- Animation Section -----------------------------------------

  def runAnimation()
    case @facing
    when 'right'
      if @leftDirection
        @facing = 'left'
        @image.play animation: :walk, loop: true, flip: :horizontal
      else
        @image.play(animation: :walk)
      end
    when 'left'
      if @rightDirection
        @image.play(animation: :walk)
        @facing = 'right'
      else
        @image.play animation: :walk, loop: true, flip: :horizontal
      end
    end
  end

#-------------------------------- Stop Moving -----------------------------------------

  def stop()
    case @facing
    when 'right'
      @image.play(animation: :static, loop: true)
    when 'left'
      @image.play(animation: :static, loop: true, flip: :horizontal)
    end
  end

#------------Use item
def useItem()
  puts "Access my_inventory at #{myInventory.cursor_y} #{myInventory.cursor_x}"
  if myInventory.my_inventory[myInventory.cursor_y][myInventory.cursor_x]
    @healthBar.hp = @healthBar.hp + myInventory.my_inventory[myInventory.cursor_y][myInventory.cursor_x].effect
    myInventory.removeItem(myInventory.cursor_y, myInventory.cursor_x)
    @healthBar.update
  end
end

end
