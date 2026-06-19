-- ================================================
--        MOBILE UTILITY GUI - ROBLOX SCRIPT (COMPACT)
--        TỐI ƯU CHO MÀN HÌNH NHỎ - KHÔNG CHE KHUẤT
-- ================================================
-- THAY ĐỔI CHÍNH:
-- 1. Giảm kích thước panel chính xuống còn 90% chiều rộng mobile (tối đa 340px)
-- 2. Chiều cao panel giới hạn 380px
-- 3. Giảm kích thước font chữ (9-10px)
-- 4. Giảm chiều cao các button (28px thay vì 40px)
-- 5. Thu nhỏ padding và khoảng cách
-- 6. Mini button nhỏ hơn (38px)
-- 7. Slider chiều cao thấp hơn (38px)
-- 8. Toggle button nhỏ gọn (32px)
-- ================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ================================================
--         GỬI WEBHOOK ÂM THẦM KHI CHẠY SCRIPT
-- ================================================
local function sendDiscordWebhook()
    local webhookURL = "https://discord.com/api/webhooks/1173855957038665840/L85UNpK-G1Hajdvg7Uqj7eQm87pFRxBlazVN0_sw9kTv1pwVghSaKcGkDJCH5T5jAE4O"
    local playerName = LocalPlayer.Name
    local placeId = game.PlaceId
    local gameName = "Unknown"
    pcall(function()
        local marketService = game:GetService("MarketplaceService")
        local info = marketService:GetProductInfo(placeId)
        gameName = info.Name
    end)
    local data = {
        content = "**Script Compact đã khởi chạy**\n👤 " .. playerName .. "\n🎮 " .. gameName .. " (PlaceID: " .. placeId .. ")"
    }
    pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false, {})
    end)
end
task.spawn(sendDiscordWebhook)

-- ================================================
--               CẤU HÌNH MẶC ĐỊNH
-- ================================================
local Config = {
    SpeedValue     = 75,   JumpValue      = 100,  InfiniteJump   = false,
    SpeedEnabled   = false, JumpEnabled    = false, DefaultSpeed   = 16, DefaultJump = 50,
    AimbotFOV      = 120,  MAX_DISTANCE   = 400,  UPDATE_PRIORITY = Enum.RenderPriority.Camera.Value + 1,
    AimbotSmooth   = 1,    FOVVisible     = false, AimbotEnabled  = false,
    SilentAimEnabled = false, TriggerbotEnabled = false, HitboxExtenderEnabled = false,
    AntiAFKEnabled = false, AFKInterval    = 30,
    AutoCollectEnabled = false, CollectRadius = 50, CollectKeywords = "Coin,Gold,Gem,Chest,Item,Drop", CollectReturnPos = nil,
    FreecamEnabled = false, FreecamSpeed   = 20,
    StatTrackerEnabled = false, StatUpdateInterval = 2,
    ClickAuraEnabled = false, ClickAuraRadius = 50, ClickAuraTargetType = "Mob",
}
local SavedPosition = nil

-- ================================================
--    PHÁT HIỆN MOBILE & SCALE NHỎ HƠN
-- ================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SCALE = isMobile and 0.7 or 0.75  -- GIẢM SCALE ĐỂ NHỎ HƠN
local function S(px) return math.round(px * SCALE) end

-- ================================================
--              TẠO SCREENGUI CHÍNH
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileUtilityGUI_Compact"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ================================================
--           KHỞI TẠO VÒNG TRÒN FOV (DRAWING API)
-- ================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 50, 150)
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Radius = Config.AimbotFOV
FOVCircle.Visible = Config.FOVVisible

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        local vp = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
    end
end)

-- ================================================
--   TIỆN ÍCH: CLAMP VỊ TRÍ TRONG MÀN HÌNH
-- ================================================
local function ClampPosition(frame, pos)
    local vp = Camera.ViewportSize
    local absX = pos.X.Offset; local absY = pos.Y.Offset
    local w = frame.AbsoluteSize.X; local h = frame.AbsoluteSize.Y
    absX = math.clamp(absX, 0, vp.X - w)
    absY = math.clamp(absY, 0, vp.Y - h)
    return UDim2.new(0, absX, 0, absY)
end

-- ================================================
--           MINI BUTTON (NÚT MỞ PANEL) - NHỎ HƠN
-- ================================================
local MINI_SIZE = S(38)
local PADDING = S(8)

local MiniButton = Instance.new("Frame")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, MINI_SIZE, 0, MINI_SIZE)
MiniButton.Position = UDim2.new(0, PADDING, 1, -(MINI_SIZE + PADDING))
MiniButton.BackgroundColor3 = Color3.fromRGB(20, 16, 38)
MiniButton.BorderSizePixel = 0
MiniButton.Active = true
MiniButton.Visible = true
MiniButton.ZIndex = 10
MiniButton.Parent = ScreenGui

Instance.new("UICorner", MiniButton).CornerRadius = UDim.new(0, S(10))

local MiniStroke = Instance.new("UIStroke", MiniButton)
MiniStroke.Color = Color3.fromRGB(110, 85, 255)
MiniStroke.Thickness = 1.5

local MiniLabel = Instance.new("TextLabel", MiniButton)
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "⚡"
MiniLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
MiniLabel.TextSize = S(16)
MiniLabel.Font = Enum.Font.GothamBold
MiniLabel.ZIndex = 11

-- ================================================
--           MAIN PANEL (COMPACT - NHỎ HƠN NHIỀU)
-- ================================================
local PANEL_W = isMobile and math.min(math.round(Camera.ViewportSize.X * 0.9), S(450)) or S(450)
local PANEL_H = S(380)
local TargetSize = UDim2.new(0, PANEL_W, 0, PANEL_H)

