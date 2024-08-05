require_relative '../CommonParameter'
require_relative '../GameMap'
require_relative 'Node'



class PathFinder

    attr_reader :openList, :pathList, :startNode, :goalNode, :currentNode, :goalReached, :step
    def initialize()
        @node = Array.new(CP::MAX_WORLD_ROWS) { Array.new(CP::MAX_WORLD_COLS) }

        @openList = []
        @pathList = []

        @startNode = nil
        @goalNode = nil
        @currentNode = nil

        @goalReached = false
        @step = 0

        self.instantiateNodes()
    end

    #
    def instantiateNodes()
        for i in 0..(CP::MAX_WORLD_ROWS - 1)
            for j in 0..(CP::MAX_WORLD_COLS - 1)
                @node[i][j] = Node.new(i, j)
            end
        end
    end

    #
    def resetNodes()
        for i in 0..(CP::MAX_WORLD_ROWS - 1)
            for j in 0..(CP::MAX_WORLD_COLS - 1)
                @node[i][j].open = false
                @node[i][j].checked = false
                @node[i][j].solid = false
            end
        end

        #Reset other settings
        @openList.clear
        @pathList.clear
        @goalReached = false
        @step = 0
    end


    #
    def setNodes(startRow, startCol, goalRow, goalCol, map)

        self.resetNodes()

        #set Start and Goal node
        @startNode = @node[startRow][startCol]
        @currentNode = @startNode
        @goalNode = @node[goalRow][goalCol]
        @openList.push(@currentNode)

        #
        tileNum = nil
        for i in 0..(CP::MAX_WORLD_ROWS - 1)
            for j in 0..(CP::MAX_WORLD_COLS - 1)
                # Set Solid Nodes
                tileNum = map.tileManager[i][j]
                if(map.tile[tileNum].isSolid == true)
                    @node[i][j].solid = true
                end
                # Set Cost
                self.getCost(@node[i][j])
            end
        end
    end


    #
    def getCost(node)
        #get gCost
        xDistance = (node.col - @startNode.col).abs
        yDistance = (node.row - @startNode.row).abs
        node.gCost = xDistance + yDistance

        #get hCost
        xDistance = (node.col - @goalNode.col).abs
        yDistance = (node.row - @goalNode.row).abs
        node.hCost = xDistance + yDistance

        #get fCost
        node.fCost = node.gCost + node.hCost
    end


    #
    def search()
        while (@goalReached == false && @step <= CP::MAX_WORLD_ROWS * CP::MAX_WORLD_COLS) do
            row = @currentNode.row
            col = @currentNode.col

            # Check the current node
            @currentNode.checked = true
            @openList.delete(@currentNode)

            # Open the Up Node
            if(row - 1 >= 0)
                self.openNode(@node[row - 1][col])
            end
            # Open the Down Node
            if(row + 1 < CP::MAX_WORLD_ROWS)
                self.openNode(@node[row + 1][col])
            end
            # Open the Left Node
            if(col - 1 >= 0)
                self.openNode(@node[row][col - 1])
            end
            # Open the Right Node
            if(col + 1 < CP::MAX_WORLD_COLS)
                self.openNode(@node[row][col + 1])
            end

            # Find the Best Node
            bestNodeIndex = 0
            bestNodefCost = CP::MAX_WORLD_ROWS * CP::MAX_WORLD_COLS

            # Select the node having least f_Cost, then g_Cost
            for i in 0..(@openList.length - 1)
                # Check if this node's F_Cost is better
                if(@openList[i].fCost < bestNodefCost)
                    bestNodeIndex = i
                    bestNodefCost = @openList[i].fCost
                # If f_Cost is equal, then check g_Cost
                elsif(@openList[i].fCost == bestNodefCost)
                    if(@openList[i].gCost < @openList[bestNodeIndex].gCost)
                        bestNodeIndex = i
                    end
                end
            end

            # If there is no node in the openList, then end the while-loop
            break if (@openList.length == 0)

            # After the loop, openList[bestNodeIndex] is the next step (= currentNode)
            @currentNode = @openList[bestNodeIndex]

            if (@currentNode.row == @goalNode.row && @currentNode.col == @goalNode.col)
                @goalReached = true
                self.trackThePath()
            end
            @step = @step + 1
        end
        @step = 0
        return @goalReached
    end


    #
    def openNode(node)
        if(node.open == false && node.checked == false && node.solid == false)
            node.open = true
            node.parent = @currentNode
            @openList.push(node)
        end

    end


    # 
    def trackThePath()
        currentNode = @goalNode

        while (currentNode != @startNode) do
            @pathList.unshift(currentNode)      # Insert at front
            currentNode = currentNode.parent
        end
    end
end




# map = GameMap.new
# pFinder = PathFinder.new
# pFinder.setNodes(2, 2, 35, 35, map)
# pFinder.search



#     for i in 0..(pFinder.pathList.length - 1)
#         puts "#{pFinder.pathList[i].row}      #{pFinder.pathList[i].col} \n"
#     end






