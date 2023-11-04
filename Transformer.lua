local Enum = {}
Enum.TextXAlignment = {
    Center = 'Center',
    Left = 'Left',
    Right = 'Right'
}
Enum.TextYAlignment = {
    Bottom = 'Bottom',
    Center = 'Center',
    Top = 'Top'
}

-- Testing values
local TEST_MODE = false
local Testing = {
    elementsSelect = TEST_MODE,
    printEveryTick = TEST_MODE,
    physicalElements = false,
    physicalFrames = true,
    movableFrame = false,
    progressBarChangeValue = true,
    jacobToolTip = false
}

-- math library
local math = math
function math.clamp(min, value, max)
    return math.max(math.min(value, max), min)
end

function math.lerp(min, max, value)
    return min + (max - min) * value
end

function math.rgbLerp(color1, color2, value)
    local r = math.lerp(color1[1], color2[1], value)
    local g = math.lerp(color1[2], color2[2], value)
    local b = math.lerp(color1[3], color2[3], value)
    return { r, g, b }
end

function math.rgbaLerp(color1, color2, value)
    local r = math.lerp(color1[1], color2[1], value)
    local g = math.lerp(color1[2], color2[2], value)
    local b = math.lerp(color1[3], color2[3], value)
    local a = math.lerp(color1[4], color2[4], value)
    return { r, g, b, a }
end

function math.collide(min, startPos, length, max)
    local newPos = math.clamp(min, startPos, max - length)
    return newPos, startPos ~= newPos
end

-- Abstract static base class
local Object = {}

function Object:registerObject(object)
    object._myClass = self
    setmetatable(object, {__index = self})
end

function Object:super()
    return self._parentClass
end

function Object:new()
    local obj = {}
    self:registerObject(obj)
    return obj
end

function Object:getTableArray(length)
    local newArray = {}
    for i = 1, length do
        table.insert(newArray, {})
    end
    return newArray
end

function Object:getValueArray(length, value)
    local newArray = {}
    for i = 1, length do
        table.insert(newArray, value)
    end
    return newArray
end

function Object:getTable2D(width, height)
    local table = {}
    for i = 1, width do
        table[i] = self:getTableArray(height)
    end
    return table
end

-- extends class
local function extends(className)
    return setmetatable({ _parentClass = className }, {__index = className})
end

-- Class Color
local Color = extends(Object)

function Color.lerp(color1, color2, value)

end

function Color:new(r, g, b, a)
    local obj = self:super():new()
    self:registerObject(obj)
    obj._r = r or 0
    obj._g = g or 0
    obj._b = b or 0
    obj._a = a or 0
    return obj
end

-- Abstract class Element
local Element = extends(Object)

function Element:new(posX, posY, width, height)
    local obj = self:super():new()
    self:registerObject(obj)
    obj._enabled = true
    -- graphics
    obj._anchorX = 0
    obj._anchorY = 0
    obj._posX = posX or 0
    obj._posY = posY or 0
    obj._width = width or 0
    obj._height = height or 0
    obj._padding = 5
    obj._lineWidth = 5
    obj._lineHeight = 5
    obj._minWidth = 10
    obj._minHeight = 10
    obj._title = ''
    obj._autosizeX = false
    obj._autosizeY = false
    obj._raycastTarget = true
    obj._pastIsSelect = false
    obj._hasBorder = true
    obj._hasSelected = Testing.elementsSelect
    obj._isContainer = false
    obj._parentContainer = nil
    obj._mouse = nil
    -- psychics
    obj._slowdown = 0.95
    obj._gravity = 20 -- 20
    obj._friction = 0.8
    obj._bounciness = 0.8
    obj._isPhysical = Testing.physicalElements
    obj._isCollider = Testing.physicalElements
    -- colors
    obj._borderColor = { 255, 255, 255 }
    obj._borderColorSelected = obj._borderColor
    obj._backgroundColor = { 0, 0, 0 }
    obj._backgroundColorSelected = obj._backgroundColor
    -- update values
    obj._mouseX = 0
    obj._mouseY = 0
    obj._drawX = 0
    obj._drawY = 0
    obj._dx = 0
    obj._dy = 0
    obj._isSelect = false
    obj._currentBorderColor = obj._borderColor
    obj._currentBackgroundColor = obj._backgroundColor
    return obj
end

