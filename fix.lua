local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local FILE = "lock_position.json"
local Islands = {
	["Dao1"] = {
		Position = Vector3.new(270.40, 21.53, 50.72),
		LookVector = Vector3.new(1.00, 0.00, -0.04)
	},
	["Dao2"] = {
		Position = Vector3.new(1769.54, 18.72, -376.28),
		LookVector = Vector3.new(0.60, 0.00, 0.80)
	},
	["Dao3"] = {
		Position = Vector3.new(915.57, 17.63, 1242.17),
		LookVector = Vector3.new(0.64, 0.00, -0.77)
	},
	["Dao4"] = {
		Position = Vector3.new(769.92, 20.90, -988.58),
		LookVector = Vector3.new(0.29, 0.00, 0.96)
	},
	["Dao5"] = {
		Position = Vector3.new(-433.47, 22.06, 957.79),
		LookVector = Vector3.new(-0.79, 0.00, 0.61)
	}
}

local savedCFrame = nil
local lockEnabled = true
local bossPresent = false
local returning = false
local currentBossIsland = nil
local lastCheckTime = 0
local moveToBossPosition = false

-- load vị trí
pcall(function()
	if readfile and isfile and isfile(FILE) then
		local data = HttpService:JSONDecode(readfile(FILE))
		savedCFrame = CFrame.new(
			data.x,data.y,data.z,
			data.r00,data.r01,data.r02,
			data.r10,data.r11,data.r12,
			data.r20,data.r21,data.r22
		)
	end
end)

local function savePosition(cf)
	local comp = {cf:GetComponents()}
	local save = {
		x=comp[1],y=comp[2],z=comp[3],
		r00=comp[4],r01=comp[5],r02=comp[6],
		r10=comp[7],r11=comp[8],r12=comp[9],
		r20=comp[10],r21=comp[11],r22=comp[12]
	}
	writefile(FILE,HttpService:JSONEncode(save))
end

local function notify(t)
	StarterGui:SetCore("SendNotification",{
		Title="Boss Checker",
		Text=t,
		Duration=3
	})
end

local function getHRP()
	if player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
end

local function distance(a,b)
	return (a.Position - b.Position).Magnitude
end

-- Hàm di chuyển đến vị trí boss với Tween
local function moveToBossPositionSmooth(targetCFrame)
	local hrp = getHRP()
	if not hrp then return end
	
	returning = true
	moveToBossPosition = true
	
	-- Tạo hiệu ứng di chuyển mượt
	local tweenInfo = TweenInfo.new(
		2, -- Thời gian di chuyển
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	
	local goal = {
		CFrame = targetCFrame
	}
	
	local tween = TweenService:Create(hrp, tweenInfo, goal)
	tween:Play()
	
	-- Chờ tween hoàn thành
	tween.Completed:Wait()
	
	moveToBossPosition = false
	returning = false
end

-- Hàm lấy CFrame từ thông tin đảo
local function getIslandCFrame(islandName)
	local island = Islands[islandName]
	if island then
		return CFrame.new(island.Position, island.Position + island.LookVector)
	end
	return nil
end

-- Hàm kiểm tra và di chuyển đến vị trí boss
local function checkAndMoveToBossPosition()
	if not bossPresent or not currentBossIsland then return end
	
	local targetCFrame = getIslandCFrame(currentBossIsland)
	if not targetCFrame then return end
	
	local hrp = getHRP()
	if not hrp then return end
	
	-- Kiểm tra khoảng cách với vị trí boss
	if distance(hrp.CFrame, targetCFrame) > 5 then
		notify("Đang di chuyển đến vị trí " .. currentBossIsland)
		moveToBossPositionSmooth(targetCFrame)
	else
		notify("Đã ở vị trí " .. currentBossIsland)
	end
end

-- check boss
local function checkBoss()
	local z = workspace:FindFirstChild("BossZones")
	if not z then return end
	
	local island = nil
	
	-- Tìm đảo có boss
	for i = 1, 7 do
		local name = "Island "..i
		if z:FindFirstChild(name) and z[name]:FindFirstChild("BossSpawnZone") then
			island = name
			break
		end
	end
	
	if island then
		-- Chuyển đổi tên island sang định dạng trong bảng Islands
		local islandKey = "Dao"..string.match(island, "%d+")
		
		if not bossPresent then
			bossPresent = true
			currentBossIsland = islandKey
			notify("Boss ở "..islandKey)
			
			-- Chờ 10 giây rồi kiểm tra vị trí
			task.spawn(function()
				task.wait(10)
				if bossPresent and currentBossIsland then
					checkAndMoveToBossPosition()
					
					-- Bắt đầu kiểm tra định kỳ mỗi 3 giây
					while bossPresent and currentBossIsland do
						task.wait(3)
						checkAndMoveToBossPosition()
					end
				end
			end)
		end
	else
		if bossPresent then
			bossPresent = false
			currentBossIsland = nil
			moveToBossPosition = false
			notify("Boss biến mất")
			
			task.spawn(function()
				task.wait(15)
				if lockEnabled and savedCFrame and not bossPresent and not returning then
					smoothReturn()
				end
			end)
		end
	end
end

-- quay lại từng bước
local function smoothReturn()
	if not savedCFrame then return end
	
	local hrp = getHRP()
	if not hrp then return end
	
	returning = true
	
	while distance(hrp.CFrame, savedCFrame) > 10 and not bossPresent and not moveToBossPosition do
		local dir = (savedCFrame.Position - hrp.Position).Unit
		hrp.CFrame = hrp.CFrame + dir * 10
		task.wait(0.1)
	end
	
	if not bossPresent and not moveToBossPosition then
		hrp.CFrame = savedCFrame
	end
	
	returning = false
end

-- lock position check (chỉ hoạt động khi không có boss và không đang di chuyển)
task.spawn(function()
	while true do
		if lockEnabled and savedCFrame and not bossPresent and not returning and not moveToBossPosition then
			local hrp = getHRP()
			if hrp then
				if distance(hrp.CFrame, savedCFrame) > 15 then
					hrp.CFrame = savedCFrame
				end
			end
		end
		task.wait(3)
	end
end)

-- boss scan
task.spawn(function()
	while true do
		checkBoss()
		task.wait(3)
	end
end)

-- GUI nhỏ gọn
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 90, 0, 55)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local set = Instance.new("TextButton", frame)
set.Size = UDim2.new(1, 0, 0, 25)
set.Text = "SET"
set.TextScaled = true
set.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
set.TextColor3 = Color3.new(1, 1, 1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 25)
toggle.Position = UDim2.new(0, 0, 0, 28)
toggle.Text = "LOCK ON"
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)

-- kéo GUI
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- save vị trí
set.MouseButton1Click:Connect(function()
	local hrp = getHRP()
	if hrp then
		savedCFrame = hrp.CFrame
		savePosition(hrp.CFrame)
		notify("Đã lưu vị trí")
	end
end)

-- toggle
toggle.MouseButton1Click:Connect(function()
	lockEnabled = not lockEnabled
	toggle.Text = lockEnabled and "LOCK ON" or "LOCK OFF"
end)
