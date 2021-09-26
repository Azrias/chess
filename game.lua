local composer = require( "composer" )
 
local scene = composer.newScene()

--Global variable for number of squares of the field @see "createField"
local N = 8
--Global variable of the game field @see "createField"
local field = {}
local fieldGroup

local ONE_PLAYER = true

local currentTurnColor = "white"

local whiteKingHascheck
local blackKingHascheck

local whiteKingHascheckForAnalys
local blackKingHascheckForAnalys

local nameOfTheFilePawnWhite = "blackPawn.png"
local nameOfTheFileRockWhite = "blackRock.png"
local nameOfTheFileBishopWhite = "blackBishop.png"
local nameOfTheFileQueenWhite = "blackQueen.png"
local nameOfTheFileKingWhite = "blackKing.png"
local nameOfTheFileKnightWhite = "blackKnight.png"

local nameOfTheFilePawnBlack = "whitePawn.png"
local nameOfTheFileRockBlack = "whiteRock.png"
local nameOfTheFileBishopBlack = "whiteBishop.png"
local nameOfTheFileQueenBlack = "whiteQueen.png"
local nameOfTheFileKingBlack = "whiteKing.png"
local nameOfTheFileKnightBlack = "whiteKnight.png"

local DISTANCE_BETWEEN_SQUARES = 35
local SIZE_OF_THE_SQUARE = DISTANCE_BETWEEN_SQUARES - 1
local FIELD_OFFSET_X = 20
local FIELD_OFFSET_Y = 50
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--- Creating an array of square but do not draw them @see "drawTheSquares"
local tableOfPosibleMovements = {}
local tableOfAllPosibleMovementsForColor = {}
local tableForAnalys = {}
local tableForallPosibleMovesForAnalys = {}
local function createField()
    -- body
    for i=1,N do
        field[i] = {}
        tableOfPosibleMovements[i] = {}
        tableOfAllPosibleMovementsForColor[i] = {}
        tableForAnalys[i] = {}   
        tableForallPosibleMovesForAnalys[i] = {}  
        for j=1,N do
            local square = {}
            square["x"] = i * DISTANCE_BETWEEN_SQUARES - DISTANCE_BETWEEN_SQUARES/2
            square["y"] = j * DISTANCE_BETWEEN_SQUARES - DISTANCE_BETWEEN_SQUARES/2
            field[i][j] = square
            field[i][j]["piece"] = "null"
            field[i][j]["color"] = "null"
            field[i][j]["object"] = "null"
            tableOfPosibleMovements[i][j] = 0
            tableOfAllPosibleMovementsForColor[i][j] = 0
            tableForAnalys[i][j] = 0
            tableForallPosibleMovesForAnalys[i][j] = 0
        end
    end
end

local function changeColorOfSquare()
    -- body
    for i=1,N do
        for j=1,N do
            if( (i + j) % 2 == 1) then
                field[i][j]["square"]:setFillColor(0,0.5,0)
            else 
                field[i][j]["square"]:setFillColor(1,1,1)
            end
        end
    end
end

local function drawTheSquares()
    -- body
    fieldGroup = display.newGroup()
    for i=1,N do
        for j=1,N do
            local square = display.newRect(field[i][j]["x"],field[i][j]["y"],SIZE_OF_THE_SQUARE,SIZE_OF_THE_SQUARE)
            field[i][j]["square"] = square
            fieldGroup:insert( square )
        end
    end
    fieldGroup.x = FIELD_OFFSET_X
    fieldGroup.y = FIELD_OFFSET_Y
    changeColorOfSquare()
end
local function rotateField()
    fieldGroup:rotate(180)
    fieldGroup.x = fieldGroup.x + DISTANCE_BETWEEN_SQUARES * N
    fieldGroup.y = fieldGroup.y + DISTANCE_BETWEEN_SQUARES * N
end
local centerOfSquare,xOfUnderneathSquare,yOfUnderneathSquare
local function findXAndYOfSquareUnderneath(x,y)
    for i = 1,N do
        centerOfSquare = FIELD_OFFSET_X - DISTANCE_BETWEEN_SQUARES/2 + DISTANCE_BETWEEN_SQUARES * i
        if (x < centerOfSquare + DISTANCE_BETWEEN_SQUARES/2 and x > centerOfSquare - DISTANCE_BETWEEN_SQUARES/2) then
            xOfUnderneathSquare = i
        end
    end
    for i = 1,N do
        centerOfSquare = FIELD_OFFSET_Y - DISTANCE_BETWEEN_SQUARES/2 + DISTANCE_BETWEEN_SQUARES * i
        if (y < centerOfSquare + DISTANCE_BETWEEN_SQUARES/2 and y > centerOfSquare - DISTANCE_BETWEEN_SQUARES/2) then
            yOfUnderneathSquare = i
        end
    end
