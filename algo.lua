local function resetTableForallPosibleMovesForColor()
    for i = 1, N do
        for j = 1, N do
            tableForallPosibleMovesForColor[i][j] = 0
        end
    end
end

local function allPosiblemovesForColor(string)
    
    for i = 1, N do
        for j = 1, N do
            fillArrayOfPosibleMoves(string,i,j)
        end
    end
    for i = 1, N do
        for j = 1, N do
            tableForallPosibleMovesForColor[i][j] = tableOfPosibleMovements[i][j]
        end
    end
    resetArrayOfPosibleMovements()
    resetTableForallPosibleMovesForColor()
end

local function isKingHasCheck(color)
    allPosiblemovesForColor(color)
    for i = 1, N do
        for j = 1, N do
            if tableForallPosibleMovesForColor[i][j] == 1 and field[i][j]["piece"] == "king" then
                if color == "white" then
                    whiteKingHascheck = true
                else
                    blackKingHascheck = true
                end
            end
        end
    end
end