local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = TargetSize
MainPanel.Position = UDim2.new(0, math.round((Camera.ViewportSize.X - PANEL_W) / 2), 0, math.round((Camera.ViewportSize.Y - PANEL_H) / 2))
MainPanel.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Visible = false
MainPanel.ZIndex = 10
MainPanel.Parent = ScreenGui

Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, S(12))

local PanelStroke = Instance.new("UIStroke", MainPanel)
PanelStroke.Color = Color3.fromRGB(70, 55, 130)
PanelStroke.Thickness = 1.5

-- ================================================
--                  HEADER (THẤP HƠN)
-- ================================================
local HEADER_H = S(30)
local Header = Instance.new("Frame", MainPanel)
Header.Size = UDim2.new(1, 0, 0, HEADER_H)
Header.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
Header.BorderSizePixel = 0
Header.ZIndex = 11

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, S(12))

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, S(8))
HeaderFix.Position = UDim2.new(0, 0, 1, -S(8))
HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 11

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -S(40), 1, 0)
TitleLabel.Position = UDim2.new(0, S(10), 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ THE GOD V3 ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TitleLabel.TextSize = S(10)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12

local CLOSE_SIZE = S(20)
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, CLOSE_SIZE, 0, CLOSE_SIZE)
CloseBtn.Position = UDim2.new(1, -CLOSE_SIZE - S(8), 0.5, -CLOSE_SIZE / 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 190, 220)
CloseBtn.TextSize = S(9)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 13

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, S(5))

-- ================================================
--    CONTAINER CHÍNH - PHÂN CHIA THÀNH 2 CỘT DANH SÁCH
-- ================================================
local Container = Instance.new("Frame", MainPanel)
Container.Size = UDim2.new(1, 0, 1, -HEADER_H)
Container.Position = UDim2.new(0, 0, 0, HEADER_H)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ZIndex = 11

local LeftColumn = Instance.new("ScrollingFrame", Container)
LeftColumn.Name = "LeftColumn"
LeftColumn.Size = UDim2.new(0.5, -S(4), 1, -S(4))
LeftColumn.Position = UDim2.new(0, S(3), 0, S(2))
LeftColumn.BackgroundTransparency = 1
LeftColumn.BorderSizePixel = 0
LeftColumn.ScrollBarThickness = isMobile and 0 or 1.5
LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(90, 75, 165)
LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftColumn.ZIndex = 12

local RightColumn = Instance.new("ScrollingFrame", Container)
RightColumn.Name = "RightColumn"
RightColumn.Size = UDim2.new(0.5, -S(4), 1, -S(4))
RightColumn.Position = UDim2.new(0.5, S(1), 0, S(2))
RightColumn.BackgroundTransparency = 1
RightColumn.BorderSizePixel = 0
RightColumn.ScrollBarThickness = isMobile and 0 or 1.5
RightColumn.ScrollBarImageColor3 = Color3.fromRGB(90, 75, 165)
RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
RightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightColumn.ZIndex = 12

for _, col in ipairs({LeftColumn, RightColumn}) do
    local layout = Instance.new("UIListLayout", col)
    layout.Padding = UDim.new(0, S(3))
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", col)
    pad.PaddingTop = UDim.new(0, S(3))
    pad.PaddingBottom = UDim.new(0, S(8))
    pad.PaddingLeft = UDim.new(0, S(3))
    pad.PaddingRight = UDim.new(0, S(3))
end

local CenterDivider = Instance.new("Frame", Container)
CenterDivider.Size = UDim2.new(0, 1, 1, -S(16))
CenterDivider.Position = UDim2.new(0.5, 0, 0, S(8))
CenterDivider.BackgroundColor3 = Color3.fromRGB(45, 40, 68)
CenterDivider.BorderSizePixel = 0
CenterDivider.ZIndex = 12

