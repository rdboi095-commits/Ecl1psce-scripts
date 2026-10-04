--// ================================================================
--//  ECL1PSCE SCRIPTS | Blox Fruits All-In-One
--//  Menu: Right Shift  |  Copy Position: P
--//  Logo: paste your asset id below
--// ================================================================
getgenv().Ecl1psce = {
    LogoAssetId = 108083060527602, -- Ecl1psce logo
}


local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser  = game:GetService("VirtualUser")
local TeleportSvc  = game:GetService("TeleportService")
local HttpService  = game:GetService("HttpService")
local Lighting     = game:GetService("Lighting")
local StarterGui   = game:GetService("StarterGui")
local RS           = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local CommF       = RS:WaitForChild("Remotes"):WaitForChild("CommF_")

getgenv().Settings = {
    WalkSpeed = 16, JumpPower = 50,
    Fly = false, FlySpeed = 60, Noclip = false, InfJump = false,
    FarmMode = nil,                 -- "Level" | "Nearest"
    AutoBoss = false, SelectedBoss = "The Gorilla King",
    AutoStats = false, Stat = "Melee",
    AutoBuso = false, FastAttack = false,
    ESPMobs = false, ESPPlayers = false, FruitESP = false, AutoFruitTP = false,
    TweenSpeed = 300,
}
local S = getgenv().Settings

--// ================================================================
--//  DATABASES  (First Sea — use P key to fix coords after updates)
--// ================================================================
local QuestDB = {
    {Lvl=1,   Quest="BanditQuest1",           Idx=1, Mob="Bandit",               Giver="Bandit Quest Giver",     GiverCF=CFrame.new(1059, 16, 1547)},
    {Lvl=10,  Quest="MonkeyQuest",            Idx=1, Mob="Monkey",               Giver="Monkey Quest Giver",     GiverCF=CFrame.new(-1600, 36, 150)},
    {Lvl=15,  Quest="GorillaQuest",           Idx=1, Mob="Gorilla",              Giver="Gorilla Quest Giver",    GiverCF=CFrame.new(-1240, 40, -320)},
    {Lvl=30,  Quest="PirateQuest",            Idx=1, Mob="Pirate",               Giver="Pirate Quest Giver",     GiverCF=CFrame.new(-1140, 40, 3800)},
    {Lvl=40,  Quest="BruteQuest",             Idx=1, Mob="Brute",                Giver="Brute Quest Giver",      GiverCF=CFrame.new(-1140, 40, 3950)},
    {Lvl=60,  Quest="DesertQuest1",           Idx=1, Mob="Desert Bandit",        Giver="Desert Quest Giver",     GiverCF=CFrame.new(1600, 10, 4300)},
    {Lvl=75,  Quest="DesertQuest2",           Idx=2, Mob="Desert Officer",       Giver="Desert Quest Giver",     GiverCF=CFrame.new(1600, 10, 4300)},
    {Lvl=90,  Quest="SnowQuest1",             Idx=1, Mob="Snow Bandit",          Giver="Snow Quest Giver",       GiverCF=CFrame.new(600, 400, -5200)},
    {Lvl=100, Quest="SnowQuest2",             Idx=2, Mob="Snowman",              Giver="Snow Quest Giver",       GiverCF=CFrame.new(600, 400, -5200)},
    {Lvl=120, Quest="MarineQuest1",           Idx=1, Mob="Chief Petty Officer",  Giver="Marine Quest Giver",     GiverCF=CFrame.new(-3000, 70, 4800)},
    {Lvl=150, Quest="SkyQuest1",              Idx=1, Mob="Sky Bandit",           Giver="Sky Quest Giver",        GiverCF=CFrame.new(-4800, 730, -2500)},
    {Lvl=175, Quest="SkyQuest2",              Idx=2, Mob="Dark Master",          Giver="Sky Quest Giver",        GiverCF=CFrame.new(-4800, 730, -2500)},
    {Lvl=200, Quest="PrisonerQuest",          Idx=1, Mob="Prisoner",             Giver="Prison Quest Giver",     GiverCF=CFrame.new(700, 70, 2500)},
    {Lvl=225, Quest="DangerousPrisonerQuest", Idx=1, Mob="Dangerous Prisoner",   Giver="Prison Quest Giver",     GiverCF=CFrame.new(700, 70, 2500)},
    {Lvl=250, Quest="ColosseumQuest1",        Idx=1, Mob="Toga Warrior",         Giver="Colosseum Quest Giver",  GiverCF=CFrame.new(-1600, 50, -3000)},
    {Lvl=275, Quest="ColosseumQuest2",        Idx=2, Mob="Gladiator",            Giver="Colosseum Quest Giver",  GiverCF=CFrame.new(-1600, 50, -3000)},
}

