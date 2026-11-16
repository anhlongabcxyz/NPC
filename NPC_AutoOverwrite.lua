--[[
    NPC Control Panel - Auto Overwrite Edition
    Author: @anhlongabcxyz
]]--

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- [QUAN TRỌNG] Tự động dọn dẹp các bản cũ đang chạy trước khi khởi tạo bản mới
local core = game:FindFirstChildOfClass("CoreGui") or lp:WaitForChild("PlayerGui")
if core:FindFirstChild("SimpleNPCControl") then
	core.SimpleNPCControl:Destroy()
end

-- Xóa bỏ Highlight cũ của nhân vật nếu có để tránh bị lỗi hiển thị đè
if lp:FindFirstChildOfClass("Highlight") then
	for _, v in ipairs(lp:GetChildren()) do
		if v:IsA("Highlight") then
			v:Destroy()
		end
	end
end

-- 1. Bảng dữ liệu chức năng
local actions = {
	{title = "kill npc", des = "Tiêu diệt NPC ngay lập tức", val = 15, fn = function(npc)
		local hum = npc:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(15) end
	end},
	{title = "bring npc", des = "Kéo NPC đến vị trí của bạn", fn = function(npc)
		if lp.Character then npc:PivotTo(lp.Character:GetPivot()) end
	end},
	{title = "goto npc", des = "Dịch chuyển bạn đến chỗ NPC", fn = function(npc)
		if lp.Character then lp.Character:PivotTo(npc:GetPivot()) end
	end},
	{title = "control npc", des = "Điều khiển trực tiếp thân xác NPC", fn = function(state, npc) end},
	{title = "punish npc", des = "Đưa NPC bay lên không gian", fn = function(npc)
		npc:PivotTo(CFrame.new(0, 1000, 0))
	end},
	{title = "npc sit state", des = "Bật/Tắt trạng thái ngồi của NPC", fn = function(npc)
		local hum = npc:FindFirstChildOfClass("Humanoid")
		if hum then hum.Sit = not hum.Sit end
	end},
	{title = "npc jump state", des = "Lệnh cho NPC nhảy", val = 3, fn = function(npc)
		local hum = npc:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(3) end
	end},
	{title = "following npc", des = "Lệnh NPC đi theo bạn", fn = function(state, npc) end},
}

-- 2. Khởi tạo Giao diện chính (UI)
local ScreenGui = Instance.new("ScreenGui", core)
ScreenGui.Name = "SimpleNPCControl"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- Khung chính (Main Window)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 60)
Instance.new("UIDragDetector", MainFrame)

local MainScale = Instance.new("UIScale", MainFrame)

-- Thanh tiêu đề (Top Bar)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TopBar)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "✧ NPC Control Panel"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 170)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Thu Nhỏ (Minimize trong menu)
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Nút Mở/Thu nhỏ ngoài màn hình (Toggle To, hình ✧)
local OutsideToggle = Instance.new("Frame", ScreenGui)
OutsideToggle.Size = UDim2.new(0, 56, 0, 56)
OutsideToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
OutsideToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OutsideToggle.Visible = false
Instance.new("UICorner", OutsideToggle).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OutsideToggle).Color = Color3.fromRGB(0, 255, 170)
Instance.new("UIDragDetector", OutsideToggle)

local OutsideBtn = Instance.new("TextButton", OutsideToggle)
OutsideBtn.Size = UDim2.new(1, 0, 1, 0)
OutsideBtn.BackgroundTransparency = 1
OutsideBtn.Font = Enum.Font.GothamBold
OutsideBtn.Text = "✧"
OutsideBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
OutsideBtn.TextSize = 28

local ToggleScale = Instance.new("UIScale", OutsideToggle)
ToggleScale.Scale = 1

-- Hiệu ứng Intro mở đầu màn hình
local DarkOverlay = Instance.new("Frame", ScreenGui)
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkOverlay.BackgroundTransparency = 0.5
DarkOverlay.ZIndex = 5

local IntroBox = Instance.new("Frame", ScreenGui)
IntroBox.Size = UDim2.new(0, 240, 0, 240)
IntroBox.Position = UDim2.new(0.5, -120, 0.5, -120)
IntroBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
IntroBox.ZIndex = 6
Instance.new("UICorner", IntroBox).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", IntroBox).Color = Color3.fromRGB(0, 255, 170)

