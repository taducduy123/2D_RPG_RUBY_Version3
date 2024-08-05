require 'ruby2d'

class HealthBar

  attr_reader :hp, :x, :y
  attr_writer :hp,:x, :y
  attr_accessor :heart, :rec1, :rec2

  def initialize(hp, maxHp, x, y, leng)
    @leng = leng
    @hp = hp
    @maxHp = maxHp
    #the heart icon
    @heart = Image.new(
      './Image/Heart.png',
      x: x, y: y,
      width: 15, height: 10,
      z: 2
    )

    #the maxHp bar
    @rec1 = Rectangle.new(
      x: x, y: y,
      width: leng + 4, height: 12, #plus 4 to make the right and left border for the health bar (each is 2 pixel)
      color: 'black',
      z: 0
    )
    # the hp bar
    @rec2 = Rectangle.new(
      x: x + 2, y: y + 2,
      width: (@hp*1.00/@maxHp)*leng , height: 8,
      color: 'red',
      z: 1
    )
  end

  def move(x,y)
    @rec1.x = x
    @rec1.y = y
    
    @rec2.x = x
    @rec2.y = y

    @heart.x = x
    @heart.y = y
  end

  def isDead?
    if @hp == 0
      return true
    else
      return false
    end
  end

  #update method and setting range for hp
  def update
    if @hp <= 0
      @hp = 0
    elsif @hp >= @maxHp
      @hp = @maxHp
    end
    @rec2.width = (@hp*1.00/@maxHp)*@leng
  end
end
