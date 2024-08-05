class SharedData
  @shared_chat_array = []

  class << self
    attr_accessor :shared_chat_array
    def clear_array
      @shared_chat_array.clear
    end
  end
end