end

local function isPieceOnSquare(x,y)
    if field[x][y]["piece"] == "null" then
        return false
    end
    return true
end

local function capturePiece(x,y)
    display.remove(field[x][y]["object"])
    field[x][y]["piece"] = "null"
    field[x][y]["object"] = "null"
    field[x][y]["color"] = "null"
end

local function highlightPossibleFigureMovements(xCenter,yCenter)
    for i = 1, N do
        for j = 1, N do
            if tableOfPosibleMovements[i][j] == 1  then
                field[i][j]["square"]:setFillColor(1,1,0)
            end
        end
    end
    --field[xCenter][yCenter]["square"]:setFillColor(1,0,0)
end


local function resetArrayOfPosibleMovements()
    for i = 1, N do
        for j = 1, N do
            tableOfPosibleMovements[i][j] = 0
        end
    end
end

local function resetTableOfAllPosibleMovementsForColor()
    for i = 1, N do
        for j = 1, N do
            tableOfAllPosibleMovementsForColor[i][j] = 0
        end
    end
end

local function resetTableForAnalys()
    for i = 1, N do
        for j = 1, N do
            tableForAnalys[i][j] = 0
        end
    end
end

local function resettableForallPosibleMovesForAnalys()
    for i = 1, N do
        for j = 1, N do
            tableForallPosibleMovesForAnalys[i][j] = 0
        end
    end
end

local function arrayOfPosibleMovesBishop(table,xStart,yStart)
    local x
    local y
    x = xStart - 1
    y = yStart - 1
    while ( x > 0 and y > 0)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        x = x - 1
        y = y - 1
    end
    x = xStart - 1 
    y = yStart + 1
    while ( x > 0 and y <= N)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        x = x - 1
        y = y + 1
    end
    x = xStart + 1 
    y = yStart - 1
    while ( y > 0 and x <= N)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        x = x + 1 
        y = y - 1
    end
    x = xStart + 1 
    y = yStart + 1
    while ( x <= N and y <= N)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        x = x + 1 
        y = y + 1
    end
end

local function arrayOfPosibleMovesRock(table,xStart,yStart)
    local x
    local y 
    x = xStart - 1
    y = yStart
    while ( x > 0 ) do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        x = x - 1
    end
    x = xStart + 1
    y = yStart
    while (x <= N)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        x = x + 1 
    end
    x = xStart 
    y = yStart - 1
    while (y > 0)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        y = y - 1
    end
    x = xStart 
    y = yStart + 1
    while (y <= N)do
        table[x][y] = 1
        if isPieceOnSquare(x,y) then
            if field[x][y]["color"] == field[xStart][yStart]["color"] then
                table[x][y] = 0
            end
            break
        end
        y = y + 1
    end
end

local function arrayOfPosibleMovesKing(table,xStart,yStart)
    for i = 1, N do
        for j = 1, N do
            if math.abs(i - xStart) <= 1 and  math.abs(j - yStart) <= 1 then
                table[i][j] = 1
                if isPieceOnSquare(i,j) then
                    if field[i][j]["color"] == field[xStart][yStart]["color"] then
                        table[i][j] = 0
                    end
                end
            end
        end
    end
    
end

local function arrayOfPosibleMovesKnight(table,xStart,yStart)
    for i = 1, N do
        for j = 1, N do
            if math.abs(i - xStart) == 1 and  math.abs(j - yStart) == 2 then
                table[i][j] = 1
            end
            if math.abs(i - xStart) == 2 and  math.abs(j - yStart) == 1 then
                table[i][j] = 1
            end
        end
    end
    for i = 1, N do
        for j = 1, N do
            if isPieceOnSquare(i,j) and field[i][j]["color"] == field[xStart][yStart]["color"] then
                table[i][j] = 0
            end
        end
    end
end