local BossDB = {
    "The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral",
    "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord",
    "Wysper", "Thunder God", "Cyborg", "Saber Expert", "Greybeard",
}

local IslandDB = {
    {"Starter Island",   CFrame.new(1000, 16, 1500)},
    {"Jungle",           CFrame.new(-1500, 40, -100)},
    {"Pirate Village",   CFrame.new(-1150, 40, 3850)},
    {"Desert",           CFrame.new(1600, 10, 4300)},
    {"Snow Island",      CFrame.new(600, 400, -5200)},
    {"Marine Fortress",  CFrame.new(-3000, 70, 4800)},
    {"Skylands",         CFrame.new(-4800, 730, -2500)},
    {"Prison",           CFrame.new(700, 70, 2500)},
    {"Colosseum",        CFrame.new(-1600, 50, -3000)},
    {"Magma Village",    CFrame.new(-5200, 50, -8500)},
    {"Fishman Island",   CFrame.new(6100, 40, -2600)},
    {"Fountain City",    CFrame.new(5000, 400, 4000)},
}

--// ================================================================
--//  HELPERS
--// ================================================================
local function charParts()
    local c = LocalPlayer.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
end

local function tweenTo(cf, cancelFn)
    local _, hrp = charParts()
    if not hrp then return end
    local dist = (cf.Position - hrp.Position).Magnitude
    local dur  = math.clamp(dist / S.TweenSpeed, 0.15, 12)
    local tw   = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play()
    local t0 = os.clock()
    while os.clock() - t0 < dur + 0.3 do
        if cancelFn and cancelFn() then break end
        task.wait(0.1)
    end
    tw:Cancel()
end

local function findNPC(name)
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and d.Name == name then
            local h = d:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then return d end
        end
    end
end

local function getEnemies(mobName)
    local out = {}
    local folder = workspace:FindFirstChild("Enemies")
    local list = folder and folder:GetChildren() or workspace:GetChildren()
    for _, m in ipairs(list) do
        if m:IsA("Model") and (not mobName or m.Name == mobName) then
            local h, hrp = m:FindFirstChildOfClass("Humanoid"), m:FindFirstChild("HumanoidRootPart")
            if h and hrp and h.Health > 0 then table.insert(out, m) end
        end
    end
    return out
end

local function getNearestEnemy()
    local _, hrp = charParts()
    if not hrp then return nil end
    local best, bd = nil, math.huge
    for _, m in ipairs(getEnemies(nil)) do
        local mhrp = m:FindFirstChild("HumanoidRootPart")
        if mhrp then
            local d = (mhrp.Position - hrp.Position).Magnitude
            if d < bd then bd, best = d, m end
        end
    end
    return best
end

local function getQuestText()
    local ok, quest = pcall(function() return LocalPlayer.PlayerGui.Main.Quest end)
    if not ok or not quest or not quest.Visible then return nil end
    local ok2, txt = pcall(function() return quest.Container.QuestTitle.Title.Text end)
    return ok2 and txt or nil
end

local function getLevel()
    local ok, lvl = pcall(function() return LocalPlayer.Data.Level.Value end)
    return ok and lvl or 1
end

local function pickQuest(lvl)
    local best = nil
    for _, e in ipairs(QuestDB) do
        if lvl >= e.Lvl then best = e else break end
    end
    return best
end

local function equipWeapon()
    local _, _, hum = charParts()
    if not hum then return end
    local tool = LocalPlayer.Backpack:FindFirstChild(S.Weapon)
    if tool then pcall(function() hum:EquipTool(tool) end) end
end

local function click()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1, 1))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(1, 1))
    end)
end