function Element:getPosition()
    return self._posX, self._posY
end

function Element:getAnchor()
    return self._anchorX, self._anchorY
end

function Element:getSize()
    return self._width, self._height
end

function Element:setPosition(x, y)
    self._posX, self._posY = x, y
end

function Element:getMouse()
    return self._mouse
end

function Element:getPadding()
    return self._padding
end

function Element:getLineHeight()
    return self._lineHeight
end

function Element:getIsContainer()
    return self._isContainer
end

function Element:setAnchor(x, y)
    self._anchorX, self._anchorY = x, y
end

function Element:setPadding(padding)
    self._padding = padding
end

function Element:setLineHeight(lineHeight)
    self._lineHeight = lineHeight
end

function Element:getParentContainer()
    return self._parentContainer
end

function Element:setParentContainer(parent)
    self._parentContainer = parent
end

function Element:setMouse(mouse)
    self._mouse = mouse
end

function Element:onSelect(posX, posY)
    --print(posX, posY)
end

function Element:onSelectStarted(posX, posY)
end

function Element:onSelectEnded(posX, posY)
end

function Element:onClick(posX, posY, button)
end

function Element:onMouseUp(posX, posY, button)
end

function Element:onMouseMove(x, y, dx, dy)
    if self._isDrag then
        self._dx = dx * 50
        self._dy = dy * 50
    end
end

function Element:checkSelect()
    return self._isSelect
end

function Element:checkSelectDraw()
    return self._raycastTarget and self._isSelect
end

function Element:selectDetector(x, y)
    self._isSelect = self._raycastTarget and x > self._drawX and x < self._drawX + self._width and y > self._drawY and
        y < self._drawY + self._height or false
    if self._isSelect then
        self._mouse._selectElement = self
    end
    return self._isSelect
end

function Element:clickDetector(x, y, button)
    local select = self:checkSelect()
    if select then
        self:onClick(self._mouseX, self._mouseY, button)
    end
    return select
end

function Element:unClickDetector(x, y, button)
    local select = self:checkSelect()
    if select then
        self:onMouseUp(self._mouseX, self._mouseY, button)
    end
    return select
end

function Element:mouseMoveDetector(x, y, dx, dy)
    self:onMouseMove(x, y, dx, dy)
end

function Element:updateSizeX()
end

function Element:updateSizeY()
end

function Element:updatePhysics()
    local dt = self._mouse:getDeltaTime()
    self._dx = self._dx * (self._slowdown)
    self._dy = (self._dy + self._gravity) * self._slowdown
    self._posX = self._posX + self._dx * dt
    self._posY = self._posY + self._dy * dt
end

function Element:updateCollider()
    local collideX = false
    local collideY = false
    local parent = self:getParentContainer()
    if parent then
        self._posX, collideX = math.collide(0, self._posX, self._width, parent._width)
        self._posY, collideY = math.collide(0, self._posY, self._height, parent._height)
    end
    if collideX then
        self._dx = -self._dx * self._bounciness
        self._dy = self._dy * self._friction
    end
    if collideY then
        self._dx = self._dx * self._friction
        self._dy = -self._dy * self._bounciness
    end
end

function Element:updateSelect()
    local pastSelect = self._pastIsSelect
    local select = self._isSelect
    if select == pastSelect then
        if select then
            if Testing.jacobToolTip then
                graphics.toolTip(self._title, 20, 350)
            end
            self:onSelect(self._mouseX, self._mouseY)
        end
    else
        if select then
            self:onSelectStarted(self._mouseX, self._mouseY)
        else
            self:onSelectEnded(self._mouseX, self._mouseY)
        end
    end
    self._pastIsSelect = self._isSelect
    self._isSelect = false
end

function Element:updateColors()
    self._currentBorderColor = self._borderColor
    self._currentBackgroundColor = self._backgroundColor
    if self._hasSelected and self:checkSelectDraw() then
        self._currentBorderColor = self._borderColorSelected
        self._currentBackgroundColor = self._backgroundColorSelected
    end
end

function Element:updateCoords()
    self._drawX = self._posX
    self._drawY = self._posY
    local parent = self:getParentContainer()
    if parent then
        self._drawX = self._drawX + parent._drawX
        self._drawY = self._drawY + parent._drawY
    end
    local mX, mY = self._mouse:getPosition()
    self._mouseX = mX - self._drawX
    self._mouseY = mY - self._drawY