local function arrayOfPosibleMovesPawn(table,xStart,yStart)
    if yStart == 7 and field[xStart][yStart]["color"] == "white" then
        if not isPieceOnSquare(xStart, yStart - 1)  and not isPieceOnSquare(xStart, yStart - 2) then
            table[xStart][yStart - 2] = 1
        end
    end

    if yStart == 2 and field[xStart][yStart]["color"] == "black" then
        if not isPieceOnSquare(xStart, yStart + 1)  and not isPieceOnSquare(xStart, yStart + 2) then
            table[xStart][yStart + 2] = 1
        end
    end
    
    if field[xStart][yStart]["color"]  == "black" then
        if xStart ~= 1 then
            if isPieceOnSquare(xStart - 1, yStart + 1) and field[xStart - 1][yStart + 1]["color"] ~= field[xStart][yStart]["color"] then
                table[xStart - 1][yStart + 1] = 1
            end
        end
        if not isPieceOnSquare(xStart, yStart + 1) then
            table[xStart][yStart + 1] = 1
        end
        if xStart ~= 8 then
            if isPieceOnSquare(xStart + 1, yStart + 1) and field[xStart + 1][yStart + 1]["color"] ~= field[xStart][yStart]["color"]  then
                table[xStart + 1][yStart + 1] = 1
            end
        end
    else
        if xStart ~= 1 then
            if isPieceOnSquare(xStart - 1, yStart - 1) and field[xStart - 1][yStart - 1]["color"] ~= field[xStart][yStart]["color"]  then
                table[xStart - 1][yStart - 1] = 1
            end
        end
        if not isPieceOnSquare(xStart, yStart - 1) then
            table[xStart][yStart - 1] = 1
        end
        if xStart ~= 8 then
            if isPieceOnSquare(xStart + 1, yStart - 1) and field[xStart + 1][yStart - 1]["color"] ~= field[xStart][yStart]["color"]  then
                table[xStart + 1][yStart - 1] = 1
            end
        end
    end
    
end


local function fillArrayOfPosibleMoves(table,string,x,y)
    if field[x][y]["color"] == currentTurnColor and  not ONE_PLAYER then
        return 
    end
    if string == "biship" then
        arrayOfPosibleMovesBishop(table,x,y)
    end
    if string == "rock" then
        arrayOfPosibleMovesRock(table,x,y)
    end
    if string == "queen" then
        arrayOfPosibleMovesBishop(table,x,y)
        arrayOfPosibleMovesRock(table,x,y)
    end
    if string == "king" then
        arrayOfPosibleMovesKing(table,x,y)
    end
    if field[x][y]["piece"] == "knight" then
        arrayOfPosibleMovesKnight(table,x,y)
    end
    if string == "pawn" then
        arrayOfPosibleMovesPawn(table,x,y)
    end
end


local function isValidMovement(xEnd,yEnd)
    for i = 1, N do
        for j = 1, N do
            if tableOfPosibleMovements[xEnd][yEnd] == 1 then
                return true
            end
        end
    end
    return false
end

local needToAddEventListener = false
local function promotePawn(x,y)
    capturePiece(x,y)
    needToAddEventListener = true
    local piece
    if y == 1 then
        piece = display.newImage(nameOfTheFileQueenBlack,field[x][y]["x"],field[x][y]["y"])
        field[x][y]["color"] = "black"
    else
        piece = display.newImage(nameOfTheFileQueenWhite,field[x][y]["x"],field[x][y]["y"])
        field[x][y]["color"] = "white"
    end
    fieldGroup:insert( piece )
    field[x][y]["object"] = piece   
    field[x][y]["piece"] = "queen"
end

local function isNeedToPromote(string,y)
    if string == "pawn" then
        if y == 8 or y == 1 then
            return true
        end
    end
    return false
end

local function allPosiblemovesForColor(table,string)
    local color
    if string  == "white" then
        color = "black"
    else
        color = "white"
    end
    for i = 1, N do
        for j = 1, N do
            if field[i][j]["color"] == color and field[i][j]["piece"] ~= "null" then
                fillArrayOfPosibleMoves(table,field[i][j]["piece"],i,j)
            end
        end
    end
end

local function isKingHasCheckForAnalys(color)
    allPosiblemovesForColor(tableForallPosibleMovesForAnalys,color)
    for i = 1, N do
        for j = 1, N do
            if tableForallPosibleMovesForAnalys[i][j] == 1 then
                --print(i .. " " .. j)
            end
        end
    end
    if color == "white" then
        whiteKingHascheckForAnalys = "false"
    else
        blackKingHascheckForAnalys = "false"
    end
    for i = 1, N do
        for j = 1, N do
            if tableForallPosibleMovesForAnalys[i][j] == 1 and field[i][j]["piece"] == "king" then
                print(i .. " " .. j .. "white can go here and here is a king")
                if color == "white" then
                    whiteKingHascheckForAnalys = "true"
                    --print "sq"
                else
                    blackKingHascheckForAnalys = "true"
                    --print "black has a check"
                end
            end
        end
    end
    print(blackKingHascheckForAnalys)
    resettableForallPosibleMovesForAnalys()
