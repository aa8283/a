local UILibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Creates a unique ScreenGui for each window instance
local function CreateBaseGui(windowId)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "" .. windowId -- Unique name to avoid conflicts
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    return ScreenGui
end

-- Creates a draggable window with a Tab System on the left
function UILibrary:CreateWindow(title)
    local windowId = tostring(math.random(1000, 9999)) -- Unique ID for each window
    local ScreenGui = CreateBaseGui(windowId)
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 450, 0, 550)
    Window.Position = UDim2.new(0.5, -225 + math.random(-50, 50), 0.5, -275 + math.random(-50, 50)) -- Slight offset to avoid overlap
    Window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Window.BorderSizePixel = 0
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Window
    Window.Parent = ScreenGui

    -- Gradient background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))}
    Gradient.Parent = Window

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    TitleBar.Parent = Window

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = title or "Nini UI"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
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
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab Container (left side)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -30)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = Window

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer

    -- Content Container (right side)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -120, 1, -30)
    ContentContainer.Position = UDim2.new(0, 120, 0, 30)
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
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        TabButton.Parent = TabContainer

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
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                for _, otherTab in pairs(tabs) do
                    if otherTab.Button ~= TabButton then
                        TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    end
                end
            end
        end)

        table.insert(tabs, {Button = TabButton, Content = TabContent})
        return TabContent
    end

    return { Window = Window, CreateTab = CreateTab }
end

-- Creates a customizable button
function UILibrary:CreateButton(container, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.Text = text or "Button"
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(70, 70, 70)
    Stroke.Thickness = 1
    Stroke.Parent = Button
    Button.Parent = container

    Button.MouseButton1Click:Connect(callback or function() print("Button clicked!") end)
    return Button
end

-- Creates a toggle switch
function UILibrary:CreateToggle(container, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
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
    Toggle.Size = UDim2.new(0, 20, 0, 20)
    Toggle.Position = UDim2.new(1, -25, 0.5, -10)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Toggle.Text = ""
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Toggle
    Toggle.Parent = ToggleFrame

    local state = default or false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)}):Play()
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
    SliderBar.Size = UDim2.new(1, 0, 0, 8)
    SliderBar.Position = UDim2.new(0, 0, 0, 25)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = SliderBar
    SliderBar.Parent = SliderFrame

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    SliderButton.Text = ""
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = SliderButton
    SliderButton.Parent = SliderBar

    local value = default or min
    local function UpdateSlider(input)
        local relativePos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relativePos
        SliderButton.Position = UDim2.new(relativePos, -8, 0, -4)
        if callback then callback(math.floor(value)) end
    end

    SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -4)

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
    TextBoxFrame.Size = UDim2.new(1, -10, 0, 30)
    TextBoxFrame.BackgroundTransparency = 1
    TextBoxFrame.Parent = container

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholder or "Enter text..."
    TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = TextBox
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
    DropdownFrame.Size = UDim2.new(1, -10, 0, 30)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = container

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Text = text or "Dropdown"
    DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 14
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = DropdownButton
    DropdownButton.Parent = DropdownFrame

    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, #options * 25)
    DropdownList.Position = UDim2.new(0, 0, 1, 5)
    DropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownList.Visible = false
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList
    DropdownList.Parent = DropdownFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownList

    for _, option in pairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.Text = option
        OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.Parent = DropdownList

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