end

function Element:update()
    if self._autosizeX then
        self:updateSizeX()
        self._width = math.max(self._width, self._minWidth)
    end
    if self._autosizeY then
        self:updateSizeY()
        self._height = math.max(self._height, self._minHeight)
    end
    if not self._isDrag then
        if self._isPhysical then
            self:updatePhysics()
        end
        if self._isCollider then
            self:updateCollider()
        end
    end
    self:updateCoords()
    self:updateColors()
    self:updateSelect()
end

function Element:drawBackground()
    graphics.fillRect(self._drawX, self._drawY, self._width, self._height, unpack(self._currentBackgroundColor))
end

function Element:drawBorder()
    graphics.drawRect(self._drawX, self._drawY, self._width, self._height, unpack(self._currentBorderColor))
end

function Element:draw()
    if not self._enabled then
        return
    end
    self:drawBackground()
    if self._hasBorder then
        self:drawBorder()
    end
end

-- Abstrct class Container
local Container = extends(Element)

function Container:new(posX, posY, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._elements = {}
    obj._isContainer = true
    obj._raycastTarget = false
    -- update values
    obj._selectElement = obj -- TODO возможно не нужен
    return obj
end

function Container:addElement(element)
    element:setParentContainer(self)
    element:setMouse(self._mouse)
    table.insert(self._elements, element)
end

function Container:removeElement(element)
    element:setParentContainer(nil)
    local index = 1
    table.remove(self._elements, index)
end

function Container:checkSelect()
    --print(self._selectElement == self)
    return Element.checkSelect(self) and self._selectElement == self
end

function Container:setMouse(mouse)
    Element.setMouse(self, mouse)
    for i = 1, #self._elements do
        self._elements[i]:setMouse(mouse)
    end
end

function Container:selectDetector(x, y)
    self._selectElement = self
    for i = 1, #self._elements do
        if self._elements[i]:selectDetector(x, y) then
            self._selectElement = self._elements[i]
            return true
        end
    end
    return Element.selectDetector(self, x, y)
end

function Container:elementUp(index)
    table.insert(self._elements, 1, table.remove(self._elements, index))
end

function Container:clickDetector(x, y, button)
    local signal = Element.clickDetector(self, x, y, button)
    for i = 1, #self._elements do
        if self._elements[i]:clickDetector(x, y, button) then
            if self._elements[i]:getIsContainer() then
                self:elementUp(i)
            end
            return true
        end
    end
    return signal
end

function Container:unClickDetector(x, y, button)
    local signal = Element.unClickDetector(self, x, y, button)
    for i = 1, #self._elements do
        if self._elements[i]:unClickDetector(x, y, button) then
            return true
        end
    end
    return signal
end

function Container:mouseMoveDetector(x, y, dx, dy)
    local signal = Element.mouseMoveDetector(self, x, y, dx, dy)
    for i = 1, #self._elements do
        if self._elements[i]:mouseMoveDetector(x, y, dx, dy) then
            return true
        end
    end
    return signal
end

function Container:onClick(x, y, button)
    Element.onClick(self, x, y, button)
end

function Container:getMaxWidth(elements)
    local maxWidth = 0
    for i = 1, #elements do
        maxWidth = math.max(maxWidth, elements[i]._width)
    end
    return maxWidth
end

function Container:getMaxHeight(elements)
    local maxHeight = 0
    for i = 1, #elements do
        maxHeight = math.max(maxHeight, elements[i]._height)
    end
    return maxHeight
end

function Container:updateSizeX()
    self._width = self:getMaxWidth(self._elements) + self._padding * 2
end

function Container:updateSizeY()
    self._height = self:getMaxHeight(self._elements) + self._padding * 2
end

function Container:updateElements()
    for i = 1, #self._elements do
        self._elements[i]:update()
    end
end

function Container:update()
    Element.update(self)
    self:updateElements()
end

function Container:draw()
    for i = #self._elements, 1, -1 do
        self._elements[i]:draw()
    end
end

-- Class Frame
local Frame = extends(Container)

function Frame:new(posX, posY, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._isPhysical = Testing.physicalFrames
    obj._isCollider = Testing.physicalFrames
    obj._raycastTarget = true
    obj._isMovable = true
    obj._isDrag = false
    return obj
end

function Frame:onClick(x, y, button)
    self:super():onClick(x, y, button)
    self._isDrag = true
end

function Frame:onMouseUp(x, y, button)
    self:super():onClick(x, y, button)
    self._isDrag = false
end

function Frame:onMouseMove(x, y, dx, dy)
    Element.onMouseMove(self, x, y, dx, dy)
    if self._isMovable and self._isDrag then
        self._posX = self._posX + dx
        self._posY = self._posY + dy
    end
end

function Frame:update()
    Container.update(self)
end

function Frame:draw()
    --for k, v in pairs(graphics) do
    --print(k, v)
    --end
    --local x, y, w, h = graphics.setClipRect(self._drawX, self._drawY, self._width, self._height)

    --graphics.setClipRect(x, y, w, h)
    --graphics.toolTip('123', self._mouseX, self._mouseY)
    Element.draw(self)
    Container.draw(self)
end

-- Class VerticalFrame
local VerticalFrame = extends(Frame)

function VerticalFrame:new(posX, posY, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._autosizeX = true
    return obj
end

function VerticalFrame:update()
    local height = self._padding
    for i = 1, #self._elements do
        local element = self._elements[i]
        element._posX = self._padding
        element._posY = height
        height = height + element._height + self._lineHeight
    end
    self._height = height - self._lineHeight + self._padding
    Frame.update(self)
end

-- Class HorizontalFrame
local HorizontalFrame = extends(Frame)

function HorizontalFrame:new(posX, posY, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._autosizeY = true
    return obj
end

function HorizontalFrame:update()
    local width = self._padding
    for i = 1, #self._elements do
        local element = self._elements[i]
        element._posX = width
        element._posY = self._padding
        width = width + element._width + self._lineWidth
    end
    self._width = width - self._lineWidth + self._padding
    Frame.update(self)
end

-- Class GridFrame
local GridFrame = extends(Frame)

function GridFrame:new(posX, posY, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    --obj._autosizeX = true
    obj._autosizeY = true
    return obj
end

function GridFrame:update()
    local width = self._padding
    for i = 1, #self._elements do
        local element = self._elements[i]
        element._posX = width
        element._posY = self._padding
        width = width + element._width + self._lineWidth
    end
    self._width = width - self._lineWidth + self._padding
    Frame.update(self)
end

-- Class TableFrame
local TableFrame = extends(Frame)

function TableFrame:new(posX, posY, sizeX, sizeY, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._sizeX = sizeX or 5
    obj._sizeY = sizeY or 5
    obj._cells = self:getTable2D(obj._sizeX, obj._sizeY)
    obj._columnMaxWidth = self:getValueArray(obj._sizeX, 0)
    obj._columnDrawWidth = self:getValueArray(obj._sizeX, 0)
    obj._rowMaxHeight = self:getValueArray(obj._sizeY, 0)
    obj._rowDrawHeight = self:getValueArray(obj._sizeY, 0)
    obj._autosizeX = true
    obj._autosizeY = true
    return obj
end

function TableFrame:calculateMaxValues()
    for i = 1, self._sizeX do
        self._columnMaxWidth[i] = self:getMaxWidth(self._cells[i])
    end
    for i = 1, self._sizeY do

    end
end

function TableFrame:updateCoords()
    Frame.updateCoords(self)
    self._columnMaxWidth = self:getValueArray(self._sizeX, 0)
    self._columnDrawWidth = self:getValueArray(self._sizeX, 0)
    self._rowMaxHeight = self:getValueArray(self._sizeY, 0)
    self._rowDrawHeight = self:getValueArray(self._sizeY, 0)
end

function TableFrame:update()
    Frame.update(self)
end

function TableFrame:drawTable() -- draw grid. NO ELEMENTS
    for i = 1, self._sizeX do
        --self._columnDrawWidth[i]
        for j = 1, self._sizeY do

        end
    end
end

function TableFrame:draw()
    Frame.draw(self)
    self:drawTable()
end

-- Class Label
local Label = extends(Element)

function Label:new(posX, posY, text, width, height)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._text = text or ''
    obj._textXAlignment = Enum.TextXAlignment.Left
    obj._textYAlignment = Enum.TextYAlignment.Top
    obj._padding = 1
    obj._autosizeX = true
    obj._autosizeY = true
    obj._hasBorder = false
    obj._hasSelected = false
    obj._raycastTarget = false
    obj._textVisible = true
    obj._backgroundColor = { 0, 0, 0, 0 }
    obj._textColor = { 255, 255, 255 }
    obj._textColorSelected = obj._textColor
    obj._currentTextColor = obj._textColor
    -- update values
    obj._textPosX = 0
    obj._textPosY = 0
    obj._textWidth = 0
    obj._textHeight = 0
    return obj
end

function Label:getText()
    return self._text
end

function Label:setText(text)
    self._text = text
end

function Label:updateColors()
    Element.updateColors(self)
    self._currentTextColor = self._hasSelected and self:checkSelect() and self._textColorSelected or self._textColor
end

function Label:updateText()
end

function Label:updateSizeX()
    self._width = self._textWidth + self._padding * 2
end

function Label:updateSizeY()
    self._height = self._textHeight + self._padding * 2
end

function Label:updateCoords()
    Element.updateCoords(self)
    self._textWidth, self._textHeight = graphics.textSize(self._text)
    if self._textXAlignment == Enum.TextXAlignment.Left then
        self._textPosX = self._padding
    elseif self._textXAlignment == Enum.TextXAlignment.Center then
        self._textPosX = (self._width - self._textWidth) / 2
    elseif self._textXAlignment == Enum.TextXAlignment.Right then
        self._textPosX = self._width - (self._textWidth + self._padding)
    end
    if self._textYAlignment == Enum.TextYAlignment.Top then
        self._textPosY = self._padding
    elseif self._textYAlignment == Enum.TextYAlignment.Center then
        self._textPosY = (self._height - self._textHeight) / 2
    elseif self._textYAlignment == Enum.TextYAlignment.Bottom then
        self._textPosY = self._height - (self._textHeight + self._padding)
    end
end

function Label:update()
    self:updateText()
    Element.update(self)
end

function Label:drawText()
    graphics.drawText(self._drawX + self._textPosX, self._drawY + self._textPosY, self._text,
        unpack(self._currentTextColor))
end

function Label:draw()
    Element.draw(self)
    if self._textVisible then
        self:drawText()
    end
end

-- Class ProgressBar
local ProgressBar = extends(Label)

function ProgressBar:new(posX, posY, text, width, height)
    local obj = self:super():new(posX, posY, text, width, height)
    self:registerObject(obj)
    obj._progress = 0
    obj._padding = 3
    obj._title = text
    obj._textXAlignment = Enum.TextXAlignment.Center
    obj._textYAlignment = Enum.TextYAlignment.Center
    obj._backgroundColor = { 50, 50, 100, 255 }
    obj._backgroundColorSelected = obj._backgroundColor
    obj._autosizeX = false
    obj._autosizeY = false
    obj._hasBorder = true
    obj._hasSelected = true
    obj._raycastTarget = true
    obj._textVisible = true
    obj._textColorSelected = { 100, 100, 100 }
    obj._progressRectColor = { 0, 200, 0 }
    obj._progressRectColorSelect = { 200, 200, 0 }
    obj._currentProgressRectColor = obj._progressRectColor
    return obj
end

function ProgressBar:setProgress(value)
    self._progress = math.clamp(0, value, 1)
end

function ProgressBar:updateColors()
    Label.updateColors(self)
    self._currentProgressRectColor = self._hasSelected and self:checkSelect() and self._progressRectColorSelect or
        self._progressRectColor
end

function ProgressBar:update()
    Label.update(self)
    if Testing.progressBarChangeValue then
        self:setProgress((self._progress + 0.005) % 1)
    end
    self._text = math.modf(self._progress * 100) .. '%'
end

function ProgressBar:drawProgressRect()
    graphics.fillRect(self._drawX, self._drawY, self._width * self._progress, self._height,
        unpack(self._currentProgressRectColor))
end

function ProgressBar:draw()
    self:drawBackground()
    self:drawProgressRect()
    if self._textVisible then
        self:drawText()
    end
    self:drawBorder()
end

-- Class Button
local Button = extends(Label)

function Button:new(posX, posY, text, width, height)
    local obj = self:super():new(posX, posY, text, width, height)
    self:registerObject(obj)
    obj._padding = 3
    obj._title = text
    obj._textXAlignment = Enum.TextXAlignment.Center
    obj._textYAlignment = Enum.TextYAlignment.Center
    obj._autosizeX = false
    obj._autosizeY = false
    obj._hasBorder = true
    obj._hasSelected = true
    obj._raycastTarget = true
    obj._borderColor = { 255, 255, 255 }
    obj._borderColorSelected = obj._borderColor
    obj._backgroundColor = { 100, 100, 200 }
    obj._backgroundColorSelected = { 200, 200, 0 }
    obj._textColor = { 255, 255, 255 }
    obj._textColorSelected = obj._textColor
    return obj
end

function Button:update()
    Label.update(self)
end

function Button:draw()
    Label.draw(self)
end

-- Class CheckBox
local CheckBox = extends(Button)

function CheckBox:new(posX, posY, text)
    local obj = self:super():new(posX, posY, text or 'Test 2', 15, 15)
    self:registerObject(obj)
    obj._textVisible = true -- TODO temp
    --obj._textXAlignment = Enum.TextXAlignment.Left
    obj._textYAlignment = Enum.TextYAlignment.Center
    obj._lineWidth = 2
    obj._value = false
    obj._borderColor = { 200, 200, 200 }
    obj._borderColorSelected = { 200, 200, 100 }
    obj._backgroundColor = { 50, 50, 50 }
    obj._backgroundColorSelected = obj._backgroundColor
    obj._textColor = { 255, 255, 255 }
    obj._textColorSelected = obj._textColor
    obj._valueColor = { 200, 200, 200, 255 }
    obj._valueColorSelect = { 255, 255, 255, 255 }
    obj._currentValueColor = obj._valueColor
    return obj
end

function CheckBox:onClick()
    self._value = not self._value
end

function CheckBox:updateColors()
    Button.updateColors(self)
    self._currentValueColor = self._hasSelected and self:checkSelect() and self._valueColorSelect or
        self._valueColor
end

function CheckBox:updateCoords()
    Button.updateCoords(self)
    self._textPosX = self._width + self._lineWidth
end

function CheckBox:drawValue()
    graphics.fillRect(self._drawX + 5, self._drawY + 5, self._width - 10, self._height - 10,
        unpack(self._currentValueColor))
end

function CheckBox:draw()
    Button.draw(self)
    if self._value then
        self:drawValue()
    end
end

-- Class The powder toy Button
local TPTButton = extends(Button)

function TPTButton:new(elementID)
    local elementTable = elements.element(elementID)
    local name = elementTable.Name
    local obj = self:super():new(0, 0, name, 30, 15)
    self:registerObject(obj)
    obj._elementID = elementID
    obj._identifier = elementTable.Identifier
    obj._title = elementTable.Description
    obj._name = name
    obj._padding = 3
    obj._backgroundColor = { graphics.getColors(elementTable.Colour) }
    obj._backgroundColor[4] = nil -- fix problem Cracker1000 mod
    obj._backgroundColorSelected = obj._backgroundColor
    obj._textColor = { 0, 0, 0 }
    obj._textColorSelected = obj._textColor
    obj._borderColor = { 0, 0, 0 }
    obj._borderColorSelected = { 255, 0, 0 }
    obj._hasBorder = true
    obj._hasSelected = true
    return obj
end

function TPTButton:onClick(posX, posY, button)
    if button == 1 then
        tpt.selectedl = self._identifier
    end
    if button == 2 then
        tpt.selecteda = self._identifier
    end
    if button == 3 then
        tpt.selectedr = self._identifier
    end
end

function TPTButton:checkSelectDraw()
    local isSelect = true
    self._borderColorSelected = { 255, 0, 0 }
    if tpt.selectedl == self._identifier then
        self._borderColorSelected = { 255, 0, 0 }
    elseif tpt.selectedr == self._identifier then
        self._borderColorSelected = { 0, 0, 255 }
    elseif tpt.selecteda == self._identifier then
        self._borderColorSelected = { 0, 255, 0 }
    else
        isSelect = false
    end
    return Element.checkSelectDraw(self) or isSelect
end

-- Class MovableElement. TEST CLASS
MovableElement = extends(Frame)

function MovableElement:new(posX, posY, width, height, speed)
    local obj = self:super():new(posX, posY, width, height)
    self:registerObject(obj)
    obj._speed = speed or 1
    obj._right = true
    obj._up = true
    return obj
end

function MovableElement:update()
    Frame.update(self)
    if self._isDrag then
        return
    end
    local parent = self:getParentContainer()
    if self._posX < 0 then
        self._right = true
    elseif self._posX + self._width >= parent._width then
        self._right = false
    end
    if self._posY < 0 then
        self._up = true
    elseif self._posY + self._height >= parent._height then
        self._up = false
    end
    self._posX = self._posX + (self._right and self._speed or -self._speed)
    self._posY = self._posY + (self._up and self._speed or -self._speed)
end

-- Class ToolTip
local ToolTip = extends(VerticalFrame)

function ToolTip:new()
    local obj = self:super():new(0, 0, 200, 100)
    self:registerObject(obj)
    obj._titleLabel = Label:new(0, 0, "", 150, 100)
    obj:addElement(obj._titleLabel)
    --self._textVisible = false
    return obj
end

function ToolTip:update()
    VerticalFrame.update(self)
    self._title = ""
    local target = self._mouse._selectElement
    if target then
        if type(target._title) == "string" then
            self._title = target._title
        end
    end
    self._titleLabel:setText(self._title)
    local mx, my = self._mouse:getPosition()
    self:setPosition(mx + 5, my)
    self._enabled = self._title ~= ""
end

-- Class Mouse
local Mouse = extends(Object)

function Mouse:new()
    local obj = self:super():new()
    self:registerObject(obj)
    obj._posX = 0
    obj._posY = 0
    obj._dt = 1 / 60
    obj._tick = function()
        obj:update()
        obj:draw()
    end
    obj._mousemove = function(x, y)
        obj._posX = x
        obj._posY = y
    end
    obj:run()
    return obj
end

function Mouse:getPosition()
    return self._posX, self._posY
end

function Mouse:getDeltaTime()
    return self._dt
end

function Mouse:update()
end

function Mouse:draw()
end

function Mouse:run()
    if not self._isWorks then
        self._isWorks = true
        event.register(event.tick, self._tick)
        event.register(event.mousemove, self._mousemove)
    end
end

function Mouse:stop()
    if self._isWorks then
        self._isWorks = false
        event.unregister(event.tick, self._tick)
        event.unregister(event.mousemove, self._mousemove)
    end
end

-- Class Engine
local Engine = extends(Container)

function Engine:new(width, height)
    local obj = self:super():new(0, 0, width or sim.XRES, height or sim.YRES)
    self:registerObject(obj)
    obj._toolTip = ToolTip:new()
    obj._isWorks = false
    obj._tick = function()
        obj:update()
        obj._toolTip:update()
        obj:draw()
        obj._toolTip:draw()
    end
    obj._mouseDown = function(x, y, button)
        return not obj:clickDetector(x, y, button)
    end
    obj._mouseUp = function(x, y, button)
        return not obj:unClickDetector(x, y, button)
    end
    obj._mouseMove = function(x, y, dx, dy)
        return not obj:mouseMoveDetector(x, y, dx, dy)
    end
    obj:setMouse(Mouse:new())
    obj:run()
    return obj
end

function Engine:setMouse(mouse)
    self:super().setMouse(self, mouse)
    self._toolTip:setMouse(mouse)
end

function Engine:update()
    if Testing.printEveryTick then
        print()
    end
    self._mouse._selectElement = false
    self:super().update(self)
    local mX, mY = self._mouse:getPosition()
    self:selectDetector(mX, mY)
end

function Engine:getStatus()
    return self._isWorks
end

function Engine:run()
    if not self._isWorks then
        self._isWorks = true
        event.register(event.tick, self._tick)
        event.register(event.mousedown, self._mouseDown)
        event.register(event.mouseup, self._mouseUp)
        event.register(event.mousemove, self._mouseMove)
        --event.register(event.mousewheel)
        --event.register(event.keypress)
        --event.register(event.keyrelease)
    end
end

function Engine:stop()
    if self._isWorks then
        self._isWorks = false
        event.unregister(event.tick, self._tick)
        event.unregister(event.mousedown, self._mouseDown)
        event.unregister(event.mouseup, self._mouseUp)
        event.unregister(event.mousemove, self._mouseMove)
    end
end

-- Program
local engine = Engine:new()
local mouse = engine:getMouse()

local labelName = Label:new()
local labelTemp = Label:new()
local labelTmp = Label:new()
local labelTmp2 = Label:new()
local labelTmp3 = Label:new()
local labelTmp4 = Label:new()

--[[
local func = labelName.update
function labelName:update()
    print(self._posX, self._posY)
    func(self)

end
--]]
local BUTTON_SIZE_X = 40
local BUTTON_SIZE_Y = 15
local button1 = Button:new(10, 40, 'Play', BUTTON_SIZE_X, BUTTON_SIZE_Y)
local button2 = Button:new(10, 60, 'Stop', BUTTON_SIZE_X, BUTTON_SIZE_Y)
local button3 = Button:new(10, 80, 'Pause', BUTTON_SIZE_X, BUTTON_SIZE_Y)
local tptbutton1 = TPTButton:new(elements.DEFAULT_PT_METL)
local tptbutton2 = TPTButton:new(elements.DEFAULT_PT_SPRK)
local tptbutton3 = TPTButton:new(elements.DEFAULT_PT_LAVA)
local tptbutton4 = TPTButton:new(elements.DEFAULT_PT_WATR)
local tptbutton5 = TPTButton:new(elements.DEFAULT_PT_FILT)
local progressBar1 = ProgressBar:new(0, 0, 0, 100, 15)
local checkbox1 = CheckBox:new()
local tableFrame1 = TableFrame:new(100, 100, 10, 10)
function button1:onClick()
    labelName:setText('Play')
end

function button2:onClick()
    labelName:setText('Stop')
end

function button3:onClick()
    labelName:setText('Pause')
end

local frame = VerticalFrame:new(20, 20, 100, 100)
frame:setLineHeight(0)
frame:setPadding(20)
frame:addElement(labelName)
frame:addElement(labelTemp)
frame:addElement(labelTmp)
frame:addElement(labelTmp2)
frame:addElement(labelTmp3)
frame:addElement(labelTmp4)
frame:addElement(button1)
frame:addElement(button2)
frame:addElement(button3)
frame:addElement(tptbutton1)
frame:addElement(tptbutton2)
frame:addElement(tptbutton3)
frame:addElement(tptbutton4)
frame:addElement(tptbutton5)
frame:addElement(checkbox1)
frame:addElement(progressBar1)

local frameElements = GridFrame:new(400, 20, 100, 100)
for id = 1, 3 do
    frameElements:addElement(TPTButton:new(id))
end

local frameElements2 = VerticalFrame:new(200, 20, 100, 100)
for id = 11, 15 do
    frameElements2:addElement(TPTButton:new(id))
end

local movableFrame = MovableElement:new(10, 10, 100, 200)

local frameElementInfo = VerticalFrame:new(10, 10)

engine:addElement(frame)
engine:addElement(frameElements)
engine:addElement(frameElements2)
engine:addElement(tableFrame1)

if Testing.movableFrame then
    engine:addElement(movableFrame)
end

function mouse:update()
    local x, y = sim.adjustCoords(self._posX, self._posY)
    local id = sim.partID(x, y)
    if id then
        local elementTable = elements.element(sim.partProperty(id, sim.FIELD_TYPE))
        local name = elementTable.Name
        local temp = sim.partProperty(id, sim.FIELD_TEMP)
        local tmp = sim.partProperty(id, sim.FIELD_TMP)
        local tmp2 = sim.partProperty(id, sim.FIELD_TMP2)
        local tmp3 = sim.partProperty(id, sim.FIELD_TMP3)
        local tmp4 = sim.partProperty(id, sim.FIELD_TMP4)
        labelName:setText('Name: ' .. name)
        labelTemp:setText('Temp: ' .. math.modf(temp - 273.15))
        labelTmp:setText('Tmp: ' .. tmp)
        labelTmp2:setText('Tmp2: ' .. tmp2)
        labelTmp3:setText('Tmp3: ' .. tmp3)
        labelTmp4:setText('Tmp4: ' .. tmp4)
    else
        labelName:setText('Name: None')
        labelTemp:setText('Temp: None')
        labelTmp:setText('Tmp: None')
        labelTmp2:setText('Tmp2: None')
        labelTmp3:setText('Tmp3: None')
        labelTmp4:setText('Tmp4: None')
    end
end

--local moveElem = MovableElement(30, 30, 300, 200, 0)
--moveElem:addElement(frame1)
