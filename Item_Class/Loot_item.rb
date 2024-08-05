require 'ruby2d'

#NOTES: ALL ITEMS are CONSUMABLES

class Meat  # Regain health
  attr_accessor  :image_path, :visible, :description
  def initialize()
    @image_path = 'Image/Meat.png'
    @description = 'Restore health when consumed'
  end

  def effect
    healthRegain = 60
    return healthRegain
  end


end

class RottedItem   # Reduce health
  attr_accessor :image_path, :visible, :description
  def initialize()
    @image_path = 'Image/Spoiled_Meat.png'
    @description = 'Reduce health when consumed'
  end

  def effect
    healthRegain = -60
    return healthRegain
  end
end
