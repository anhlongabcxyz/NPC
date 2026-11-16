--[[
    NPC Control Panel - All In One
    Author: @anhlongabcxyz
    Combined & Optimized UI/UX
]]--

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- 1. Data Table
local save = {
	["1"] = {title = "kill npc", des = "instant kill the npc", val = 15},
	["2"] = {title = "bring npc", des  = "teleport the npc to your position"},
	["3"] = {title = "goto npc", des = "teleport your character to npc position"},
	["4"] = {title = "control npc", des = "control npc/dummy until the npc loses network ownership"},
	["5"] = {title = "punish npc", des = "make npc disappear into space"},
	["6"] = {title = "npc sit state", des = "make npc in sitting position"},
	["7"] = {title = "npc jump state", des = "make npc jump", val = 3},
	["8"] = {title = "following npc", des = "make npc follow you"},
	["9"] = {title = "kill aura any npc", val = 15},
	["10"] = {title = "jump aura any npc", val = 3}
}

-- 2. GUI Setup & Core UI
local core
if game:FindFirstChildOfClass("CoreGui") then
	if gethui then
		core = gethui()
	else
		core = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
else
	core = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui", core)
ScreenGui.Name = "NPCControlPanel"
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 5
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.BorderSizePixel = 0
Frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Size = UDim2.new(0, 560, 0, 380)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 1.5

local UIScale = Instance.new("UIScale", Frame)
local UIDrag = Instance.new("UIDragDetector", Frame)

-- Shadow
local Shadow = Instance.new("ImageLabel", Frame)
Shadow.ZIndex = -2
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://4654143143"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.SliceCenter = Rect.new(0, 0, 1, 1)

-- Top Bar
local Bar = Instance.new("Frame", Frame)
Bar.BorderSizePixel = 0
Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Bar.Size = UDim2.new(1, -20, 0, 36)
Bar.Position = UDim2.new(0, 10, 0, 10)

local BarCorner = Instance.new("UICorner", Bar)
BarCorner.CornerRadius = UDim.new(0, 8)

local BarTitle = Instance.new("TextLabel", Bar)
BarTitle.BackgroundTransparency = 1
BarTitle.Position = UDim2.new(0, 12, 0, 0)
BarTitle.Size = UDim2.new(1, -50, 1, 0)
BarTitle.Font = Enum.Font.GothamBold
BarTitle.Text = "NPC Control | @anhlongabcxyz"
BarTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
BarTitle.TextSize = 14
BarTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button inside Bar
local MinimizeBtn = Instance.new("ImageButton", Bar)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
MinimizeBtn.Position = UDim2.new(1, -8, 0.5, 0)
MinimizeBtn.Image = "rbxassetid://6026568240"
MinimizeBtn.ScaleType = Enum.ScaleType.Fit

-- Smaller Outside Toggle / Icon (Khi thu nhỏ)
local IconFrame = Instance.new("Frame", ScreenGui)
IconFrame.Visible = false
IconFrame.BorderSizePixel = 0
IconFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
IconFrame.AnchorPoint = Vector2.new(0.5, 0.5)
IconFrame.Size = UDim2.new(0, 38, 0, 38) -- Kích thước nhỏ gọn hơn nhiều ở ngoài
IconFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
IconFrame.BackgroundTransparency = 0.25

local IconCorner = Instance.new("UICorner", IconFrame)
IconCorner.CornerRadius = UDim.new(1, 0)

local IconStroke = Instance.new("UIStroke", IconFrame)
IconStroke.Color = Color3.fromRGB(90, 90, 90)
IconStroke.Thickness = 1.5

local IconImgBtn = Instance.new("ImageButton", IconFrame)
IconImgBtn.BackgroundTransparency = 1
IconImgBtn.AnchorPoint = Vector2.new(0.5, 0.5)
IconImgBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
IconImgBtn.Size = UDim2.new(0.65, 0, 0.65, 0)
IconImgBtn.Image = "rbxassetid://11104447804"
IconImgBtn.ScaleType = Enum.ScaleType.Fit

local IconDrag = Instance.new("UIDragDetector", IconFrame)
local IconScale = Instance.new("UIScale", IconFrame)
IconScale.Scale = 1

