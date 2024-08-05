

module WorldHandler

    def worldX_to_screenX(worldX, player)
        screenX = worldlX - player.worldlX + player.x
        return screenX
    end

    def worldY_to_screenY(worldY, player)
        screenY = worldlY - player.worldlY + player.y
        return screenY
    end


    #Draw somewhat object (e.g. monsters, items) in the screen basing on thier WORLD COORDINATE
    #Ex: If a monster has WORLD COORDINATE (1000, 1000), then the following function will help yoi
    #to determine where you should play the monster in our SCREEN (notice that the monster can or cannot in the Screen)
    def DrawObject(object, player)
        screenX = object.worldX - player.worldX + player.x
        screenY = object.worldY - player.worldY + player.y
        # if (object.worldX + CP::TILE_SIZE + 20 >= player.worldX - player.x &&
        #     object.worldX - CP::TILE_SIZE - 20 <= player.worldX + player.x &&
        #     object.worldY + CP::TILE_SIZE + 20 >= player.worldY - player.y &&
        #     object.worldY - CP::TILE_SIZE - 20 <= player.worldY + player.y)

            object.image.x = screenX
            object.image.y = screenY
        # end
    end
end
