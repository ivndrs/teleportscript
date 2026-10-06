local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
	MaxDistance = 500,
	Offset = Vector3.new(0, 3, 0),
	TeleportEnabled = true,
	ThirdPersonEnabled = false,
	MenuVisible = true,
}

-- Save the original camera settings so they can be restored.
local originalCameraMode = player.CameraMode
local originalMinZoom = player.CameraMinZoomDistance
local originalMaxZoom = player.CameraMaxZoomDistance

local function teleportToClick()
	if not CONFIG.TeleportEnabled then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart or humanoid.Health <= 0 then
		return
	end

	-- Prevent teleporting when the mouse is not pointing at a part.
	if not mouse.Target then
		warn("No valid teleport surface selected")
		return
	end

	local hitPosition = mouse.Hit.Position
	local distance = (hitPosition - rootPart.Position).Magnitude

	if distance > CONFIG.MaxDistance then
		warn(
			"Teleport location is too far away ("
				.. math.floor(distance)
				.. "/"
				.. CONFIG.MaxDistance
				.. " studs)"
		)
		return
	end

	local targetPosition = hitPosition + CONFIG.Offset

	-- PivotTo moves the complete character model instead of only its root part.
	character:PivotTo(CFrame.new(targetPosition) * rootPart.CFrame.Rotation)
end

local function setThirdPerson(enabled)
	CONFIG.ThirdPersonEnabled = enabled

	if enabled then
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 20
	else
		player.CameraMode = originalCameraMode
		player.CameraMinZoomDistance = originalMinZoom
		player.CameraMaxZoomDistance = originalMaxZoom
	end
end

-- UI creation

local oldGui = playerGui:FindFirstChild("TeleportMenu")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0, 0.5)
main.Position = UDim2.new(0, 28, 0.5, 0)
main.Size = UDim2.fromOffset(310, 245)
main.BackgroundColor3 = Color3.fromRGB(9, 7, 12)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3
mainStroke.Transparency = 0.05
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

local borderGradient = Instance.new("UIGradient")
borderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 35, 255)),
	ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 0, 200)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 75, 150)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 35, 255)),
})
borderGradient.Parent = mainStroke

local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.AnchorPoint = main.AnchorPoint
shadow.Position = UDim2.new(0, 34, 0.5, 8)
shadow.Size = main.Size
shadow.BackgroundColor3 = Color3.fromRGB(120, 0, 110)
shadow.BackgroundTransparency = 0.72
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = screenGui

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 16)
shadowCorner.Parent = shadow

main.ZIndex = 1

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 18)
padding.PaddingBottom = UDim.new(0, 18)
padding.PaddingLeft = UDim.new(0, 18)
padding.PaddingRight = UDim.new(0, 18)
padding.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = main

local title = Instance.new("TextLabel")
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "TELEPORT CONTROL"
title.TextColor3 = Color3.fromRGB(255, 225, 249)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.LayoutOrder = 2
subtitle.Size = UDim2.new(1, 0, 0, 36)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Point at a surface and press T\nPress M to hide or show this menu"
subtitle.TextColor3 = Color3.fromRGB(174, 154, 181)
subtitle.TextSize = 12
subtitle.TextWrapped = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.Parent = main

local function createButton(text, layoutOrder)
	local button = Instance.new("TextButton")
	button.LayoutOrder = layoutOrder
	button.Size = UDim2.new(1, 0, 0, 48)
	button.AutoButtonColor = false
	button.BackgroundColor3 = Color3.fromRGB(29, 22, 36)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamSemibold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(245, 232, 247)
	button.TextSize = 14
	button.Parent = main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 61, 122)
	stroke.Transparency = 0.35
	stroke.Thickness = 1
	stroke.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(47, 27, 57)
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(29, 22, 36)
	end)

	return button, stroke
end

local teleportButton, teleportStroke = createButton("", 3)
local cameraButton, cameraStroke = createButton("", 4)

local function updateButtons()
	if CONFIG.TeleportEnabled then
		teleportButton.Text = "TELEPORT: ENABLED"
		teleportButton.TextColor3 = Color3.fromRGB(255, 107, 220)
		teleportStroke.Color = Color3.fromRGB(255, 0, 190)
	else
		teleportButton.Text = "TELEPORT: DISABLED"
		teleportButton.TextColor3 = Color3.fromRGB(162, 150, 166)
		teleportStroke.Color = Color3.fromRGB(83, 69, 89)
	end

	if CONFIG.ThirdPersonEnabled then
		cameraButton.Text = "THIRD PERSON: ENABLED"
		cameraButton.TextColor3 = Color3.fromRGB(202, 135, 255)
		cameraStroke.Color = Color3.fromRGB(157, 64, 255)
	else
		cameraButton.Text = "THIRD PERSON: DISABLED"
		cameraButton.TextColor3 = Color3.fromRGB(162, 150, 166)
		cameraStroke.Color = Color3.fromRGB(83, 69, 89)
	end
end

teleportButton.Activated:Connect(function()
	CONFIG.TeleportEnabled = not CONFIG.TeleportEnabled
	updateButtons()
end)

cameraButton.Activated:Connect(function()
	setThirdPerson(not CONFIG.ThirdPersonEnabled)
	updateButtons()
end)

updateButtons()

-- Rotate the border gradient continuously.
local gradientRotation = 0

RunService.RenderStepped:Connect(function(deltaTime)
	gradientRotation = (gradientRotation + deltaTime * 80) % 360
	borderGradient.Rotation = gradientRotation
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.T then
		teleportToClick()
	elseif input.KeyCode == Enum.KeyCode.M then
		CONFIG.MenuVisible = not CONFIG.MenuVisible
		main.Visible = CONFIG.MenuVisible
		shadow.Visible = CONFIG.MenuVisible
	end
end)