local IntroIcon = Instance.new("TextLabel", IntroBox)
IntroIcon.Size = UDim2.new(1, 0, 0, 120)
IntroIcon.Position = UDim2.new(0, 0, 0.1, 0)
IntroIcon.BackgroundTransparency = 1
IntroIcon.Font = Enum.Font.GothamBold
IntroIcon.Text = "✧"
IntroIcon.TextColor3 = Color3.fromRGB(0, 255, 170)
IntroIcon.TextSize = 72

local IntroName = Instance.new("TextLabel", IntroBox)
IntroName.Size = UDim2.new(1, 0, 0, 40)
IntroName.Position = UDim2.new(0, 0, 0.65, 0)
IntroName.BackgroundTransparency = 1
IntroName.Font = Enum.Font.GothamBold
IntroName.Text = "@anhlongabcxyz"
IntroName.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroName.TextSize = 16

-- Danh sách chức năng (ScrollingFrame)
local Scrolling = Instance.new("ScrollingFrame", MainFrame)
Scrolling.Size = UDim2.new(1, -20, 1, -55)
Scrolling.Position = UDim2.new(0, 10, 0, 48)
Scrolling.BackgroundTransparency = 1
Scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scrolling.ScrollBarThickness = 3

local UIList = Instance.new("UIListLayout", Scrolling)
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- 3. Logic Tạo Nút Gọn Gàng
local currentnpc

for _, data in ipairs(actions) do
	local btn = Instance.new("TextButton", Scrolling)
	btn.Size = UDim2.new(1, 0, 0, 46)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	
	local tLabel = Instance.new("TextLabel", btn)
	tLabel.Size = UDim2.new(1, -16, 0, 20)
	tLabel.Position = UDim2.new(0, 10, 0, 4)
	tLabel.BackgroundTransparency = 1
	tLabel.Font = Enum.Font.GothamBold
	tLabel.Text = data.title
	tLabel.TextColor3 = Color3.fromRGB(255, 220, 200)
	tLabel.TextSize = 13
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local dLabel = Instance.new("TextLabel", btn)
	dLabel.Size = UDim2.new(1, -16, 0, 18)
	dLabel.Position = UDim2.new(0, 10, 0, 24)
	dLabel.BackgroundTransparency = 1
	dLabel.Font = Enum.Font.SourceSans
	dLabel.Text = data.des
	dLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
	dLabel.TextSize = 11
	dLabel.TextXAlignment = Enum.TextXAlignment.Left

	btn.MouseButton1Click:Connect(function()
		if currentnpc then
			pcall(function() data.fn(currentnpc) end)
		end
	end)
end

-- 4. Chọn NPC bằng cách bấm chuột
mouse.Button1Down:Connect(function()
	if mouse.Target and mouse.Target.Parent then
		local model = mouse.Target.Parent
		local hum = model:FindFirstChildOfClass("Humanoid")
		local player = Players:GetPlayerFromCharacter(model)
		if hum and not player then
			currentnpc = model
		end
	end
end)

-- 5. Thu nhỏ / Mở rộng Menu mượt mà
local minimized = false
local function toggleUI()
	minimized = not minimized
	if minimized then
		OutsideToggle.Visible = true
		ToggleScale.Scale = 0
		TweenService:Create(MainScale, TweenInfo.new(0.3), {Scale = 0}):Play()
		TweenService:Create(ToggleScale, TweenInfo.new(0.3), {Scale = 1}):Play()
		task.wait(0.3)
		MainFrame.Visible = false
	else
		MainFrame.Visible = true
		TweenService:Create(MainScale, TweenInfo.new(0.3), {Scale = 1}):Play()
		TweenService:Create(ToggleScale, TweenInfo.new(0.3), {Scale = 0}):Play()
		task.wait(0.3)
		OutsideToggle.Visible = false
	end
end

MinBtn.MouseButton1Click:Connect(toggleUI)
OutsideBtn.MouseButton1Click:Connect(toggleUI)

-- 6. Chạy Hiệu Ứng Intro Khi Khởi Động
task.spawn(function()
	MainScale.Scale = 0
	local blur = Instance.new("BlurEffect", Lighting)
	blur.Name = "IntroBlur"
	blur.Size = 15
	
	task.wait(2.5)
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
	TweenService:Create(DarkOverlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(IntroBox, TweenInfo.new(0.5), {Size = UDim2.new(0,0,0,0)}):Play()
	task.wait(0.5)
	DarkOverlay:Destroy()
	IntroBox:Destroy()
	blur:Destroy()
	
	TweenService:Create(MainScale, TweenInfo.new(0.4), {Scale = 1}):Play()
end)
