require 'ruby2d'
require_relative 'CommonParameter'
#require_relative 'GameMap'

module CCHECK

#---------------------------- Check if two rectangles intersect to each other -----------------------------------------
  def intersect(x1, y1, object1_width, object1_height, x2, y2, object2_width, object2_height)
    if (x1 + object1_width >= x2 && x1 <= x2 + object2_width &&
        y1 + object1_height >= y2 && y1 <= y2 + object2_height)
      return true
    end
    return false
  end


#---------------------------- Check if entity collides wall -----------------------------------------
  def checkTile(entity, map)
    entityLeftWorldX = entity.worldX + entity.solidArea.x
    entityRightWorldX = entity.worldX + entity.solidArea.x + entity.solidArea.width
    entityTopWorldY = entity.worldY + entity.solidArea.y
    entityBottomWorldY = entity.worldY + entity.solidArea.y + entity.solidArea.height

    entityLeftCol = entityLeftWorldX / CP::TILE_SIZE
    entityRightCol = entityRightWorldX / CP::TILE_SIZE
    entityTopRow = entityTopWorldY / CP::TILE_SIZE
    entityBottomRow = entityBottomWorldY / CP::TILE_SIZE

    tileNum1 = nil
    tileNum2 = nil

    if entity.upDirection == true
      entityTopRow = (entityTopWorldY - entity.speed) / CP::TILE_SIZE
      if(entityTopRow < 0)                                        # Check map boundary
        entity.collisionOn = true
      else
        tileNum1 = map.tileManager[entityTopRow][entityLeftCol]
        tileNum2 = map.tileManager[entityTopRow][entityRightCol]
        if(map.tile[tileNum1].isSolid == true || map.tile[tileNum2].isSolid == true)
            entity.collisionOn = true
        end
      end


    elsif entity.downDirection == true
      entityBottomRow = (entityBottomWorldY + entity.speed) / CP::TILE_SIZE
      if(entityBottomRow > CP::MAX_WORLD_ROWS - 1)                # Check map boundary
        entity.collisionOn = true
      else
        tileNum1 = map.tileManager[entityBottomRow][entityLeftCol]
        tileNum2 = map.tileManager[entityBottomRow][entityRightCol]
        if(map.tile[tileNum1].isSolid == true || map.tile[tileNum2].isSolid == true)
            entity.collisionOn = true
        end
      end


    elsif entity.leftDirection == true
      entityLeftCol = (entityLeftWorldX - entity.speed) / CP::TILE_SIZE
      if(entityLeftCol < 0)                                       # Check map boundary
        entity.collisionOn = true
      else
        tileNum1 = map.tileManager[entityTopRow][entityLeftCol]
        tileNum2 = map.tileManager[entityBottomRow][entityLeftCol]
        if(map.tile[tileNum1].isSolid == true || map.tile[tileNum2].isSolid == true)
            entity.collisionOn = true
        end
      end


    elsif entity.rightDirection == true
      entityRightCol = (entityRightWorldX + entity.speed) / CP::TILE_SIZE
      if(entityRightCol > CP::MAX_WORLD_COLS - 1)                 # Check map boundary
        entity.collisionOn = true
      else
        tileNum1 = map.tileManager[entityTopRow][entityRightCol]
        tileNum2 = map.tileManager[entityBottomRow][entityRightCol]
        if(map.tile[tileNum1].isSolid == true || map.tile[tileNum2].isSolid == true)
            entity.collisionOn = true
        end
      end
    end
  end




#------------------------------------ Check entity collide a single target --------------------------------
  def checkEntity_Collide_SingleTarget(entity, target)

    entitySolidX = nil, entitySolidY = nil,  targetSolidX = nil, targetSolidY = nil

    #Get entity's solid area Wolrd Position
    entitySolidX = entity.worldX + entity.solidArea.x
    entitySolidY = entity.worldY + entity.solidArea.y

    #Get target's solid area Wolrd Position
    targetSolidX = target.worldX + target.solidArea.x
    targetSolidY = target.worldY + target.solidArea.y

    if(entity.upDirection == true)
      entitySolidY -= entity.speed    #predict the position of entity after moving
      if(intersect(entitySolidX, entitySolidY, entity.solidArea.width, entity.solidArea.height,
                    targetSolidX, targetSolidY, target.solidArea.width, target.solidArea.height)
        )
        #puts 'Up Direction Collision'
        entity.collisionOn = true
        return true
      end

    elsif(entity.downDirection == true)
      entitySolidY += entity.speed     #predict the position of entity after moving
      if(intersect(entitySolidX, entitySolidY, entity.solidArea.width, entity.solidArea.height,
                    targetSolidX, targetSolidY, target.solidArea.width, target.solidArea.height)
        )
        #puts 'Down Direction Collision'
        entity.collisionOn = true
        return true
      end

    elsif(entity.leftDirection == true)
      entitySolidX -= entity.speed      #predict the position of entity after moving
      if(intersect(entitySolidX, entitySolidY, entity.solidArea.width, entity.solidArea.height,
                    targetSolidX, targetSolidY, target.solidArea.width, target.solidArea.height)
        )
        #puts 'Left Direction Collision'
        entity.collisionOn = true
        return true
      end

    elsif(entity.rightDirection == true)
      entitySolidX += entity.speed      #predict the position of entity after moving
      if(intersect(entitySolidX, entitySolidY, entity.solidArea.width, entity.solidArea.height,
                    targetSolidX, targetSolidY, target.solidArea.width, target.solidArea.height)
        )
        #puts 'Right Direction Collision'
        entity.collisionOn = true
        return true
      end
    else
      if(intersect(entitySolidX, entitySolidY, entity.solidArea.width, entity.solidArea.height,
                    targetSolidX, targetSolidY, target.solidArea.width, target.solidArea.height)
        )
        #puts 'Undefine_Direction Collision'
        entity.collisionOn = true
        return true
      end
    end
    return false
  end



#---------------------------- Check if one entity collides many targets (targets may be Player, NPCs, Monsters) -----------------------------------------
# this function will return INDEX of one among targets  that collides the entity

  def checkEntity_Collide_AllTargets(entity, targets)         #targets here is array of chacracters (Player, NPCs, Monsters)
    index = -1
    for i in 0..(targets.length - 1)
      if(targets[i] != nil)
        if(checkEntity_Collide_SingleTarget(entity, targets[i]) == true)
          index = i
        end
      end
    end
    return index
  end



#---------------------------- Check if one monster collides any other monster in the monster list-----------------------------------------
#Ex: Given monsterList = {M1, M2, M3, M4}. This function will check if M_i collides any other monsters that are not M_i in the list  
  def checkMonster_Collide_OtherMonsters(monster, monsterList)
    for i in 0..(monsterList.length - 1)
      if(monster != monsterList[i])
        checkEntity_Collide_SingleTarget(monster, monsterList[i])
      end
      if (monster.collisionOn == true)
        return true
      end
    end
    return false
  end


end