# event_handlers.rb



#---------------------------------------- When user presses a key --------------------------------------
def handle_key_down(event, player, monsters)
  case event.key
    when 'w'
      player.runAnimation()
      player.upDirection = true
      #player.direction = "up"
    when 's'
      player.runAnimation()
      player.downDirection = true
      #player.direction = "down"
    when 'a'
      player.runAnimation()
      player.leftDirection = true
      #player.direction = "left"
    when 'd'
      player.runAnimation()
      player.rightDirection = true
      #player.direction = "right"
    when 'j'
      player.attackInBox(monsters)

    when 'k'
      player.attackSpecial(monsters)
  end
end

#---------------------------------------- When user releases a key --------------------------------------
def handle_key_up(event, player)
  case event.key
    when 'w'
      player.upDirection = false
      player.stop
    when 's'
      player.downDirection = false
      player.stop
    when 'a'
      player.leftDirection = false
      player.stop
    when 'd'
      player.rightDirection = false
      player.stop
  end
end

#---------------------------------------- Set up Player to be moveable --------------------------------------
def get_key_input(player, interact_obj, interact_npc, monsters)

  on :key_held do |event|
    handle_key_down(event, player, monsters)
    #puts "You are PRESSING a key\n"
  end

  on :key_down do |event|
    handle_key_down(event, player, monsters)

  end

  on :key_up do |event|
    handle_key_up(event, player)
  end
 #handles inventory
  on :key_down do |event|
    case event.key
    when 'i'
      if player.myInventory.visible
        player.myInventory.hide
        player.myInventory.visible = false
      else
        player.myInventory.visible = true
        player.myInventory.display
      end

    when 'f'
      if player.myInventory.visible
       player.useItem()
      end

    when 'left'
      player.myInventory.move_cursor(-1, 0) if player.myInventory.visible
    when 'right'
      player.myInventory.move_cursor(1, 0) if player.myInventory.visible
    when 'up'
      player.myInventory.move_cursor(0, -1) if player.myInventory.visible
    when 'down'
      player.myInventory.move_cursor(0, 1) if player.myInventory.visible
    #handles interaction
    when 'x'
      if player.talktoNpc >= 0
       interact_npc[player.talktoNpc].chatprogress += 1
      end
    when 'e'
      if player.interacting > -1
       interact_obj[player.interacting].playerInteract(player)
      end
    end
  end
end