-- Dark Overlay & Intro Screen
local DarkOverlay = Instance.new("Frame", ScreenGui)
DarkOverlay.Visible = false
DarkOverlay.ZIndex = -10
DarkOverlay.BorderSizePixel = 0
DarkOverlay.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundTransparency = 0.65

local IntroFrame = Instance.new("Frame", ScreenGui)
IntroFrame.Visible = false
IntroFrame.AnchorPoint = Vector2.new(0.5, 0.5)
IntroFrame.Size = UDim2.new(0, 220, 0, 260)
IntroFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)

local IntroCorner = Instance.new("UICorner", IntroFrame)
IntroCorner.CornerRadius = UDim.new(0, 12)

local IntroIcon = Instance.new("ImageLabel", IntroFrame)
IntroIcon.BackgroundTransparency = 1
IntroIcon.Image = "rbxassetid://11104447804"
IntroIcon.Size = UDim2.new(0, 80, 0, 80)
IntroIcon.Position = UDim2.new(0.5, -40, 0.2, 0)
IntroIcon.ScaleType = Enum.ScaleType.Fit

local IntroTitle = Instance.new("TextLabel", IntroFrame)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroTitle.TextSize = 14
IntroTitle.Size = UDim2.new(1, 0, 0, 30)
IntroTitle.Position = UDim2.new(0, 0, 0.65, 0)
IntroTitle.Text = "@anhlongabcxyz"

local IntroScale = Instance.new("UIScale", IntroFrame)

-- Scrolling Container for Main Features
local MainScrolling = Instance.new("ScrollingFrame", Frame)
MainScrolling.Active = true
MainScrolling.ScrollingDirection = Enum.ScrollingDirection.Y
MainScrolling.BorderSizePixel = 0
MainScrolling.BackgroundTransparency = 1
MainScrolling.Size = UDim2.new(0.95, 0, 0.78, 0)
MainScrolling.Position = UDim2.new(0.025, 0, 0.16, 0)
MainScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScrolling.ScrollBarThickness = 4
MainScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)

local UIList = Instance.new("UIListLayout", MainScrolling)
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Templates for Buttons & Toggles
local ButtonTemplate = Instance.new("Frame")
ButtonTemplate.Size = UDim2.new(1, 0, 0, 52)
ButtonTemplate.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ButtonTemplate.BorderSizePixel = 0
local BTNCorn = Instance.new("UICorner", ButtonTemplate)
BTNCorn.CornerRadius = UDim.new(0, 8)
local BTNStroke = Instance.new("UIStroke", ButtonTemplate)
BTNStroke.Color = Color3.fromRGB(70, 70, 70)
BTNStroke.Thickness = 0

local BTNTitle = Instance.new("TextLabel", ButtonTemplate)
BTNTitle.Name = "title"
BTNTitle.BackgroundTransparency = 1
BTNTitle.Position = UDim2.new(0, 12, 0, 6)
BTNTitle.Size = UDim2.new(0.8, 0, 0, 20)
BTNTitle.Font = Enum.Font.GothamBold
BTNTitle.TextColor3 = Color3.fromRGB(255, 220, 213)
BTNTitle.TextSize = 13
BTNTitle.TextXAlignment = Enum.TextXAlignment.Left

local BTNDes = Instance.new("TextLabel", ButtonTemplate)
BTNDes.Name = "des"
BTNDes.BackgroundTransparency = 1
BTNDes.Position = UDim2.new(0, 12, 0, 26)
BTNDes.Size = UDim2.new(0.9, 0, 0, 20)
BTNDes.Font = Enum.Font.SourceSans
BTNDes.TextColor3 = Color3.fromRGB(190, 190, 190)
BTNDes.TextSize = 12
BTNDes.TextXAlignment = Enum.TextXAlignment.Left

local BTNClick = Instance.new("TextButton", ButtonTemplate)
BTNClick.Name = "click"
BTNClick.BackgroundTransparency = 1
BTNClick.Size = UDim2.new(1, 0, 1, 0)
BTNClick.Text = ""