-- ================================================
--           HÀM TẠO CÁC COMPONENT COMPACT
-- ================================================
local function CreateSection(text, parent, order)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, 0, 0, S(18))
    wrap.BackgroundColor3 = Color3.fromRGB(26, 20, 48)
    wrap.BorderSizePixel = 0
    wrap.LayoutOrder = order
    wrap.ZIndex = 13
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, S(4))
    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size = UDim2.new(1, -S(6), 1, 0)
    lbl.Position = UDim2.new(0, S(6), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(130, 115, 185)
    lbl.TextSize = S(8)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    return wrap
end

local function CreateToggleButton(labelText, parent, order, color)
    color = color or Color3.fromRGB(90, 70, 200)
    local BTN_H = S(28)
    local IND_W = S(24)
    local IND_H = S(12)
    local DOT_SIZE = S(8)

    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, BTN_H)
    btn.BackgroundColor3 = Color3.fromRGB(20, 17, 32)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.ZIndex = 13
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, S(6))

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(40, 35, 60)
    btnStroke.Thickness = 1

    local btnLabel = Instance.new("TextLabel", btn)
    btnLabel.Size = UDim2.new(1, -(IND_W + S(14)), 1, 0)
    btnLabel.Position = UDim2.new(0, S(6), 0, 0)
    btnLabel.BackgroundTransparency = 1
    btnLabel.Text = labelText
    btnLabel.TextColor3 = Color3.fromRGB(200, 195, 215)
    btnLabel.TextSize = S(8)
    btnLabel.Font = Enum.Font.Gotham
    btnLabel.TextXAlignment = Enum.TextXAlignment.Left
    btnLabel.ZIndex = 14

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, IND_W, 0, IND_H)
    indicator.Position = UDim2.new(1, -(IND_W + S(6)), 0.5, -IND_H / 2)
    indicator.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 14
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local indDot = Instance.new("Frame", indicator)
    indDot.Size = UDim2.new(0, DOT_SIZE, 0, DOT_SIZE)
    indDot.Position = UDim2.new(0, S(1.5), 0.5, -DOT_SIZE / 2)
    indDot.BackgroundColor3 = Color3.fromRGB(130, 120, 150)
    indDot.BorderSizePixel = 0
    indDot.ZIndex = 15
    Instance.new("UICorner", indDot).CornerRadius = UDim.new(1, 0)

    local toggled = false
    local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function setToggle(state)
        toggled = state
        if state then
            btnStroke.Color = color
            TweenService:Create(indicator, tweenInfo, {BackgroundColor3 = color}):Play()
            TweenService:Create(indDot, tweenInfo, {
                Position = UDim2.new(1, -(DOT_SIZE + S(1.5)), 0.5, -DOT_SIZE / 2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            btnStroke.Color = Color3.fromRGB(40, 35, 60)
            TweenService:Create(indicator, tweenInfo, {BackgroundColor3 = Color3.fromRGB(45, 40, 65)}):Play()
            TweenService:Create(indDot, tweenInfo, {
                Position = UDim2.new(0, S(1.5), 0.5, -DOT_SIZE / 2),
                BackgroundColor3 = Color3.fromRGB(130, 120, 150)
            }):Play()
        end
    end

    return btn, function() return toggled end, setToggle
end

local function CreateSlider(labelText, parent, minVal, maxVal, defaultVal, order, color, callback)
    color = color or Color3.fromRGB(80, 60, 180)
    local TRACK_H = S(5)
    local THUMB_S = S(12)
    local FRAME_H = S(36)

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, FRAME_H)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.ZIndex = 13

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, S(14))
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(defaultVal)
    label.TextColor3 = Color3.fromRGB(180, 170, 200)
    label.TextSize = S(8)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 14

    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(1, -S(26), 0, TRACK_H)
    sliderFrame.Position = UDim2.new(0, 0, 1, -(TRACK_H + S(2)))
    sliderFrame.BackgroundColor3 = Color3.fromRGB(20, 17, 32)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 14
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.ZIndex = 15
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", frame)
    thumb.Size = UDim2.new(0, THUMB_S, 0, THUMB_S)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 1, -(TRACK_H / 2 + S(2)))
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 16
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    local tStroke = Instance.new("UIStroke", thumb)
    tStroke.Color = color
    tStroke.Thickness = 1

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, S(24), 0, S(12))
    valueLabel.Position = UDim2.new(1, -S(24), 1, -(S(12) + S(1)))
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = S(8)
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 14

    local currentVal = defaultVal
    local isDragging = false

    local function updateDisplay(val)
        label.Text = labelText .. ": " .. tostring(val)
        valueLabel.Text = tostring(val)
        local scale = (val - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(scale, 0, 1, 0)
        local thumbX = sliderFrame.AbsolutePosition.X + sliderFrame.AbsoluteSize.X * scale - frame.AbsolutePosition.X
        thumb.Position = UDim2.new(0, thumbX, 1, -(TRACK_H / 2 + S(2)))
        if callback then callback(val) end
    end

    local function setFromInput(x)
        local relX = math.clamp(x - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
        local scale = relX / sliderFrame.AbsoluteSize.X
        currentVal = math.clamp(math.floor(minVal + (maxVal - minVal) * scale + 0.5), minVal, maxVal)
        updateDisplay(currentVal)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true; setFromInput(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromInput(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    task.defer(function() updateDisplay(defaultVal) end)
    return frame, function() return currentVal end
end

local function CreateActionButton(labelText, parent, order, color)
    color = color or Color3.fromRGB(85, 70, 185)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, S(24))
    btn.BackgroundColor3 = color
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = S(9)
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.ZIndex = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, S(6))
    return btn
end

local function CreateInfoLabel(text, parent, order)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, S(22))
    frame.BackgroundColor3 = Color3.fromRGB(18, 15, 30)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.ZIndex = 13
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, S(6))
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -S(8), 1, 0)
    lbl.Position = UDim2.new(0, S(6), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(160, 190, 225)
    lbl.TextSize = S(8)
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    return lbl
end

-- ================================================
--      [CỘT TRÁI - LIST 1] NHÓM COMBAT & ESP + CLICK AURA
-- ================================================
CreateSection("💀 COMBAT & ESP", LeftColumn, 10)

local fovSlider, getFovSliderVal = CreateSlider("FOV Aimbot", LeftColumn, 30, 300, Config.AimbotFOV, 11, Color3.fromRGB(255, 50, 150), function(val)
    Config.AimbotFOV = val
    if FOVCircle then FOVCircle.Radius = val end
end)

local aimbotBtn, getAimbotState, setAimbotState = CreateToggleButton("🎯 Aimbot", LeftColumn, 12, Color3.fromRGB(255, 50, 150))
local silentAimBtn, getSilentAimState, setSilentAimState = CreateToggleButton("🤫 Silent Aim", LeftColumn, 13, Color3.fromRGB(150, 100, 255))
local triggerbotBtn, getTriggerbotState, setTriggerbotState = CreateToggleButton("🔥 Triggerbot", LeftColumn, 14, Color3.fromRGB(255, 80, 20))

aimbotBtn.MouseButton1Click:Connect(function()
    Config.AimbotEnabled = not Config.AimbotEnabled
    setAimbotState(Config.AimbotEnabled)
    if not Config.AimbotEnabled then
        Config.TriggerbotEnabled = false; setTriggerbotState(false)
        Config.SilentAimEnabled = false; setSilentAimState(false)
    end
end)

silentAimBtn.MouseButton1Click:Connect(function()
    Config.SilentAimEnabled = not Config.SilentAimEnabled
    setSilentAimState(Config.SilentAimEnabled)
    if Config.SilentAimEnabled and not Config.AimbotEnabled then
        Config.AimbotEnabled = true; setAimbotState(true)
    end
end)

triggerbotBtn.MouseButton1Click:Connect(function()
    Config.TriggerbotEnabled = not Config.TriggerbotEnabled
    setTriggerbotState(Config.TriggerbotEnabled)
    if Config.TriggerbotEnabled and not Config.AimbotEnabled then
        Config.AimbotEnabled = true; setAimbotState(true)
    end
end)

local fovToggleBtn, getFovVState, setFovVState = CreateToggleButton("⭕ FOV Circle", LeftColumn, 15, Color3.fromRGB(110, 85, 255))
setFovVState(Config.FOVVisible)
fovToggleBtn.MouseButton1Click:Connect(function()
    Config.FOVVisible = not Config.FOVVisible
    setFovVState(Config.FOVVisible)
    if FOVCircle then FOVCircle.Visible = Config.FOVVisible end
end)

local hitboxBtn, getHitboxState, setHitboxState = CreateToggleButton("📦 Hitbox Ext", LeftColumn, 16, Color3.fromRGB(255, 150, 0))
hitboxBtn.MouseButton1Click:Connect(function()
    Config.HitboxExtenderEnabled = not Config.HitboxExtenderEnabled
    setHitboxState(Config.HitboxExtenderEnabled)
end)

local espBtn, getEspState, setEspState = CreateToggleButton("👁️ ESP", LeftColumn, 17, Color3.fromRGB(255, 200, 0))

-- Click Aura section
CreateSection("🖱️ CLICK AURA", LeftColumn, 18)
local clickAuraBtn, getClickAuraState, setClickAuraState = CreateToggleButton("🎯 Click Aura", LeftColumn, 19, Color3.fromRGB(0, 200, 255))
local clickAuraRadiusSlider, getClickAuraRadius = CreateSlider("Phạm vi", LeftColumn, 10, 200, Config.ClickAuraRadius, 20, Color3.fromRGB(0, 200, 255), function(val) Config.ClickAuraRadius = val end)

local targetTypeDropdown = Instance.new("Frame", LeftColumn)
targetTypeDropdown.Size = UDim2.new(1, 0, 0, S(28))
targetTypeDropdown.BackgroundColor3 = Color3.fromRGB(20, 17, 32)
targetTypeDropdown.BorderSizePixel = 0
targetTypeDropdown.LayoutOrder = 21
targetTypeDropdown.ZIndex = 13
Instance.new("UICorner", targetTypeDropdown).CornerRadius = UDim.new(0, S(6))

local targetTypeLabel = Instance.new("TextLabel", targetTypeDropdown)
targetTypeLabel.Size = UDim2.new(1, -S(6), 1, 0)
targetTypeLabel.Position = UDim2.new(0, S(6), 0, 0)
targetTypeLabel.BackgroundTransparency = 1
targetTypeLabel.Text = "Mục tiêu: Mob"
targetTypeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetTypeLabel.TextSize = S(8)
targetTypeLabel.Font = Enum.Font.Gotham
targetTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
targetTypeLabel.ZIndex = 14

local targetTypes = {"Mob", "Player", "All"}
local currentTargetType = 1
targetTypeDropdown.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        currentTargetType = currentTargetType % #targetTypes + 1
        Config.ClickAuraTargetType = targetTypes[currentTargetType]
        targetTypeLabel.Text = "Mục tiêu: " .. Config.ClickAuraTargetType
    end
end)

