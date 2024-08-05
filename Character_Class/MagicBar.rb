require 'ruby2d'

class MagicBar

  attr_reader :mp, :x, :y
  attr_writer :mp,:x, :y
  attr_accessor :mana, :rec1, :rec2

  def initialize(mp, maxMp, x, y, leng)
    @leng = leng
    @mp = mp
    @maxMp = maxMp
    #the mana icon
    @mana = Image.new(
      './Image/Mana.png',
      x: x, y: y,
      width: 15, height: 10,
      z: 2
    )

    #the maxMp bar
    @rec1 = Rectangle.new(
      x: x, y: y,
      width: leng + 4, height: 12, #plus 4 to make the right and left border for the health bar (each is 2 pixel)
      color: 'black',
      z: 0
    )
    # the mp bar
    @rec2 = Rectangle.new(
      x: x + 2, y: y + 2,
      width: (@mp*1.00/@maxMp)*leng , height: 8,
      color: 'blue',
      z: 1
    )

    @rec3 = Rectangle.new(
      x: x + leng/2 + 1, y: y+1,
      width: 2, height: 11,
      color: 'white',
      z:3,
      opacity: 0.5
    )
  end

  def move(x,y)
    @rec1.x = x
    @rec1.y = y
    
    @rec2.x = x
    @rec2.y = y

    @rec3.x = x
    @rec3.y = y

    @mana.x = x
    @mana.y = y
  end

  def useSpecialskill
    @mp -= 50
  end

  def canUseSkill?
    if @mp/50 > 1
        return true
    else
        return false
    end
  end

  #update method and setting range for hp
  def update
    @mp += 0.1
    if @mp <= 0
      @mp = 0
    elsif @mp >= @maxMp
      @mp = @maxMp
    end
    @rec2.width = (@mp*1.00/@maxMp)*@leng
  end
end