-- Toggle Template
local ToggleTemplate = ButtonTemplate:Clone()
local ToggleIndicator = Instance.new("Frame", ToggleTemplate)
ToggleIndicator.Name = "toggle"
ToggleIndicator.Size = UDim2.new(0, 36, 0, 20)
ToggleIndicator.AnchorPoint = Vector2.new(1, 0.5)
ToggleIndicator.Position = UDim2.new(1, -12, 0.5, 0)
ToggleIndicator.BackgroundColor3 = Color3.fromRGB(188, 0, 0)
ToggleIndicator.BorderSizePixel = 0
Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(1, 0)

-- Logic Functions & Highlight Setup
local fast = TweenInfo.new(.4, Enum.EasingStyle.Exponential)
local medium = TweenInfo.new(.6)
local slow = TweenInfo.new(.8)

local currentnpc
local clicknpc = true

local highlight = Instance.new("Highlight")
highlight.Parent = lp
highlight.FillTransparency = 1
highlight.OutlineTransparency = 1

local function light(adornee, color)
	task.spawn(function()
		highlight.Adornee = adornee
		highlight.OutlineColor = color
		TweenService:Create(highlight, medium, {OutlineTransparency = 0}):Play()
		task.wait(.5)
		TweenService:Create(highlight, medium, {OutlineTransparency = 1}):Play()
	end)
end

local function isnpc(ins)
	local humanoid = ins:FindFirstChildOfClass("Humanoid")
	local player = Players:GetPlayerFromCharacter(ins)
	if humanoid and not player then
		return ins
	end
	return nil
end

local function partowner(part)
	return part.ReceiveAge == 0
end

-- UI Builder functions
local function createButton(titleText, desText, func)
	local sample = ButtonTemplate:Clone()
	sample.Parent = MainScrolling
	sample.title.Text = titleText or ""
	sample.des.Text = desText or ""

	sample.click.MouseButton1Click:Connect(function()
		if func then
			task.spawn(function()
				TweenService:Create(sample.UIStroke, TweenInfo.new(0.1), {Thickness = 1}):Play()
				task.wait(.2)
				TweenService:Create(sample.UIStroke, TweenInfo.new(0.1), {Thickness = 0}):Play()
			end)
			local _, err = pcall(func)
			if err then warn(err) end
		end
	end)
end

local function createToggle(titleText, desText, func)
	local sample = ToggleTemplate:Clone()
	sample.Parent = MainScrolling
	sample.title.Text = titleText or ""
	sample.des.Text = desText or ""

	local toggled = false
	sample.click.MouseButton1Click:Connect(function()
		toggled = not toggled
		if func then
			task.spawn(function()
				TweenService:Create(sample.toggle, TweenInfo.new(.2), {BackgroundColor3 = toggled and Color3.fromRGB(26, 255, 0) or Color3.fromRGB(188, 0, 0)}):Play()
				TweenService:Create(sample.UIStroke, TweenInfo.new(.1), {Thickness = 1}):Play()
				task.wait(.2)
				TweenService:Create(sample.UIStroke, TweenInfo.new(.1), {Thickness = 0}):Play()
			end)
			local _, err = pcall(func, toggled)
			if err then warn(err) end
		end
	end)

	local addition = {}
	function addition:swich(bool)
		toggled = bool
		TweenService:Create(sample.toggle, TweenInfo.new(.2), {BackgroundColor3 = toggled and Color3.fromRGB(26, 255, 0) or Color3.fromRGB(188, 0, 0)}):Play()
	end
	return addition
end

-- Build Controls using Table data
createButton(save["1"].title, save["1"].des, function()
	if currentnpc then
		local part = currentnpc:FindFirstChild("HumanoidRootPart")
		if part and partowner(part) then
			local hum = currentnpc:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(save["1"].val) end
		else
			light(currentnpc, Color3.fromRGB(255, 0, 0))
		end
	end
end)

createButton(save["2"].title, save["2"].des, function()
	if currentnpc then
		local part = currentnpc:FindFirstChild("HumanoidRootPart")
		if part and partowner(part) then
			if lp and lp.Character then
				currentnpc:PivotTo(lp.Character:GetPivot())
			end
		else
			light(currentnpc, Color3.fromRGB(255, 0, 0))
		end
	end
end)

