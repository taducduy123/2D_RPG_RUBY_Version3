


class Node
   attr_reader :row, :col
   attr_accessor :parent, :gCost, :hCost, :fCost, :solid, :open, :checked
    def initialize(row, col)
        @parent = nil

        @row = row
        @col = col

        @gCost = nil
        @hCost = nil
        @fCost = nil

        @solid = nil
        @open = nil
        @checked = nil
    end

end