local UILibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Creates a unique ScreenGui for each window instance
local function CreateBaseGui(windowId)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "" .. windowId
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    return ScreenGui
end

-- Creates a draggable and resizable window with a modern Tab System
function UILibrary:CreateWindow(title)
    local windowId = tostring(math.random(1000, 9999))
    local ScreenGui = CreateBaseGui(windowId)
    
    -- Outer Frame (draggable with shadow)
    local OuterFrame = Instance.new("Frame")
    OuterFrame.Size = UDim2.new(0, 400, 0, 500) -- Adjusted size: 400x500
    OuterFrame.Position = UDim2.new(0.5, -200 + math.random(-50, 50), 0.5, -250 + math.random(-50, 50)) -- Adjusted position
    OuterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    OuterFrame.BorderSizePixel = 0
    local OuterCorner = Instance.new("UICorner")
    OuterCorner.CornerRadius = UDim.new(0, 12)
    OuterCorner.Parent = OuterFrame
    local OuterStroke = Instance.new("UIStroke")
    OuterStroke.Color = Color3.fromRGB(50, 50, 50)
    OuterStroke.Thickness = 2
    OuterStroke.Parent = OuterFrame
    OuterFrame.Parent = ScreenGui

    -- Inner Window
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(1, -10, 1, -10)
    Window.Position = UDim2.new(0, 5, 0, 5)
    Window.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Window.BorderSizePixel = 0
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(0, 8)
    InnerCorner.Parent = Window
    Window.Parent = OuterFrame

    -- Gradient background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))}
    Gradient.Parent = Window

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.BorderSizePixel = 0
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    TitleBar.Parent = Window

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = title or "Nini UI"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Dragging OuterFrame
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = OuterFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            OuterFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Resize Button
    local ResizeButton = Instance.new("TextButton")
    ResizeButton.Size = UDim2.new(0, 20, 0, 20)
    ResizeButton.Position = UDim2.new(1, -25, 1, -25)
    ResizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ResizeButton.Text = "↔"
    ResizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResizeButton.Font = Enum.Font.SourceSans
    ResizeButton.TextSize = 14
    local ResizeCorner = Instance.new("UICorner")
    ResizeCorner.CornerRadius = UDim.new(0, 4)
    ResizeCorner.Parent = ResizeButton
    ResizeButton.Parent = OuterFrame

    -- Resizing functionality
    local resizing, resizeStart, startSize
    ResizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = OuterFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    ResizeButton.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and resizing then
            local delta = input.Position - resizeStart
            local newWidth = math.max(300, startSize.X.Offset + delta.X)
            local newHeight = math.max(350, startSize.Y.Offset + delta.Y) -- Adjusted min height to 350
            OuterFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    -- Tab Container (left side)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -35)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = Window

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer

    -- Content Container (right side)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -120, 1, -35)
    ContentContainer.Position = UDim2.new(0, 120, 0, 35)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Window

    local tabs = {}
    local currentTab = nil

    -- Function to create a new tab
    local function CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.Position = UDim2.new(0, 5, 0, 0)
        TabButton.Text = tabName
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Color3.fromRGB(60, 60, 60)
        TabStroke.Thickness = 1
        TabStroke.Parent = TabButton
        TabButton.Parent = TabContainer

        -- Hover effect
        TabButton.MouseEnter:Connect(function()
            if currentTab ~= TabButton then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if currentTab ~= TabButton then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            end
        end)

        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentContainer

        local ContentListLayout = Instance.new("UIListLayout")
        ContentListLayout.Padding = UDim.new(0, 5)
        ContentListLayout.Parent = TabContent

        TabButton.MouseButton1Click:Connect(function()
            if currentTab ~= TabContent then
                if currentTab then
                    currentTab.Visible = false
                end
                TabContent.Visible = true
                currentTab = TabContent
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                for _, otherTab in pairs(tabs) do
                    if otherTab.Button ~= TabButton then
                        TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
                    end
                end
            end
        end)

        table.insert(tabs, {Button = TabButton, Content = TabContent})
        return TabContent
    end

    return { Window = Window, OuterFrame = OuterFrame, CreateTab = CreateTab }
end

-- Creates a customizable button
function UILibrary:CreateButton(container, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Text = text or "Button"
    Button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Parent = Button
    Button.Parent = container

    -- Hover effect
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
    end)

    Button.MouseButton1Click:Connect(callback or function() print("Button clicked!") end)
    return Button
end

-- Creates a toggle switch
function UILibrary:CreateToggle(container, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.Text = text or "Toggle"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 24, 0, 24)
    Toggle.Position = UDim2.new(1, -30, 0.5, -12)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    Toggle.Text = ""
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Toggle
    Toggle.Parent = ToggleFrame

    local state = default or false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)}):Play()
        if callback then callback(state) end
    end)

    return ToggleFrame
end

-- Creates a slider (supports Mobile and PC)
function UILibrary:CreateSlider(container, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = text or "Slider"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 10)
    SliderBar.Position = UDim2.new(0, 0, 0, 25)
    SliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = SliderBar
    SliderBar.Parent = SliderFrame

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    SliderButton.Text = ""
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 9)
    ButtonCorner.Parent = SliderButton
    SliderButton.Parent = SliderBar

    local value = default or min
    local function UpdateSlider(input)
        local relativePos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relativePos
        SliderButton.Position = UDim2.new(relativePos, -9, 0, -4)
        if callback then callback(math.floor(value)) end
    end

    SliderButton.Position = UDim2.new((default - min) / (max - min), -9, 0, -4)

    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(input)
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end)

    return SliderFrame
end

-- Creates a text input box
function UILibrary:CreateTextBox(container, placeholder, callback)
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Size = UDim2.new(1, -10, 0, 35)
    TextBoxFrame.BackgroundTransparency = 1
    TextBoxFrame.Parent = container

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholder or "Enter text..."
    TextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = TextBox
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Parent = TextBox
    TextBox.Parent = TextBoxFrame

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(TextBox.Text)
        end
    end)

    return TextBoxFrame
end

-- Creates a dropdown menu
function UILibrary:CreateDropdown(container, text, options, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = container

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Text = text or "Dropdown"
    DropdownButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 14
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = DropdownButton
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Parent = DropdownButton
    DropdownButton.Parent = DropdownFrame

    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
    DropdownList.Position = UDim2.new(0, 0, 1, 5)
    DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DropdownList.Visible = false
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList
    local ListStroke = Instance.new("UIStroke")
    ListStroke.Color = Color3.fromRGB(70, 70, 70)
    ListStroke.Thickness = 1
    ListStroke.Parent = DropdownList
    DropdownList.Parent = DropdownFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownList

    for _, option in pairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Text = option
        OptionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.Parent = DropdownList

        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
        end)

        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = option
            DropdownList.Visible = false
            if callback then callback(option) end
        end)
    end

    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
    end)

    return DropdownFrame
end

return UILibrary
