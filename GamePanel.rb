require 'ruby2d'
require_relative 'Character_Class/Player'
require_relative 'KeyHandler'
require_relative 'GameMap'
require_relative 'CommonParameter'
require_relative 'Character_Class/Monster'
require_relative 'Character_Class/Bat'
require_relative 'Character_Class/Skeleton'
require_relative 'FindingPath/Node'
require_relative 'FindingPath/PathFinder'
require_relative 'Character_Class/Warrior'
require_relative 'Item_Class/Chest'
require_relative 'Item_Class/Loot_item'
require_relative 'Character_Class/Minotaur'


include CCHECK

@isSwitched = false

#1. Create objects in the game
#------------------------- 1.1. Map Section --------------------------------
map = GameMap.new()

#------------------------- 1.2. Player Section --------------------------------
player = Player.new(1*CP::TILE_SIZE, 1*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE)

#------------------------- 1.3. Monsters Section --------------------------------
monsters = [
            Minotaur.new(24*CP::TILE_SIZE, 27*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Skeleton.new(30*CP::TILE_SIZE, 6*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Skeleton.new(39*CP::TILE_SIZE, 12*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Skeleton.new(1*CP::TILE_SIZE, 37*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Skeleton.new(11*CP::TILE_SIZE, 36*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Skeleton.new(36*CP::TILE_SIZE, 28*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Bat.new(16*CP::TILE_SIZE, 0*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Bat.new(1*CP::TILE_SIZE, 13*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Bat.new(1*CP::TILE_SIZE, 33*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Bat.new(3*CP::TILE_SIZE, 31*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Bat.new(35*CP::TILE_SIZE, 20*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player),
            Bat.new(32*CP::TILE_SIZE, 36*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE, player)
           ]

#------------------------- 1.4. NPCs Section --------------------------------
npcs = [
          Warrior.new(CP::TILE_SIZE * 3, CP::TILE_SIZE * 4, CP::TILE_SIZE, CP::TILE_SIZE)

       ]

#------------------------- 1.5. Items Section --------------------------------
insideChest = Meat.new
insideChest2 = RottedItem.new
items = [
          Chest.new(CP::TILE_SIZE * 6, CP::TILE_SIZE * 4, insideChest),
          Chest.new(CP::TILE_SIZE * 3, CP::TILE_SIZE * 13, insideChest2),
          Chest.new(CP::TILE_SIZE * 6, CP::TILE_SIZE * 38, insideChest),
          Chest.new(CP::TILE_SIZE * 30, CP::TILE_SIZE * 36, insideChest),
          Chest.new(CP::TILE_SIZE * 35, CP::TILE_SIZE * 3, insideChest)
        ]


#------------------------- 1.6. Text Section --------------------------------
text = Text.new(
  '',
  x: 0, y: 0,
  #font: 'vera.ttf',
  style: 'bold',
  size: 20,
  color: 'white',
  #rotate: 90,
  #z: 10
)

text1 = Text.new(
  '',
  x: 465, y: 0,
  #font: 'vera.ttf',
  style: 'bold',
  size: 20,
  color: 'white',
  #rotate: 90,
  #z: 10
)

text2 = Text.new(
  '',
  x: 465, y: 30,
  #font: 'vera.ttf',
  style: 'bold',
  size: 20,
  color: 'white',
  #rotate: 90,
  #z: 10
)

text_Win = Text.new(
  'VICTORY!!!',
  x: CP::SCREEN_WIDTH / 2 - 180,
  y: CP::SCREEN_HEIGHT / 2 - 80,
  style: 'bold',
  size: 72,
  color: 'white',
)
text_Win.remove

text_Loose = Text.new(
  'GAME OVER!',
  x: CP::SCREEN_WIDTH / 2 - 220,
  y: CP::SCREEN_HEIGHT / 2 - 80,
  style: 'bold',
  size: 72,
  color: 'white',
)
text_Loose.remove



#2. Include necessary tools
#------------------------------------ 2.1. Get user's input -------------------------
get_key_input(player, items, npcs, monsters)
#------------------------------------ 2.2. Audio/Sound ------------------------------
music = Music.new('Sound/Dungeon.wav')
music.loop = true
music.play

#---------------------------------------Check monster alive helper------------------------------------------
def isAllMonsterDead(monsters)
  monsters.each do |monster|
    if monster.exist == true
      return false
    end
  end
  return true
end

#3. Core of 2D game
#------------------------------------------------------- Game Loop ------------------------------------------
update do
  if (!player.healthBar.isDead? && !isAllMonsterDead(monsters))
    #1. Update Player
    player.updatePlayer(monsters, map, npcs, items)

    #2. Update Monsters
    for i in 0..(monsters.length - 1)
      monsters[i].updateMonster(player, map, items, npcs, monsters)
    end

    #3. Update Texts
    text.text = "Hero Coordinate: #{player.worldX}   #{player.worldY} "
    text1.text = "Minotaur Coordinate: #{monsters[0].worldX}   #{monsters[0].worldY}"
    currentNumberOfMonsters = 0
    for i in 0..(monsters.length - 1)
      if(monsters[i].exist == true)
        currentNumberOfMonsters = currentNumberOfMonsters + 1
      end
    end
    text2.text = "Total Monsters: #{currentNumberOfMonsters} / #{monsters.length }"

    #4. Update NPCs
    current_interacting_npc = -1
    for i in 0..(npcs.length - 1)
      npcs[i].updateNPC(player, map, i)
      if player.talktoNpc != -1
        current_interacting_npc = player.talktoNpc
      end
    end
    # Restore the interaction state after processing all items
    player.talktoNpc = -current_interacting_npc
    #5. Update Items in map and preserve player.interacting
    current_interacting_chest = -1
    for i in 0..(items.length - 1)
      items[i].updateChest(player, i)
      if player.interacting != -1
        current_interacting_chest = player.interacting
      end
    end
    # Restore the interaction state after processing all items
    player.interacting = current_interacting_chest
    #6. Update Map
    map.updateMap(player)
  else
    case player.healthBar.isDead?
    when true
      if !@isSwitched
        Window.clear
        @isSwitched = true
        text_Loose.add
      end
    when false
      if !@isSwitched
        Window.clear
        @isSwitched = true
        text_Win.add
      end
    end
  end
end


#------------------------------------------------------- Set up window ---------------------------------------
#Setting Window
set width: CP::SCREEN_WIDTH
set height: CP::SCREEN_HEIGHT
set title: "Simulating Hero's Adventure (RPG GAME) with Ruby "
set resizable: true
set background: 'black'
#set fullscreen: true


#------------------------------------------------------- Show window ---------------------------------------
show