end

local function isKingHasCheck(color)
    allPosiblemovesForColor(tableOfAllPosibleMovementsForColor,color)
    if color == "white" then
        whiteKingHascheck = "false"
    else
        blackKingHascheck = "false"
    end
    for i = 1, N do
        for j = 1, N do
            if tableOfAllPosibleMovementsForColor[i][j] == 1 and field[i][j]["piece"] == "king" and field[i][j]["color"] == color then
                if color == "white" then
                    whiteKingHascheck = "true"
                else
                    blackKingHascheck = "true"
                end
            end
        end
    end
    resetTableOfAllPosibleMovementsForColor()
end

local function changePiecePositionForCheck(xStart,yStart,xEnd,yEnd,color)
    local isLegalMove = true
    local kpiece = field[xEnd][yEnd]["piece"]
    field[xEnd][yEnd]["piece"] = field[xStart][yStart]["piece"]
    field[xStart][yStart]["piece"] = "null"
    local kcolor = field[xEnd][yEnd]["color"]
    field[xEnd][yEnd]["color"] = field[xStart][yStart]["color"]
    field[xStart][yStart]["color"] = "null"
    local kobject = field[xEnd][yEnd]["object"]
    field[xEnd][yEnd]["object"] = field[xStart][yStart]["object"]
    field[xStart][yStart]["object"] = "null"
    --print(xEnd .. " " .. yEnd)

    if color == "black" then
        isKingHasCheckForAnalys("black")
        if blackKingHascheckForAnalys == "true" then
            isLegalMove = false
            --print("black king has check if go to" .. xEnd .. yEnd)
        else
            --print("black doesnot have one")
        end
    else
        isKingHasCheckForAnalys("white")
        if whiteKingHascheckForAnalys == "true" then
            isLegalMove = false
            --print("white king has check if go to" .. xEnd .. yEnd)
        else
            --print("white doesnot have one")
        end
    end
    field[xStart][yStart]["piece"] = field[xEnd][yEnd]["piece"]
    field[xEnd][yEnd]["piece"] = kpiece
    field[xStart][yStart]["color"] = field[xEnd][yEnd]["color"]
    field[xEnd][yEnd]["color"] = kcolor
    field[xStart][yStart]["object"] = field[xEnd][yEnd]["object"]
    field[xEnd][yEnd]["object"] = kobject
    return isLegalMove
end

local function changePiecePosition(event,pieceStartCoordinateX,pieceStartCoordinateY)
    event.target.x = DISTANCE_BETWEEN_SQUARES * xOfUnderneathSquare - DISTANCE_BETWEEN_SQUARES/2
    event.target.y = DISTANCE_BETWEEN_SQUARES * yOfUnderneathSquare - DISTANCE_BETWEEN_SQUARES/2 
    field[xOfUnderneathSquare][yOfUnderneathSquare]["piece"] = field[pieceStartCoordinateX][pieceStartCoordinateY]["piece"]
    field[pieceStartCoordinateX][pieceStartCoordinateY]["piece"] = "null"
    field[xOfUnderneathSquare][yOfUnderneathSquare]["object"] = field[pieceStartCoordinateX][pieceStartCoordinateY]["object"]
    field[pieceStartCoordinateX][pieceStartCoordinateY]["object"] = "null"
    field[xOfUnderneathSquare][yOfUnderneathSquare]["color"] = field[pieceStartCoordinateX][pieceStartCoordinateY]["color"]
    field[pieceStartCoordinateX][pieceStartCoordinateY]["color"] = "null"
    if isNeedToPromote(field[xOfUnderneathSquare][yOfUnderneathSquare]["piece"],yOfUnderneathSquare) then
        promotePawn(xOfUnderneathSquare,yOfUnderneathSquare)
    end
    if currentTurnColor == "white" then
        currentTurnColor = "black"
    else
        currentTurnColor = "white"
    end
end