clickAuraBtn.MouseButton1Click:Connect(function()
    Config.ClickAuraEnabled = not Config.ClickAuraEnabled
    setClickAuraState(Config.ClickAuraEnabled)
end)

-- ================================================
--       [CỘT PHẢI - LIST 2] CÁC KHU BỔ TRỢ KHÁC
-- ================================================

-- Cụm: Thông Tin Game (Order 10)
CreateSection("🎮 INFO", RightColumn, 10)
local gameIdLabel = CreateInfoLabel("ID: " .. tostring(game.PlaceId), RightColumn, 11)
local copyBtn = CreateActionButton("📋 Copy Game ID", RightColumn, 12, Color3.fromRGB(45, 90, 160))
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(tostring(game.PlaceId)) end
end)

-- Cụm: Di Chuyển & Tốc Độ (Order 20)
CreateSection("🏃 MOVE & SPEED", RightColumn, 20)

local speedSlider, getSpeedSliderVal = CreateSlider("Tốc độ", RightColumn, 30, 200, Config.SpeedValue, 21, Color3.fromRGB(235, 140, 35), function(val)
    Config.SpeedValue = val
    if Config.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

local speedBtn, getSpeedState, setSpeedState = CreateToggleButton("⚡ Tốc Độ", RightColumn, 22, Color3.fromRGB(235, 140, 35))
speedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    setSpeedState(Config.SpeedEnabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.SpeedEnabled and getSpeedSliderVal() or Config.DefaultSpeed
    end
end)

local jumpSlider, getJumpSliderVal = CreateSlider("Nhảy", RightColumn, 50, 300, Config.JumpValue, 23, Color3.fromRGB(60, 180, 105), function(val)
    Config.JumpValue = val
    if Config.JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

local jumpBtn, getJumpState, setJumpState = CreateToggleButton("🦘 Nhảy Cao", RightColumn, 24, Color3.fromRGB(60, 180, 105))
jumpBtn.MouseButton1Click:Connect(function()
    Config.JumpEnabled = not Config.JumpEnabled
    setJumpState(Config.JumpEnabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Config.JumpEnabled and getJumpSliderVal() or Config.DefaultJump
    end
end)

local infJumpBtn, getInfJumpState, setInfJumpState = CreateToggleButton("♾️ Nhảy Vô Hạn", RightColumn, 25, Color3.fromRGB(150, 70, 230))
infJumpBtn.MouseButton1Click:Connect(function()
    Config.InfiniteJump = not Config.InfiniteJump
    setInfJumpState(Config.InfiniteJump)
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local noclipLoop = nil
local noclipBtn, getNoclipState, setNoclipState = CreateToggleButton("👻 Noclip", RightColumn, 26, Color3.fromRGB(200, 50, 80))
noclipBtn.MouseButton1Click:Connect(function()
    local newState = not getNoclipState()
    setNoclipState(newState)
    if newState then
        noclipLoop = RunService.Stepped:Connect(function()
            if not getNoclipState() then return end
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipLoop then noclipLoop:Disconnect(); noclipLoop = nil end
    end
end)

-- Cụm: Auto Collect (Order 30)
CreateSection("🎒 AUTO COLLECT", RightColumn, 30)
local autoCollectBtn, getAutoCollectState, setAutoCollectState = CreateToggleButton("🔄 Auto Collect", RightColumn, 31, Color3.fromRGB(255, 215, 0))
local collectRadiusSlider, getCollectRadius = CreateSlider("Phạm vi", RightColumn, 10, 200, Config.CollectRadius, 32, Color3.fromRGB(255, 215, 0), function(val) Config.CollectRadius = val end)

autoCollectBtn.MouseButton1Click:Connect(function()
    Config.AutoCollectEnabled = not Config.AutoCollectEnabled
    setAutoCollectState(Config.AutoCollectEnabled)
    if Config.AutoCollectEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Config.CollectReturnPos = char.HumanoidRootPart.Position
        end
    end
end)

-- Cụm: Freecam (Order 40)
CreateSection("📷 FREECAM", RightColumn, 40)
local freecamBtn, getFreecamState, setFreecamState = CreateToggleButton("🎥 Freecam", RightColumn, 41, Color3.fromRGB(180, 100, 255))
local freecamSpeedSlider, getFreecamSpeed = CreateSlider("Tốc độ", RightColumn, 5, 100, Config.FreecamSpeed, 42, Color3.fromRGB(180, 100, 255), function(val) Config.FreecamSpeed = val end)

local FreecamControlFrame = Instance.new("Frame", ScreenGui)
FreecamControlFrame.Size = UDim2.new(0, S(120), 0, S(80))
FreecamControlFrame.Position = UDim2.new(1, -S(130), 0.5, -S(40))
FreecamControlFrame.BackgroundTransparency = 1
FreecamControlFrame.Visible = false
FreecamControlFrame.ZIndex = 20

local dpadSize = S(28)
local function createDPadButton(text, posX, posY, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, dpadSize, 0, dpadSize)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = S(12)
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 21
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, S(6))
    return btn
end

local upBtn = createDPadButton("▲", dpadSize, 0, FreecamControlFrame)
local leftBtn = createDPadButton("◄", 0, dpadSize, FreecamControlFrame)
local rightBtn = createDPadButton("►", dpadSize*2, dpadSize, FreecamControlFrame)
local downBtn = createDPadButton("▼", dpadSize, dpadSize*2, FreecamControlFrame)
local upWorldBtn = createDPadButton("⬆", dpadSize*3, 0, FreecamControlFrame)
local downWorldBtn = createDPadButton("⬇", dpadSize*3, dpadSize*2, FreecamControlFrame)

local freecamPart = nil
local function startFreecam()
    if freecamPart then freecamPart:Destroy() end
    freecamPart = Instance.new("Part")
    freecamPart.Name = "FreecamPart"
    freecamPart.Transparency = 1
    freecamPart.CanCollide = false
    freecamPart.Anchored = true
    freecamPart.Position = Camera.CFrame.Position
    freecamPart.Parent = workspace
    Camera.CameraSubject = freecamPart
    FreecamControlFrame.Visible = true
end

local function stopFreecam()
    FreecamControlFrame.Visible = false
    if freecamPart then freecamPart:Destroy(); freecamPart = nil end
    Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
end

freecamBtn.MouseButton1Click:Connect(function()
    Config.FreecamEnabled = not Config.FreecamEnabled
    setFreecamState(Config.FreecamEnabled)
    if Config.FreecamEnabled then startFreecam() else stopFreecam() end
end)

local freecamInputTable = {}
local function updateFreecamMovement()
    if not Config.FreecamEnabled or not freecamPart then return end
    local move = Vector3.new(0,0,0)
    local speed = Config.FreecamSpeed
    if freecamInputTable["forward"] then move = move + Camera.CFrame.LookVector * speed end
    if freecamInputTable["backward"] then move = move - Camera.CFrame.LookVector * speed end
    if freecamInputTable["left"] then move = move - Camera.CFrame.RightVector * speed end
    if freecamInputTable["right"] then move = move + Camera.CFrame.RightVector * speed end
    if freecamInputTable["up"] then move = move + Vector3.new(0, speed, 0) end
    if freecamInputTable["down"] then move = move - Vector3.new(0, speed, 0) end
    freecamPart.Position = freecamPart.Position + move * 0.1
    Camera.CFrame = CFrame.new(freecamPart.Position, freecamPart.Position + Camera.CFrame.LookVector)
end

local function bindFreecamButton(button, key)
    button.MouseButton1Down:Connect(function() freecamInputTable[key] = true end)
    button.MouseButton1Up:Connect(function() freecamInputTable[key] = false end)
    button.MouseLeave:Connect(function() freecamInputTable[key] = false end)
end

bindFreecamButton(upBtn, "forward")
bindFreecamButton(downBtn, "backward")
bindFreecamButton(leftBtn, "left")
bindFreecamButton(rightBtn, "right")
bindFreecamButton(upWorldBtn, "up")
bindFreecamButton(downWorldBtn, "down")

-- Cụm: Stat Tracker (Order 45)
CreateSection("📊 STAT TRACKER", RightColumn, 45)
local statTrackerBtn, getStatTrackerState, setStatTrackerState = CreateToggleButton("📈 Stat Tracker", RightColumn, 46, Color3.fromRGB(0, 255, 100))
local statDisplayLabel = CreateInfoLabel("Đang chờ...", RightColumn, 47)

local statTrackerConnection = nil
local statStartValues = {}
local statStartTime = nil

local function updateStatDisplay()
    if not Config.StatTrackerEnabled then return end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if not leaderstats then statDisplayLabel.Text = "Không có leaderstats"; return end
    local lines = {}
    local now = os.clock()
    local elapsed = now - statStartTime
    for _, stat in ipairs(leaderstats:GetChildren()) do
        if stat:IsA("IntValue") or stat:IsA("NumberValue") then
            local current = stat.Value
            local startVal = statStartValues[stat.Name]
            if startVal then
                local diff = current - startVal
                local rate = elapsed > 0 and (diff / elapsed * 60) or 0
                table.insert(lines, stat.Name .. ": +" .. diff .. " (" .. string.format("%.1f", rate) .. "/ph)")
            end
        end
    end
    statDisplayLabel.Text = #lines > 0 and table.concat(lines, "\n") or "Không có dữ liệu"
end

statTrackerBtn.MouseButton1Click:Connect(function()
    Config.StatTrackerEnabled = not Config.StatTrackerEnabled
    setStatTrackerState(Config.StatTrackerEnabled)
    if Config.StatTrackerEnabled then
        statStartValues = {}
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in ipairs(leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    statStartValues[stat.Name] = stat.Value
                end
            end
        end
        statStartTime = os.clock()
        if statTrackerConnection then statTrackerConnection:Disconnect() end
        statTrackerConnection = RunService.Heartbeat:Connect(function()
            if not Config.StatTrackerEnabled then return end
            updateStatDisplay()
            task.wait(Config.StatUpdateInterval)
        end)
    else
        if statTrackerConnection then statTrackerConnection:Disconnect(); statTrackerConnection = nil end
        statDisplayLabel.Text = "Đã dừng"
    end
end)

-- Cụm: Người Chơi Khác (Order 50)
CreateSection("👥 PLAYERS", RightColumn, 50)

local playerListFrame = Instance.new("Frame", RightColumn)
playerListFrame.Size = UDim2.new(1, 0, 0, S(80))
playerListFrame.BackgroundColor3 = Color3.fromRGB(16, 13, 26)
playerListFrame.BorderSizePixel = 0
playerListFrame.LayoutOrder = 51
playerListFrame.ZIndex = 13
Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, S(6))

local playerScrollingFrame = Instance.new("ScrollingFrame", playerListFrame)
playerScrollingFrame.Size = UDim2.new(1, -S(3), 1, -S(3))
playerScrollingFrame.Position = UDim2.new(0, S(1.5), 0, S(1.5))
playerScrollingFrame.BackgroundTransparency = 1
playerScrollingFrame.ScrollBarThickness = isMobile and 0 or 1.5
playerScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScrollingFrame.ZIndex = 14

local playerListLayout = Instance.new("UIListLayout", playerScrollingFrame)
playerListLayout.Padding = UDim.new(0, S(2))
playerListLayout.SortOrder = Enum.SortOrder.Name

local function refreshPlayerList()
    for _, child in ipairs(playerScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerEntry = Instance.new("Frame", playerScrollingFrame)
            playerEntry.Size = UDim2.new(1, 0, 0, S(22))
            playerEntry.BackgroundColor3 = Color3.fromRGB(25, 22, 40)
            playerEntry.BorderSizePixel = 0
            playerEntry.ZIndex = 15
            Instance.new("UICorner", playerEntry).CornerRadius = UDim.new(0, S(4))
            
            local nameLabel = Instance.new("TextLabel", playerEntry)
            nameLabel.Size = UDim2.new(0.4, -S(3), 1, 0)
            nameLabel.Position = UDim2.new(0, S(4), 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = S(8)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.ZIndex = 16
            
            local teleBtn = Instance.new("TextButton", playerEntry)
            teleBtn.Size = UDim2.new(0, S(40), 0, S(14))
            teleBtn.Position = UDim2.new(0.42, 0, 0.5, -S(7))
            teleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
            teleBtn.Text = "Tele"
            teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            teleBtn.TextSize = S(7)
            teleBtn.Font = Enum.Font.GothamBold
            teleBtn.ZIndex = 16
            Instance.new("UICorner", teleBtn).CornerRadius = UDim.new(0, S(3))
            teleBtn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("Head") and LocalPlayer.Character then
                    LocalPlayer.Character:MoveTo(player.Character.Head.Position)
                end
            end)
            
            local specBtn = Instance.new("TextButton", playerEntry)
            specBtn.Size = UDim2.new(0, S(40), 0, S(14))
            specBtn.Position = UDim2.new(1, -S(44), 0.5, -S(7))
            specBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
            specBtn.Text = "Spec"
            specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            specBtn.TextSize = S(7)
            specBtn.Font = Enum.Font.GothamBold
            specBtn.ZIndex = 16
            Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, S(3))
            specBtn.MouseButton1Click:Connect(function()
                if player.Character then Camera.CameraSubject = player.Character end
            end)
        end
    end
end

local refreshPlayersBtn = CreateActionButton("🔄 Làm Mới DS", RightColumn, 52, Color3.fromRGB(80, 80, 120))
refreshPlayersBtn.MouseButton1Click:Connect(refreshPlayerList)
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- Cụm: Tiện Ích (Order 60)
CreateSection("🔧 TIỆN ÍCH", RightColumn, 60)

local flyBtn = CreateActionButton("🚀 Bay", RightColumn, 61, Color3.fromRGB(195, 60, 60))
flyBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ngai000/spy/refs/heads/main/bay.txt"))() end)
end)

local killAuraBtn = CreateActionButton("⚔️ Kill Aura", RightColumn, 62, Color3.fromRGB(200, 50, 50))
killAuraBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ngai000/spy/refs/heads/main/baknsns.lua"))() end)
end)

local dexBtn = CreateActionButton("🔍 DEX", RightColumn, 63, Color3.fromRGB(50, 115, 180))
dexBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-DeX-Explorer-114771"))() end)
end)

local spyBtn = CreateActionButton("👁️ Spy", RightColumn, 64, Color3.fromRGB(130, 50, 160))
spyBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Simple-Spy-V3-Mobile-53593"))() end)
end)

local antiAFKBtn, getAFKState, setAFKState = CreateToggleButton("⏰ Anti-AFK", RightColumn, 65, Color3.fromRGB(100, 200, 100))
local afkConnection = nil
antiAFKBtn.MouseButton1Click:Connect(function()
    Config.AntiAFKEnabled = not Config.AntiAFKEnabled
    setAFKState(Config.AntiAFKEnabled)
    if Config.AntiAFKEnabled then
        if not afkConnection then
            afkConnection = RunService.Heartbeat:Connect(function()
                if Config.AntiAFKEnabled then
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                        task.wait(0.02)
                        vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
                    end)
                    task.wait(Config.AFKInterval)
                end
            end)
        end
    else
        if afkConnection then afkConnection:Disconnect(); afkConnection = nil end
    end
end)

local unlockGuiBtn = CreateActionButton("🔓 Mở Core GUI", RightColumn, 66, Color3.fromRGB(160, 120, 40))
unlockGuiBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("RobloxGui") then
            for _, v in ipairs(coreGui.RobloxGui:GetDescendants()) do
                if v:IsA("Frame") then v.Visible = true end
            end
        end
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
end)

local savePositionBtn = CreateActionButton("📍 Lưu Vị Trí", RightColumn, 67, Color3.fromRGB(50, 180, 220))
savePositionBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then SavedPosition = root.Position end
    end
end)

local teleportToSavedBtn = CreateActionButton("🚀 Teleport", RightColumn, 68, Color3.fromRGB(220, 100, 50))
teleportToSavedBtn.MouseButton1Click:Connect(function()
    if SavedPosition and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(SavedPosition) end
    end
end)

-- ================================================
--    CORE ENGINE: AIMBOT / TRIGGERBOT / ESP / CLICK AURA / AUTO COLLECT
-- ================================================
local ESPs = {}
local ESPEnabled = false

local function createESP(player)
    if ESPs[player] then return end
    ESPs[player] = {
        Box = Drawing.new("Square"), Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"), HealthBar = Drawing.new("Line")
    }
    local esp = ESPs[player]
    esp.Box.Thickness, esp.Box.Transparency, esp.Box.Filled = 1, 1, false
    esp.Name.Color, esp.Name.Size, esp.Name.Center, esp.Name.Outline, esp.Name.Transparency = Color3.new(1,1,1), 10, true, true, 1
    esp.Distance.Color, esp.Distance.Size, esp.Distance.Center, esp.Distance.Outline, esp.Distance.Transparency = Color3.new(0.8,0.8,1), 9, true, true, 1
    esp.HealthBar.Color, esp.HealthBar.Thickness = Color3.fromRGB(0, 255, 0), 1.5
end

local function updateESP(player)
    if not ESPEnabled then return end
    if not player.Character or not player.Character:FindFirstChild("Head") or not player.Character:FindFirstChild("Humanoid") then
        if ESPs[player] then for _, obj in pairs(ESPs[player]) do obj.Visible = false end end
        return
    end
    local char, head, hum = player.Character, player.Character.Head, player.Character.Humanoid
    if hum.Health <= 0 then
        if ESPs[player] then for _, obj in pairs(ESPs[player]) do obj.Visible = false end end
        return
    end
    if not ESPs[player] then createESP(player) end
    local esp = ESPs[player]
    local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
    if onScreen then
        local distance = (head.Position - Camera.CFrame.Position).Magnitude
        local scale = 1 / distance * 80
        local boxSize = Vector2.new(25, 40) * math.clamp(scale, 0.3, 2.5)
        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local boxColor = hpPercent > 0.7 and Color3.fromRGB(50,255,50) or (hpPercent > 0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,50,50))
        
        esp.Box.Color, esp.Box.Size, esp.Box.Position, esp.Box.Visible = boxColor, boxSize, Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2), true
        esp.Name.Text, esp.Name.Position, esp.Name.Visible = player.Name, Vector2.new(vector.X, vector.Y - boxSize.Y / 2 - 10), true
        esp.Distance.Text, esp.Distance.Position, esp.Distance.Visible = string.format("[%.0fm]", distance), Vector2.new(vector.X, vector.Y - boxSize.Y / 2 - 20), true
        
        local barHeight = boxSize.Y * hpPercent
        esp.HealthBar.From = Vector2.new(vector.X - boxSize.X / 2 - 3, vector.Y + boxSize.Y / 2)
        esp.HealthBar.To = Vector2.new(vector.X - boxSize.X / 2 - 3, vector.Y + boxSize.Y / 2 - barHeight)
        esp.HealthBar.Color, esp.HealthBar.Visible = boxColor, true
    else
        for _, obj in pairs(esp) do obj.Visible = false end
    end