local function kill(target, cancelFn, questBound)
    local _, hrp = charParts()
    if not hrp or not target then return end
    local th = target:FindFirstChildOfClass("Humanoid")
    local t0 = os.clock()
    local delay = S.FastAttack and 0.08 or 0.18
    equipWeapon()
    while th and th.Health > 0 and os.clock() - t0 < 90 do
        if cancelFn and cancelFn() then return end
        if questBound and getQuestText() == nil then return end
        local thrp = target:FindFirstChild("HumanoidRootPart")
        if thrp then hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 2.5) end
        equipWeapon()
        click()
        task.wait(delay)
    end
end

--// ================================================================
--//  FARM LOOPS
--// ================================================================
local farmLoopRunning = false
local function farmLoop()
    while S.FarmMode == "Level" or S.FarmMode == "Nearest" do
        task.wait(0.4)
        local _, hrp = charParts()
        if not hrp then continue end

        if S.FarmMode == "Nearest" then
            local near = getNearestEnemy()
            if near then kill(near, function() return S.FarmMode ~= "Nearest" end, false) end
        else
            local entry = pickQuest(getLevel())
            local questText = getQuestText()
            if not questText and entry then
                local npc = findNPC(entry.Giver)
                local cf  = npc and npc:GetPivot() or entry.GiverCF
                tweenTo(cf * CFrame.new(0, 0, 3), function() return S.FarmMode ~= "Level" end)
                task.wait(0.4)
                pcall(function() CommF:InvokeServer("StartQuest", entry.Quest, entry.Idx) end)
                task.wait(0.6)
            elseif questText then
                local targets = entry and getEnemies(entry.Mob) or {}
                if #targets == 0 then targets = getEnemies(nil) end
                table.sort(targets, function(a, b)
                    local ap, bp = a:FindFirstChild("HumanoidRootPart"), b:FindFirstChild("HumanoidRootPart")
                    if not ap or not bp then return false end
                    return (ap.Position - hrp.Position).Magnitude < (bp.Position - hrp.Position).Magnitude
                end)
                if targets[1] then kill(targets[1], function() return S.FarmMode ~= "Level" end, true) end
            else
                local near = getNearestEnemy()
                if near then kill(near, function() return S.FarmMode ~= "Level" end, false) end
            end
        end
    end
end

local function ensureFarmLoop()
    if farmLoopRunning then return end
    farmLoopRunning = true
    task.spawn(function() farmLoop() farmLoopRunning = false end)
end

local bossLoopRunning = false
local function bossLoop()
    while S.AutoBoss do
        task.wait(1)
        local boss = findNPC(S.SelectedBoss)
        if boss then
            notify("Ecl1psce", S.SelectedBoss .. " found!")
            kill(boss, function() return not S.AutoBoss end, false)
        end
    end
end

local function ensureBossLoop()
    if bossLoopRunning then return end
    bossLoopRunning = true
    task.spawn(function() bossLoop() bossLoopRunning = false end)
end

--// Background loops: stats / buso / anti-afk
task.spawn(function()
    while true do
        task.wait(3)
        if S.AutoStats then
            pcall(function()
                local pts = LocalPlayer.Data.Points.Value
                if pts and pts > 0 then
                    CommF:InvokeServer("AddPoint", S.Stat, pts)
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if S.AutoBuso then
            pcall(function() CommF:InvokeServer("Buso") end)
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(1, 1))
end)

--// ================================================================
--//  ESP / FRUIT FINDER
--// ================================================================
local espCache = {}
local function addESP(model, color)
    if not model or espCache[model] then return end
    if not model:FindFirstChildWhichIsA("BasePart") then return end
    local h = Instance.new("Highlight")
    h.FillTransparency = 0.7
    h.OutlineColor = color
    h.FillColor = color
    h.Parent = model
    espCache[model] = h
end

local function clearESP()
    for m, h in pairs(espCache) do
        if h then h:Destroy() end
        espCache[m] = nil
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        -- prune stale
        for m, h in pairs(espCache) do
            if not (m and m.Parent) then
                if h then h:Destroy() end
                espCache[m] = nil
            end
        end
        if S.ESPMobs then
            local f = workspace:FindFirstChild("Enemies")
            if f then for _, m in ipairs(f:GetChildren()) do addESP(m, Color3.fromRGB(255, 70, 70)) end end
        end
        if S.ESPPlayers then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then addESP(p.Character, Color3.fromRGB(80, 255, 140)) end
            end
        end
    end
end)