local pieceStartCoordinateX, pieceStartCoordinateY
local function changePiecePositionIfValid(event,pieceStartPositionX,pieceStartPositionY)
    -- body
    local x,y
    x = event.target.x + FIELD_OFFSET_X
    y = event.target.y + FIELD_OFFSET_Y
    findXAndYOfSquareUnderneath(x,y) -- return xOfUnderneathSquare yOfUnderneathSquare
    local startPositionCoordinateX = math.floor(pieceStartPositionX/35) + 1
    local startPositionCoordinateY = math.floor(pieceStartPositionY/35) + 1
    if isValidMovement(xOfUnderneathSquare,yOfUnderneathSquare) then
        if isPieceOnSquare(xOfUnderneathSquare,yOfUnderneathSquare) then
            capturePiece(xOfUnderneathSquare,yOfUnderneathSquare)
        end
        changePiecePosition(event,startPositionCoordinateX,startPositionCoordinateY)
        resetArrayOfPosibleMovements() 
    else
        event.target.x = pieceStartPositionX
        event.target.y = pieceStartPositionY
        resetArrayOfPosibleMovements() 
    end
end

local function excludeMovesWhereTheKingHasCheck(xStart,yStart,color)
    -- для фигуры которую взял игрок фигуры своего цвета простчитать все ходы если есть чек то исключить
    fillArrayOfPosibleMoves(tableForAnalys,field[xStart][yStart]["piece"],xStart,yStart)
    for i = 1, N do
        for j = 1, N do
            if tableForAnalys[i][j] == 1  and not changePiecePositionForCheck(xStart,yStart,i,j,color) then
                print(i .. j .. "illigal square")
                tableOfPosibleMovements[i][j] = 0
            end
        end
    end
    resetTableForAnalys()
end

local  pieceStartPositionX, pieceStartPositionY
local function onObjectTouch( event )
    if ( event.phase == "began" ) then
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        pieceStartPositionX = event.target.x
        pieceStartPositionY = event.target.y  
        local startPositionCoordinateX = math.floor(pieceStartPositionX/35) + 1
        local startPositionCoordinateY = math.floor(pieceStartPositionY/35) + 1
        fillArrayOfPosibleMoves(tableOfPosibleMovements,field[startPositionCoordinateX][startPositionCoordinateY]["piece"],
                                 startPositionCoordinateX,startPositionCoordinateY)
        
        if whiteKingHascheck == "true" then
            excludeMovesWhereTheKingHasCheck(startPositionCoordinateX,startPositionCoordinateY,"white")
        end
        if blackKingHascheck == "true" then   
            excludeMovesWhereTheKingHasCheck(startPositionCoordinateX,startPositionCoordinateY,"black")
        end 
        highlightPossibleFigureMovements(startPositionCoordinateX,startPositionCoordinateY)
    elseif ( event.target.isFocus ) then
        if ( event.phase == "moved" ) then
            event.target.x = event.x - FIELD_OFFSET_X
            event.target.y = event.y - FIELD_OFFSET_Y
        elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
            display.getCurrentStage():setFocus( nil )
            event.target.isFocus = false
            
            changePiecePositionIfValid(event,pieceStartPositionX,pieceStartPositionY)
            if needToAddEventListener then
                needToAddEventListener = false
                local startPositionCoordinateX = math.floor(event.target.x/DISTANCE_BETWEEN_SQUARES) + 1
                local startPositionCoordinateY = math.floor(event.target.y/DISTANCE_BETWEEN_SQUARES) + 1
                field[startPositionCoordinateX][startPositionCoordinateY]["object"]:addEventListener( "touch", onObjectTouch ) 
            end
            isKingHasCheck("white")
            isKingHasCheck("black")
            resetArrayOfPosibleMovements()
            changeColorOfSquare()
            resetArrayOfPosibleMovements()
        end
    end
 
    return true
end






local function createPawns()
    for i = 1,N do
        field[i][2]["object"] = display.newImage(nameOfTheFilePawnWhite,field[i][2]["x"],field[i][2]["y"]) 
        fieldGroup:insert( field[i][2]["object"] )
        field[i][2]["object"]:addEventListener( "touch", onObjectTouch )
        field[i][2]["piece"] = "pawn"
        field[i][2]["color"] = "black"
    end
    for i = 1,N do
        field[i][7]["object"] = display.newImage(nameOfTheFilePawnBlack,field[i][7]["x"],field[i][7]["y"]) 
        fieldGroup:insert( field[i][7]["object"] )
        field[i][7]["object"]:addEventListener( "touch", onObjectTouch )   
        field[i][7]["piece"] = "pawn"
        field[i][7]["color"] = "white"
    end