createButton(save["3"].title, save["3"].des, function()
	if currentnpc then
		local part = currentnpc:FindFirstChild("HumanoidRootPart")
		if part then
			if lp and lp.Character then
				lp.Character:PivotTo(currentnpc:GetPivot())
			end
		else
			light(currentnpc, Color3.fromRGB(255, 0, 0))
		end
	end
end)

local chr, cons
createToggle(save["4"].title, save["4"].des, function(a)
	if a then
		if currentnpc then
			local part = currentnpc:FindFirstChild("HumanoidRootPart")
			if part and partowner(part) then
				if lp and lp.Character then
					chr = lp.Character
					lp.Character = currentnpc
					Workspace.CurrentCamera.CameraSubject = currentnpc:FindFirstChild("HumanoidRootPart")
					local move = 0.01
					cons = RunService.PreSimulation:Connect(function()
						local hum = lp.Character:FindFirstChildOfClass("Humanoid")
						if lp.Character and hum then
							hum.RootPart.CFrame += Vector3.new(0, move, 0)
							move = -move
						else
							if cons then cons:Disconnect(); cons = nil end
						end
					end)
				end
			else
				light(currentnpc, Color3.fromRGB(255, 0, 0))
			end
		end
	else
		if chr then
			lp.Character = chr
			Workspace.CurrentCamera.CameraSubject = chr.Humanoid
			chr = nil
			if cons then cons:Disconnect(); cons = nil end
		end
	end
end)

createButton(save["5"].title, save["5"].des, function()
	if currentnpc then
		local part = currentnpc:FindFirstChild("HumanoidRootPart")
		if part and partowner(part) then
			currentnpc:PivotTo(CFrame.new(0, 1000, 0))
		else
			light(currentnpc, Color3.fromRGB(255, 0, 0))
		end
	end
end)

createButton(save["6"].title, save["6"].des, function()
	if currentnpc then
		local part = currentnpc:FindFirstChild("HumanoidRootPart")
		if part and partowner(part) then
			local hum = currentnpc:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit = not hum.Sit end
		else
			light(currentnpc, Color3.fromRGB(255, 0, 0))
		end
	end
end)

createButton(save["7"].title, save["7"].des, function()
	if currentnpc then
		local part = currentnpc:FindFirstChild("HumanoidRootPart")
		if part and partowner(part) then
			local hum = currentnpc:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(save["7"].val) end
		else
			light(currentnpc, Color3.fromRGB(255, 0, 0))
		end
	end
end)

local con, follownpc
follownpc = createToggle(save["8"].title, save["8"].des, function(a)
	if a then
		con = RunService.RenderStepped:Connect(function()
			if currentnpc then
				local part = currentnpc:FindFirstChild("HumanoidRootPart")
				if part and partowner(part) then
					local hum = currentnpc:FindFirstChildOfClass("Humanoid")
					if hum and lp.Character then
						local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							hum:MoveTo(hrp.Position + Vector3.new(-4, 0, 0))
						end
					end
				else
					light(currentnpc, Color3.fromRGB(255, 0, 0))
					if con then follownpc:swich(false); con:Disconnect(); con = nil end
				end
			else
				if con then follownpc:swich(false); con:Disconnect(); con = nil end
			end
		end)
	else
		if con then con:Disconnect(); con = nil end
	end
end)

local con1
createToggle("kill aura any npc", "Automatically kill nearby NPCs", function(a)
	if a then
		con1 = RunService.Stepped:Connect(function()
			local hrp1 = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not hrp1 then return end
			local nbp = Workspace:GetPartBoundsInRadius(hrp1.Position, 13)
			for _, part in pairs(nbp) do
				local model = part:FindFirstAncestorOfClass("Model")
				if model and isnpc(model) then
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if hrp and partowner(hrp) and not hrp.Anchored and model ~= lp.Character then
						local hum = model:FindFirstChildOfClass("Humanoid")
						if hum then hum:ChangeState(save["9"].val) end
					end
				end
			end
		end)
	else
		if con1 then con1:Disconnect(); con1 = nil end
	end
end)

