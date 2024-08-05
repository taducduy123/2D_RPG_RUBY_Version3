require 'ruby2d'
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../WorldHandler'
require_relative '../ImageHandler'
require_relative '../Dialogue/ChatBubble'
InventorySize = 9 / 3 # for 3x3 inventory
TILE_SIZE = 100
# Create a class for the inventory
class Inventory
  attr_accessor :cursor_x, :cursor_y, :visible, :IsFull, :my_inventory

  def initialize
    @visible = false
    @IsFull = false
    @held_items_col = 0
    @held_items_row = 0
    # Array to hold player items
    @my_inventory = Array.new(InventorySize) { Array.new(InventorySize, nil) }

    @itemDescription = ChatBubble.new(0, Window.height - Window.height / 12,
    Window.width ,Window.height / 5,"")
    @itemDescription.hide

    @cursor
    @cursor_x = 0
    @cursor_y = 0
    @created_objects = []
    @created_Items_Images = Array.new(InventorySize) { Array.new(InventorySize) }
  end


  def draw_grid
    @my_inventory.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        rect = Rectangle.new(
          x: x * TILE_SIZE + Window.width / 3, y: y * TILE_SIZE + Window.height / 4,
          width: TILE_SIZE - 2, height: TILE_SIZE - 2,
          color: 'black',
          z: 3
        )
        @created_objects << rect

        if @my_inventory[y][x]
          img = Image.new(
            @my_inventory[y][x].image_path,
            x: x * TILE_SIZE + Window.width / 3, y: y * TILE_SIZE + Window.height / 4,
            width: TILE_SIZE - 2, height: TILE_SIZE - 2,
            z: 4
          )
          @created_Items_Images[y][x] = img
        end
      end
    end
  end
  def draw_cursor
    if @cursor # create cursor if not existed , show/ hide when existed
      @cursor.add
    else
      @cursor = Image.new(
        'Image/cursor.png',
        x: @cursor_x * TILE_SIZE + Window.width / 3, y: @cursor_y * TILE_SIZE + Window.height / 4,
        width: TILE_SIZE - 2, height: TILE_SIZE - 2,
        z: 5)
    end
  end

  def move_cursor(dx, dy)
    @cursor_x = (@cursor_x + dx) % InventorySize
    @cursor_y = (@cursor_y + dy) % InventorySize
    if @my_inventory[@cursor_y][@cursor_x]
      @itemDescription.show
      @itemDescription.set_text(@my_inventory[@cursor_y][@cursor_x].description)
    else
      @itemDescription.hide
    end
    @cursor.x = @cursor_x * TILE_SIZE + Window.width / 3
    @cursor.y = @cursor_y * TILE_SIZE + Window.height / 4
  end

  def add_to_inventory(loot) # Methods to add items properly
    found = false
    @my_inventory.each_with_index do |row, row_index|
      row.each_with_index do |element, col_index|
        if @my_inventory[row_index][col_index] == nil && loot[0] != nil
          @my_inventory[row_index][col_index] = loot[0] #Works only for 1 item in chest
          found = true
          break
        end
      end
      break if found
    end
  end

  def display
    draw_grid
    draw_cursor
    move_cursor(0,0)
  end

  def hide
    @created_objects.each(&:remove)
    @created_objects.clear
    @created_Items_Images.each do |row|
      row.each do |image|
        image.remove if image
      end
    end
    @created_Items_Images.each(&:clear)
    @cursor.remove
    @itemDescription.hide
  end

  def removeItem(row, col)
    @my_inventory[row][col] = nil
    @created_Items_Images[row][col].remove
    @created_Items_Images[row].delete_at(col)
  end
end