end

local function createQueens()
    
    local piece = display.newImage(nameOfTheFileQueenWhite,field[4][1]["x"],field[4][1]["y"]) 
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )
    field[4][1]["object"] = piece   
    field[4][1]["piece"] = "queen"
    field[4][1]["color"] = "black"
     

    local piece = display.newImage(nameOfTheFileQueenBlack,field[4][8]["x"],field[4][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )  
    field[4][8]["object"] = piece   
    field[4][8]["piece"] = "queen"
    field[4][8]["color"] = "white"
     
end

local function createBiships()
    local piece = display.newImage(nameOfTheFileBishopWhite,field[3][1]["x"],field[3][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    field[3][1]["object"] = piece  
    field[3][1]["piece"] = "biship"
    field[3][1]["color"] = "black"
     


    local piece = display.newImage(nameOfTheFileBishopWhite,field[6][1]["x"],field[6][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[6][1]["object"] = piece  
    field[6][1]["piece"] = "biship"
    field[6][1]["color"] = "black"
     
    local piece = display.newImage(nameOfTheFileBishopBlack,field[3][8]["x"],field[3][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[3][8]["object"] = piece  
    field[3][8]["piece"] = "biship"
    field[3][8]["color"] = "white"
     


    local piece = display.newImage(nameOfTheFileBishopBlack,field[6][8]["x"],field[6][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch ) 
    
    field[6][8]["object"] = piece    
    field[6][8]["piece"] = "biship"
    field[6][8]["color"] = "white"
     
end

local function createKnights()
    local piece = display.newImage(nameOfTheFileKnightWhite,field[2][1]["x"],field[2][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )  
    
    field[2][1]["object"] = piece   
    field[2][1]["piece"] = "knight"
    field[2][1]["color"] = "black"
     


    local piece = display.newImage(nameOfTheFileKnightWhite,field[7][1]["x"],field[7][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[7][1]["object"] = piece  
    field[7][1]["piece"] = "knight"
    field[7][1]["color"] = "black"
     

    
    local piece = display.newImage(nameOfTheFileKnightBlack,field[2][8]["x"],field[2][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )  
    
    field[2][8]["object"] = piece   
    field[2][8]["piece"] = "knight"
    field[2][8]["color"] = "white"
     


    
    local piece = display.newImage(nameOfTheFileKnightBlack,field[7][8]["x"],field[7][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[7][8]["object"] = piece  
    field[7][8]["piece"] = "knight"
    field[7][8]["color"] = "white"
     
end

local function createRocks()
    local piece = display.newImage(nameOfTheFileRockWhite,field[1][1]["x"],field[1][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[1][1]["object"] = piece  
    field[1][1]["piece"] = "rock"
    field[1][1]["color"] = "black"
     


    local piece = display.newImage(nameOfTheFileRockWhite,field[8][1]["x"],field[8][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[8][1]["object"] = piece  
    field[8][1]["piece"] = "rock"
    field[8][1]["color"] = "black"
     

    local piece = display.newImage(nameOfTheFileRockBlack,field[1][8]["x"],field[1][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    
    field[1][8]["object"] = piece  
    field[1][8]["piece"] = "rock"
    field[1][8]["color"] = "white"
     


    local piece = display.newImage(nameOfTheFileRockBlack,field[8][8]["x"],field[8][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )  
    
    field[8][8]["object"] = piece   
    field[8][8]["piece"] = "rock"
    field[8][8]["color"] = "white"
     
end

local function createKings()
    local piece = display.newImage(nameOfTheFileKingWhite,field[5][1]["x"],field[5][1]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    field[5][1]["piece"] = "king"
    field[5][1]["color"] = "black"
    
    field[5][1]["object"] = piece  
     

    local piece = display.newImage(nameOfTheFileKingBlack,field[5][8]["x"],field[5][8]["y"])
    fieldGroup:insert( piece )
    piece:addEventListener( "touch", onObjectTouch )   
    field[5][8]["piece"] = "king"
    field[5][8]["color"] = "white"
    
    field[5][8]["object"] = piece  
     
end

local function createPieces()
    -- body
    createPawns()
    createQueens()
    createBiships()
    createKings()
    createRocks()
    createKnights()

    
end



 




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    createField()
    drawTheSquares()
    createPieces()
    --rotateField()
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene