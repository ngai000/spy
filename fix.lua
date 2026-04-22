local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

-- Cấu hình nâng cao
local CONFIG = {
    FPS_THRESHOLD = 10,
    CRITICAL_FPS = 5,
    CHECK_INTERVAL = 0.5,
    RESET_DELAY = 3,
    MAX_FPS_HISTORY = 60,
    UI_UPDATE_INTERVAL = 0.1,
    AUTO_RESET_ENABLED = true,
    MIN_AVERAGE_FPS = 15,
    RECOVERY_COOLDOWN = 10,
    PING_THRESHOLD = 300,
}

-- Biến state
local state = {
    fps = 0,
    averageFps = 0,
    minFps = math.huge,
    maxFps = 0,
    lowFpsTime = 0,
    lastReset = 0,
    isRecovering = false,
    frameCount = 0,
    lastTime = tick(),
    fpsHistory = {},
    ping = 0,
    memoryUsage = 0,
}

-- ===== FIX: Tạo UI ở nơi không bị reset =====
local function createPersistentUI()
    -- Tìm nơi lưu trữ UI an toàn (không bị reset khi chết)
    local uiParent
    
    -- Thử dùng CoreGui (an toàn nhất, không bị reset)
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        if CoreGui then
            uiParent = CoreGui
        end
    end)
    
    -- Nếu không được, thử dùng PlayerGui nhưng sẽ tạo lại khi cần
    if not uiParent then
        uiParent = player:WaitForChild("PlayerGui")
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSMonitorUI_Persistent"
    screenGui.ResetOnSpawn = false  -- Quan trọng: Ngăn reset khi respawn
    screenGui.Parent = uiParent
    
    -- Main frame với hiệu ứng bóng
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 120)
    mainFrame.Position = UDim2.new(1, -230, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    -- Bo góc
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Hiệu ứng stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
    mainFrame.Parent = screenGui
    
    -- Title bar (có thể kéo)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.Text = "⚡ FPS Monitor Pro"
    titleText.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleText.BackgroundTransparency = 1
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextScaled = true
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Nút minimize
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -25, 0, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minimizeBtn.BackgroundTransparency = 0.5
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.Parent = titleBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = minimizeBtn
    
    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -35)
    contentFrame.Position = UDim2.new(0, 5, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- FPS Label
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, 0, 0, 25)
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.TextScaled = true
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Parent = contentFrame
    
    -- Average FPS Label
    local avgFpsLabel = Instance.new("TextLabel")
    avgFpsLabel.Name = "AvgFPSLabel"
    avgFpsLabel.Size = UDim2.new(1, 0, 0, 20)
    avgFpsLabel.Position = UDim2.new(0, 0, 0, 25)
    avgFpsLabel.Text = "AVG: --"
    avgFpsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    avgFpsLabel.BackgroundTransparency = 1
    avgFpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    avgFpsLabel.TextScaled = true
    avgFpsLabel.Font = Enum.Font.Gotham
    avgFpsLabel.Parent = contentFrame
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 45)
    statusLabel.Text = "Status: Stable"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = contentFrame
    
    -- Ping Label
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingLabel"
    pingLabel.Size = UDim2.new(1, 0, 0, 20)
    pingLabel.Position = UDim2.new(0, 0, 0, 65)
    pingLabel.Text = "Ping: -- ms"
    pingLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.TextScaled = true
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.Parent = contentFrame
    
    -- Progress bar cho FPS
    local fpsBar = Instance.new("Frame")
    fpsBar.Name = "FPSBar"
    fpsBar.Size = UDim2.new(1, 0, 0, 4)
    fpsBar.Position = UDim2.new(0, 0, 0, 90)
    fpsBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    fpsBar.BorderSizePixel = 0
    fpsBar.Parent = contentFrame
    
    local fpsBarFill = Instance.new("Frame")
    fpsBarFill.Name = "Fill"
    fpsBarFill.Size = UDim2.new(1, 0, 1, 0)
    fpsBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fpsBarFill.BorderSizePixel = 0
    fpsBarFill.Parent = fpsBar
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = fpsBar
    
    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 20)
    toggleBtn.Position = UDim2.new(1, -65, 0, 70)
    toggleBtn.Text = "Auto: ON"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = contentFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleBtn
    
    -- Draggable functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Minimize functionality
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 220, 0, 25) or UDim2.new(0, 220, 0, 120)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = targetSize})
        tween:Play()
    end)
    
    -- Toggle auto-reset
    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG.AUTO_RESET_ENABLED = not CONFIG.AUTO_RESET_ENABLED
        toggleBtn.Text = CONFIG.AUTO_RESET_ENABLED and "Auto: ON" or "Auto: OFF"
        toggleBtn.BackgroundColor3 = CONFIG.AUTO_RESET_ENABLED 
            and Color3.fromRGB(0, 150, 0) 
            or Color3.fromRGB(150, 0, 0)
    end)
    
    return {
        gui = screenGui,
        mainFrame = mainFrame,
        fpsLabel = fpsLabel,
        avgFpsLabel = avgFpsLabel,
        statusLabel = statusLabel,
        pingLabel = pingLabel,
        fpsBarFill = fpsBarFill,
    }
end

-- ===== FIX: Cơ chế bảo vệ UI =====
local ui
local function ensureUI()
    if not ui or not ui.gui or not ui.gui.Parent then
        ui = createPersistentUI()
    end
end

-- Khởi tạo UI lần đầu
ensureUI()

-- ===== FIX: Theo dõi PlayerGui để tạo lại UI nếu cần =====
player.Changed:Connect(function(property)
    if property == "PlayerGui" then
        task.wait(0.1) -- Đợi PlayerGui ổn định
        ensureUI()
    end
end)

