require 'ruby2d'

class ChatBubble
  attr_accessor :image, :text
  attr_reader   :visible

  def initialize(x, y, width, height, message = "")
    @image = Image.new(
      'Image/ChatBox.png',
      x: x,
      y: y,
      width: width,
      height: height,
      z: 4
    )
    @visible = true

    @text = Text.new(
      message,
      x: x + width / 3, y: y + 10,
      style: 'bold',
      size: 15,
      color: 'black',
      z: 5
    )
  end

  def set_text(message)
    @text.text = message
  end

  def show
    @image.add
    @text.add
    @visible = true
  end

  def hide
    @image.remove
    @text.remove
    @visible = false
  end
end