task.spawn(function()
    local known = {}
    while true do
        task.wait(3)
        if S.FruitESP or S.AutoFruitTP then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Tool") and v.Name:find("Fruit") and not known[v] then
                    known[v] = true
                    notify("Ecl1psce", "Fruit spawned: " .. v.Name)
                    if S.FruitESP then addESP(v.Parent or v, Color3.fromRGB(255, 220, 60)) end
                    if S.AutoFruitTP then
                        local h = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                        if h then
                            tweenTo(h.CFrame + Vector3.new(0, 3, 0), function() return not S.AutoFruitTP end)
                        end
                    end
                end
            end
        end
    end
end)

--// ================================================================
--//  MISC FEATURES
--// ================================================================
local setFly, setNoclip -- forward declarations

local flyBody, flyGyro, noclipConn

function setFly(on)
    local _, hrp = charParts()
    if not hrp then return end
    if on then
        flyBody = Instance.new("BodyVelocity")
        flyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBody.Velocity = Vector3.zero
        flyBody.Parent = hrp
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro.P = 9e4
        flyGyro.Parent = hrp
    else
        if flyBody then flyBody:Destroy() flyBody = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
    end
end

function setNoclip(on)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if c then for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end end
        end)
    end
end

UserInput.JumpRequest:Connect(function()
    if S.InfJump then
        local _, _, hum = charParts()
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local savedLighting = {}
local function setFPSBoost(on)
    if on then
        savedLighting.GlobalShadows = Lighting.GlobalShadows
        savedLighting.FogEnd = Lighting.FogEnd
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        end
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        notify("Ecl1psce", "FPS boost enabled")
    else
        Lighting.GlobalShadows = savedLighting.GlobalShadows or true
        Lighting.FogEnd = savedLighting.FogEnd or 500
    end
end

local function rejoin()
    TeleportSvc:Teleport(game.PlaceId, LocalPlayer)
end

local function serverHop()
    local ok, err = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        local choices = {}
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing and srv.playing > 0 and srv.playing < (srv.maxPlayers or 50) - 1 then
                table.insert(choices, srv)
            end
        end
        if #choices == 0 then notify("Ecl1psce", "No hop targets found") return end
        local pick = choices[math.random(1, #choices)]
        TeleportSvc:TeleportToPlaceInstance(game.PlaceId, pick.id, LocalPlayer)
    end)
    if not ok then notify("Server Hop failed", tostring(err)) end
end

local function applyCharSpeed()
    local _, _, hum = charParts()
    if hum then
        hum.WalkSpeed = S.WalkSpeed
        hum.JumpPower = S.JumpPower
        hum.UseJumpPower = true
    end
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(1) applyCharSpeed() end)

--// ================================================================
--//  GUI
--// ================================================================
local ACCENT = Color3.fromRGB(230, 180, 60)
local BTN    = Color3.fromRGB(35, 35, 45)
local BG     = Color3.fromRGB(12, 12, 18)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ecl1psce_AllInOne"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 270, 0, 430)
Main.Position = UDim2.new(0.5, -135, 0.5, -215)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--// Logo / branding
if getgenv().Ecl1psce.LogoAssetId and getgenv().Ecl1psce.LogoAssetId ~= 0 then
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(1, -20, 0, 52)
    logo.Position = UDim2.new(0, 10, 0, 8)
    logo.BackgroundTransparency = 1
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Image = "rbxassetid://" .. getgenv().Ecl1psce.LogoAssetId
    logo.Parent = Main
else
    local brand = Instance.new("TextLabel")
    brand.Size = UDim2.new(1, -20, 0, 36)
    brand.Position = UDim2.new(0, 10, 0, 12)
    brand.BackgroundTransparency = 1
    brand.Text = "E C L 1 P S C E"
    brand.TextColor3 = ACCENT
    brand.Font = Enum.Font.GothamBold
    brand.TextSize = 20
    brand.Parent = Main
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 16)
    sub.Position = UDim2.new(0, 10, 0, 44)
    sub.BackgroundTransparency = 1
    sub.Text = "S C R I P T S"
    sub.TextColor3 = Color3.fromRGB(140, 140, 150)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 10
    sub.Parent = Main
end

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -110)
Scroll.Position = UDim2.new(0, 8, 0, 64)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = ACCENT
Scroll.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layo