-- Khi character được thêm mới (respawn)
player.CharacterAdded:Connect(function()
    task.wait(0.1)
    ensureUI()
end)

-- Hàm tính FPS trung bình
local function calculateAverageFps()
    local sum = 0
    for _, fps in ipairs(state.fpsHistory) do
        sum += fps
    end
    return #state.fpsHistory > 0 and sum / #state.fpsHistory or 0
end

-- Hàm reset nhân vật (nâng cao)
local function resetCharacter()
    if not CONFIG.AUTO_RESET_ENABLED then return end
    if state.isRecovering then return end
    
    local currentTime = tick()
    if currentTime - state.lastReset < CONFIG.RECOVERY_COOLDOWN then
        return
    end
    
    state.isRecovering = true
    state.lastReset = currentTime
    
    -- Thử nhiều cách reset khác nhau
    local success = false
    
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                success = true
            end
        end
    end)
    
    if not success then
        pcall(function()
            player.Character:BreakJoints()
            success = true
        end)
    end
    
    if not success then
        pcall(function()
            local character = player.Character
            if character then
                character:Destroy()
            end
        end)
    end
    
    -- Cooldown recovery
    task.delay(CONFIG.RECOVERY_COOLDOWN, function()
        state.isRecovering = false
    end)
end

-- Hàm cập nhật UI (tối ưu hóa)
local function updateUI()
    ensureUI() -- Đảm bảo UI tồn tại trước khi cập nhật
    
    if not ui.fpsLabel then return end
    
    -- Cập nhật FPS
    local fps = math.floor(state.fps)
    pcall(function()
        ui.fpsLabel.Text = string.format("FPS: %d (Min: %d | Max: %d)", 
            fps, 
            math.min(state.minFps, fps), 
            math.max(state.maxFps, fps))
        
        -- Màu sắc FPS
        if fps >= 60 then
            ui.fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            ui.fpsBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        elseif fps >= 30 then
            ui.fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            ui.fpsBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif fps >= 15 then
            ui.fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            ui.fpsBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            ui.fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            ui.fpsBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        -- Cập nhật FPS trung bình
        ui.avgFpsLabel.Text = string.format("AVG: %.1f FPS", state.averageFps)
        
        -- Cập nhật ping
        ui.pingLabel.Text = string.format("Ping: N/A ms") -- Roblox không có API ping
        
        -- Cập nhật status
        if state.isRecovering then
            ui.statusLabel.Text = "Status: Recovering..."
            ui.statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        elseif state.lowFpsTime > 0 then
            ui.statusLabel.Text = string.format("Status: Low FPS (%.1fs)", state.lowFpsTime)
            ui.statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            ui.statusLabel.Text = "Status: Stable"
            ui.statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
        
        -- Cập nhật progress bar
        local percentage = math.clamp(fps / 60, 0, 1)
        ui.fpsBarFill.Size = UDim2.new(percentage, 0, 1, 0)
    end)
end

-- Main loop (tối ưu hóa)
local function mainLoop()
    -- FPS Counter (RenderStepped)
    RunService.RenderStepped:Connect(function()
        state.frameCount += 1
    end)
    
    -- FPS Calculator & Monitor
    task.spawn(function()
        while true do
            task.wait(CONFIG.CHECK_INTERVAL)
            
            local currentTime = tick()
            local deltaTime = currentTime - state.lastTime
            
            -- Tính FPS
            if deltaTime > 0 then
                state.fps = state.frameCount / deltaTime
                
                -- Cập nhật lịch sử FPS
                table.insert(state.fpsHistory, state.fps)
                if #state.fpsHistory > CONFIG.MAX_FPS_HISTORY then
                    table.remove(state.fpsHistory, 1)
                end
                
                -- Cập nhật min/max FPS
                state.minFps = math.min(state.minFps, state.fps)
                state.maxFps = math.max(state.maxFps, state.fps)
                
                -- Tính FPS trung bình
                state.averageFps = calculateAverageFps()
            end
            
            state.frameCount = 0
            state.lastTime = currentTime
            
            -- Kiểm tra FPS thấp
            if state.fps < CONFIG.FPS_THRESHOLD then
                state.lowFpsTime += CONFIG.CHECK_INTERVAL
            else
                state.lowFpsTime = 0
            end
            
            -- Reset nếu FPS quá thấp
            if CONFIG.AUTO_RESET_ENABLED and not state.isRecovering then
                local shouldReset = false
                
                -- Reset ngay nếu FPS cực thấp
                if state.fps < CONFIG.CRITICAL_FPS then
                    shouldReset = true
                -- Reset nếu FPS thấp kéo dài
                elseif state.lowFpsTime >= CONFIG.RESET_DELAY then
                    shouldReset = true
                -- Reset nếu FPS trung bình quá thấp
                elseif state.averageFps < CONFIG.MIN_AVERAGE_FPS and #state.fpsHistory >= 30 then
                    shouldReset = true
                end
                
                if shouldReset then
                    resetCharacter()
                    state.lowFpsTime = 0
                    state.fpsHistory = {}
                    state.minFps = math.huge
                    state.maxFps = 0
                end
            end
        end
    end)
    
    -- UI Updater (riêng biệt để giảm lag)
    task.spawn(function()
        while true do
            task.wait(CONFIG.UI_UPDATE_INTERVAL)
            pcall(updateUI)
        end
    end)
    
    -- Reset stats mỗi 5 phút
    task.spawn(function()
        while true do
            task.wait(300)
            state.minFps = math.huge
            state.maxFps = 0
        end
    end)
end

-- Khởi động
mainLoop()

print("✅ Persistent FPS Monitor đã khởi động!")
print("🛡️ UI sẽ không bị mất khi reset nhân vật!")