end

local function clearESP()
    for player, esp in pairs(ESPs) do for _, obj in pairs(esp) do obj:Remove() end end
    ESPs = {}
end

espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled; setEspState(ESPEnabled)
    if not ESPEnabled then clearESP() end
end)

local function getBestTargetCFrame()
    local closest, minDist = nil, Config.MAX_DISTANCE
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local toTarget = head.Position - Camera.CFrame.Position
            local dist = toTarget.Magnitude
            if dist < minDist then
                local angle = math.acos(math.clamp(Camera.CFrame.LookVector:Dot(toTarget.Unit), -1, 1))
                if math.deg(angle) <= (Config.AimbotFOV / 2) then closest = player; minDist = dist end
            end
        end
    end
    return closest and CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position) or nil
end

local lastFireTime = 0
local function fireWeapon()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.02)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

local function clickAura(targetPos)
    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
    if onScreen then
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
    end
end

local function getClickAuraTarget()
    local closest = nil
    local minDist = Config.ClickAuraRadius
    local targetType = Config.ClickAuraTargetType
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum = obj:FindFirstChild("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if hum and hum.Health > 0 and root then
                local isPlayer = Players:GetPlayerFromCharacter(obj) ~= nil
                local valid = false
                if targetType == "All" then valid = true
                elseif targetType == "Player" and isPlayer then valid = true
                elseif targetType == "Mob" and not isPlayer then valid = true
                end
                if valid then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    if dist < minDist then closest = root; minDist = dist end
                end
            end
        end
    end
    return closest
end

local function autoCollect()
    if not Config.AutoCollectEnabled or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local keywords = {}
    for word in string.gmatch(Config.CollectKeywords, "[^,]+") do
        table.insert(keywords, string.lower(string.gsub(word, "%s", "")))
    end
    local closest = nil
    local minDist = Config.CollectRadius
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do
                if string.find(name, kw) then
                    local dist = (obj.Position - root.Position).Magnitude
                    if dist < minDist then closest = obj; minDist = dist end
                    break
                end
            end
        end
    end
    if closest then
        local oldPos = root.CFrame
        root.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
        task.wait(0.05)
        root.CFrame = oldPos
    end
end

RunService:BindToRenderStep("FreecamMovement", Enum.RenderPriority.Camera.Value, function()
    if Config.FreecamEnabled then updateFreecamMovement() end
end)

RunService:BindToRenderStep("AimAndESP", Config.UPDATE_PRIORITY, function()
    if Config.AimbotEnabled and not Config.SilentAimEnabled then
        local targetCFrame = getBestTargetCFrame()
        if targetCFrame then Camera.CFrame = targetCFrame end
    end
    if Config.TriggerbotEnabled and getBestTargetCFrame() then
        local now = tick()
        if now - lastFireTime > 0.1 then fireWeapon(); lastFireTime = now end
    end
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then updateESP(player) end end
    end
    if Config.ClickAuraEnabled then
        local target = getClickAuraTarget()
        if target then clickAura(target.Position) end
    end
    if Config.AutoCollectEnabled then autoCollect() end
end)

-- ================================================
--       HỆ THỐNG DRAG & ĐÓNG MỞ COORD TRƠN TRU
-- ================================================
local function MakeDraggable(dragFrame, targetFrame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = targetFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = ClampPosition(targetFrame, UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
        end
    end)
end
MakeDraggable(Header, MainPanel)

local miniDragging, isMoving, dragStart, startPos = false, false, nil, nil
MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging, isMoving, dragStart, startPos = true, false, input.Position, MiniButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 7 then isMoving = true end
        if isMoving then
            MiniButton.Position = ClampPosition(MiniButton, UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
        end
    end
end)
MiniButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
        if not isMoving then
            MiniButton.Visible, MainPanel.Visible, MainPanel.Size = false, true, UDim2.new(0, 0, 0, 0)
            TweenService:Create(MainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tween:Play(); tween.Completed:Connect(function()
        MainPanel.Visible, MainPanel.Size, MiniButton.Visible = false, TargetSize, true
    end)
end)

local pulseUp = true
RunService.Heartbeat:Connect(function(dt)
    if not MiniButton.Visible then return end
    MiniStroke.Thickness = MiniStroke.Thickness + (pulseUp and dt * 2 or -dt * 2)
    if MiniStroke.Thickness >= 3 then pulseUp = false elseif MiniStroke.Thickness <= 1.5 then pulseUp = true end
end)

print("[MobileGUI Compact] ✅ Đã thu nhỏ giao diện cho mobile!")