local con2
createToggle("jump aura any npc", "Automatically make nearby NPCs jump", function(a)
	if a then
		con2 = RunService.Stepped:Connect(function()
			local hrp1 = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not hrp1 then return end
			local nbp = Workspace:GetPartBoundsInRadius(hrp1.Position, 13)
			for _, part in pairs(nbp) do
				local model = part:FindFirstAncestorOfClass("Model")
				if model and isnpc(model) then
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if hrp and partowner(hrp) and not hrp.Anchored and model ~= lp.Character then
						local hum = model:FindFirstChildOfClass("Humanoid")
						if hum then hum:ChangeState(save["10"].val) end
					end
				end
			end
		end)
	else
		if con2 then con2:Disconnect(); con2 = nil end
	end
end)

-- Mouse click selection
mouse.Button1Down:Connect(function()
	if clicknpc and mouse.Target and mouse.Target.Parent:FindFirstChild("HumanoidRootPart") then
		local model = mouse.Target.Parent
		if model:FindFirstChild("HumanoidRootPart").Anchored == false then
			if not Players:GetPlayerFromCharacter(model) then
				if partowner(model:FindFirstChild("HumanoidRootPart")) then
					currentnpc = model
					light(currentnpc, Color3.fromRGB(0, 255, 0))
				else
					light(model, Color3.fromRGB(255, 0, 0))
				end
			end
		else
			light(model, Color3.fromRGB(255, 0, 0))
		end
	end
end)

RunService.RenderStepped:Connect(function()
	pcall(function()
		sethiddenproperty(lp, "SimulationRadius", 150)
	end)
end)

-- Minimize Logic
local minimizebool = false
local function toggleMinimize()
	minimizebool = not minimizebool
	if minimizebool then
		IconFrame.Visible = true
		IconScale.Scale = 0
		TweenService:Create(UIScale, fast, {Scale = 0}):Play()
		TweenService:Create(IconScale, fast, {Scale = 1}):Play()
		task.wait(.5)
		Frame.Visible = false
	else
		Frame.Visible = true
		TweenService:Create(UIScale, fast, {Scale = 1}):Play()
		TweenService:Create(IconScale, fast, {Scale = 0}):Play()
		task.wait(.5)
		IconFrame.Visible = false
	end
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)
IconImgBtn.MouseButton1Click:Connect(toggleMinimize)

-- Intro Animation
local function playIntro()
	DarkOverlay.Visible = true
	DarkOverlay.BackgroundTransparency = 1
	IntroIcon.ImageTransparency = 1
	IntroTitle.TextTransparency = 1
	IntroScale.Scale = 0
	IntroFrame.BackgroundTransparency = 1
	IntroFrame.Visible = true
	UIScale.Scale = 0

	local blur = Instance.new("BlurEffect")
	blur.Name = "intro_blur"
	blur.Size = 0
	blur.Parent = Lighting

	TweenService:Create(blur, slow, {Size = 20}):Play()
	TweenService:Create(DarkOverlay, slow, {BackgroundTransparency = 0.65}):Play()
	task.wait(.2)
	TweenService:Create(IntroFrame, medium, {BackgroundTransparency = 0}):Play()
	TweenService:Create(IntroScale, medium, {Scale = 1}):Play()
	task.wait(.2)
	TweenService:Create(IntroIcon, medium, {ImageTransparency = 0}):Play()
	task.wait(.3)
	TweenService:Create(IntroTitle, medium, {TextTransparency = 0}):Play()
	task.wait(3.5)
	TweenService:Create(blur, slow, {Size = 0}):Play()
	TweenService:Create(IntroFrame, medium, {BackgroundTransparency = 1}):Play()
	TweenService:Create(IntroScale, medium, {Scale = 0}):Play()
	task.wait(.3)
	TweenService:Create(DarkOverlay, slow, {BackgroundTransparency = 1}):Play()
	task.wait(.5)
	TweenService:Create(UIScale, medium, {Scale = 1}):Play()
	DarkOverlay.Visible = false
	IntroFrame.Visible = false
	blur:Destroy()
end

playIntro()
