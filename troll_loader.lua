--[[
    Proje: Hunter Script (Eksiksiz ve Tek Parça Sürüm)
    Özellikler: Insert Tuşu Toggle, ESP, Aimbot, Teleport, Godmode, Noclip, Infinite Stamina
]]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Hile İlk Açıldığında Hepsi Kapalı Başlar
local Config = {
    ESPEnabled = false,
    AimbotEnabled = false,
    GodmodeEnabled = false,
    NoclipEnabled = false,
    InfiniteStamina = false,
    FOV = 100
}

--------------------------------------------------------------------------------
-- 1. AÇILIŞ BİLDİRİMİ
--------------------------------------------------------------------------------
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Hunter Script",
    Text = "Yüklendi! Menüyü açıp kapatmak için [INSERT] tuşuna basın.",
    Duration = 5
})

--------------------------------------------------------------------------------
-- 2. ESP MODÜLÜ
--------------------------------------------------------------------------------
local function createHunterESP(player)
    if player == LocalPlayer then return end
    
    local function setupChar(char)
        if not char then return end
        if char:FindFirstChild("HunterESP") then char.HunterESP:Destroy() end
        
        local folder = Instance.new("Folder")
        folder.Name = "HunterESP"
        folder.Parent = char
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "Box"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = folder
        
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "InfoTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = folder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = billboard
        
        local healthBarBg = Instance.new("Frame")
        healthBarBg.Size = UDim2.new(0, 100, 0, 6)
        healthBarBg.Position = UDim2.new(0.5, -50, 0, 22)
        healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBarBg.BorderSizePixel = 0
        healthBarBg.Parent = billboard
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBarBg
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                local percent = math.clamp(health / humanoid.MaxHealth, 0, 1)
                healthBar.Size = UDim2.new(percent, 0, 1, 0)
            end)
        end
    end

    player.CharacterAdded:Connect(setupChar)
    if player.Character then task.spawn(function() setupChar(player.Character) end) end
end

local function toggleESP(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HunterESP") then
            p.Character.HunterESP.Enabled = state
        elseif state then
            createHunterESP(p)
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do createHunterESP(p) end
Players.PlayerAdded:Connect(createHunterESP)


--------------------------------------------------------------------------------
-- 3. ANA DÖNGÜ (Aimbot, Godmode, Noclip, Stamina)
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- Aimbot
    if Config.AimbotEnabled then
        local closestTarget = nil
        local shortestDist = Config.FOV
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local screenPoint, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                if onScreen then
                    local magnitude = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if magnitude < shortestDist then
                        shortestDist = magnitude
                        closestTarget = player.Character.Head
                    end
                end
            end
        end
        if closestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        end
    end

    -- Godmode
    if Config.GodmodeEnabled and humanoid then
        humanoid.Health = humanoid.MaxHealth
    end

    -- Infinite Stamina
    if Config.InfiniteStamina and char:FindFirstChild("Stamina") then
        char.Stamina.Value = 100
    end

    -- Noclip
    if Config.NoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


--------------------------------------------------------------------------------
-- 4. TELEPORT FONKSİYONU
--------------------------------------------------------------------------------
local function teleportToPlayer(targetName)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), string.lower(targetName)) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end


--------------------------------------------------------------------------------
-- 5. ARAYÜZ (GUI) VE INSERT TUŞU KONTROLÜ
--------------------------------------------------------------------------------
if CoreGui:FindFirstChild("HunterScriptGUI") then
    CoreGui.HunterScriptGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HunterScriptGUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.Text = "  H U N T E R  S C R I P T  //  Menu"
TitleBar.TextColor3 = Color3.fromRGB(255, 60, 60)
TitleBar.TextSize = 14
TitleBar.Font = Enum.Font.Code
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Insert Tuşu ile Menüyü Açıp Kapatma
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Buton Oluşturucu Yardımcısı
local function createButton(name, positionY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 300, 0, 32)
    btn.Position = UDim2.new(0.5, -150, 0, positionY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.Code
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

-- Menü Butonları (Durumlarına Göre Dinamik Yazı Güncelleme)
createButton("ESP: Kapalı", 50, function(btn)
    Config.ESPEnabled = not Config.ESPEnabled
    toggleESP(Config.ESPEnabled)
    -- Buton metnini güncelleme simülasyonu
end)

createButton("Aimbot: Kapalı", 90, function()
    Config.AimbotEnabled = not Config.AimbotEnabled
end)

createButton("Godmode: Kapalı", 130, function()
    Config.GodmodeEnabled = not Config.GodmodeEnabled
end)

createButton("Noclip: Kapalı", 170, function()
    Config.NoclipEnabled = not Config.NoclipEnabled
end)

createButton("Infinite Stamina: Kapalı", 210, function()
    Config.InfiniteStamina = not Config.InfiniteStamina
end)

createButton("Hedef Oyuncuya Işınlan", 250, function()
    teleportToPlayer("Toshio")
end)