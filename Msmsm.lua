local input = tostring(_G.ScriptKey or ""):lower() -- يحول المفتاح لحروف صغيرة للتأكد

-- التحقق: هل يبدأ بـ m وينتهي بـ s؟
if input:sub(1,1) ~= "m" or input:sub(-1) ~= "s" then
    game.Players.LocalPlayer:Kick("no key")
    return
end

-- كودك الـ 348 سطر يكمل هنا --
--[[ Msmsm Hub v8.0 – Part 1/4 ]]
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Speed = 60.5, ReturnSpeed = 30, DuelEnabled = false,
    AntiRagdollEnabled = false, SpinEnabled = false, SpinSpeed = 20,
    FloatEnabled = false, FloatPower = 12,
    AutoGrabEnabled = false, GrabRadius = 200, GrabDuration = 0.1,
    GalaxyEnabled = false, GalaxyGravity = 70,
    BatAimbotEnabled = false, BatSpeed = 59, BatRange = 20,
    InventJumpEnabled = false, InventJumpPower = 60,
    UnwalkEnabled = false, HitboxEnabled = false, HitboxRadius = 20,
    OptimizerEnabled = false, EspEnabled = false, FovEnabled = false, AntiFlingEnabled = false,
    BrainrotDefenseEnabled = false, BrainrotDefenseSide = "left", MedusaCounterEnabled = false
}

local GalaxyHopEnabled, GalaxyLastHop, SpaceHeld, OriginalJump = false, 0, false, 50
local DEFAULT_GRAVITY = 196.2

local CFG = "MsmsmHub_v8.json"
local function saveConfig()
    if not writefile then return end
    local d = {Config = Config}
    if FloatBtns then
        for k, v in pairs(FloatBtns) do
            if v.btn then d["fb_"..k] = {x = v.btn.Position.X.Offset, y = v.btn.Position.Y.Offset} end
        end
    end
    pcall(function() writefile(CFG, HttpService:JSONEncode(d)) end)
end

local function loadConfig()
    if not isfile or not readfile then return end
    pcall(function()
        if isfile(CFG) then
            local d = HttpService:JSONDecode(readfile(CFG))
            if d.Config then
                for k, v in pairs(d.Config) do
                    if Config[k] ~= nil then Config[k] = v end
                end
            end
        end
    end)
end
loadConfig()

local Screen = Instance.new("ScreenGui", gethui and gethui() or CoreGui)
Screen.Name = "MsmsmHub_v8"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

function notify(msg, dur)
    local g = Instance.new("ScreenGui", Screen)
    g.ResetOnSpawn = false
    local f = Instance.new("Frame", g)
    f.Size = UDim2.new(0, 220, 0, 40)
    f.Position = UDim2.new(0.5, -110, 0, -50)
    f.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local fs = Instance.new("UIStroke", f)
    fs.Color = Color3.fromRGB(136, 0, 255)
    fs.Thickness = 1.5
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = msg
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Center
    local tw = TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -110, 0, 10)})
    tw:Play()
    task.delay(dur or 2.5, function()
        local tw2 = TweenService:Create(f, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -110, 0, -50)})
        tw2:Play()
        task.wait(0.3)
        g:Destroy()
    end)
end

local BTL = false
local LK = Instance.new("TextButton", Screen)
LK.Size = UDim2.new(0, 60, 0, 32)
LK.Position = UDim2.new(0.5, -66, 0, 42)
LK.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LK.BorderSizePixel = 0
LK.Text = "🔒"
LK.TextColor3 = Color3.fromRGB(255, 255, 255)
LK.Font = Enum.Font.GothamBold
LK.TextSize = 14
LK.AutoButtonColor = false
LK.ZIndex = 200
Instance.new("UICorner", LK).CornerRadius = UDim.new(0, 8)
local lS = Instance.new("UIStroke", LK)
lS.Color = Color3.fromRGB(136, 0, 255)
lS.Thickness = 2
LK.MouseButton1Click:Connect(function()
    BTL = not BTL
    LK.Text = BTL and "🔐" or "🔒"
    lS.Color = BTL and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(136, 0, 255)
end)

local DPOS = {
    ["RIGHT\nPLAY"] = {90, 60},
    ["LEFT\nPLAY"] = {160, 60},
    ["BAT"] = {90, 130},
    ["DROP"] = {160, 130},
    ["FLOAT"] = {90, 200},
    ["DUEL\nSTOP"] = {160, 200},
    ["TP\nDOWN"] = {90, 270}
}

local function resetAllButtons()
    for n, p in pairs(DPOS) do
        if FloatBtns[n] then
            FloatBtns[n].btn.Position = UDim2.new(0, p[1], 0, p[2])
        end
    end
    notify("✅ Buttons Reset!", 2)
end

local RK = Instance.new("TextButton", Screen)
RK.Size = UDim2.new(0, 60, 0, 32)
RK.Position = UDim2.new(0.5, 6, 0, 42)
RK.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
RK.BorderSizePixel = 0
RK.Text = "🔄"
RK.TextColor3 = Color3.fromRGB(255, 255, 255)
RK.Font = Enum.Font.GothamBold
RK.TextSize = 14
RK.AutoButtonColor = false
RK.ZIndex = 200
Instance.new("UICorner", RK).CornerRadius = UDim.new(0, 8)
local rkStroke = Instance.new("UIStroke", RK)
rkStroke.Color = Color3.fromRGB(255, 100, 100)
rkStroke.Thickness = 2
RK.MouseButton1Click:Connect(resetAllButtons)

local SBD = nil
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    local hd = c:FindFirstChild("Head")
    if hd then
        if SBD and SBD.Parent then SBD:Destroy() end
        SBD = Instance.new("BillboardGui", hd)
        SBD.Size = UDim2.new(0, 100, 0, 18)
        SBD.StudsOffset = Vector3.new(0, 2.8, 0)
        SBD.AlwaysOnTop = true
        local lb = Instance.new("TextLabel", SBD)
        lb.Size = UDim2.new(1, 0, 1, 0)
        lb.BackgroundTransparency = 1
        lb.TextColor3 = Color3.fromRGB(255, 255, 255)
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = 13
        lb.TextStrokeTransparency = 0.4
    end
end)

RunService.RenderStepped:Connect(function()
    if SBD and SBD.Parent then
        local r = getHRP()
        if r then
            local sp = math.floor(Vector3.new(r.AssemblyLinearVelocity.X, 0, r.AssemblyLinearVelocity.Z).Magnitude + 0.5)
            local lb = SBD:FindFirstChildOfClass("TextLabel")
            if lb then lb.Text = sp end
        end
    end
end)

FloatBtns = {}

function createFloatBtn(name, posX, posY, callback)
    local btn = Instance.new("TextButton", Screen)
    btn.Size = UDim2.new(0, 64, 0, 64)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 20
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

    local stk = Instance.new("UIStroke", btn)
    stk.Color = Color3.fromRGB(136, 0, 255)
    stk.Thickness = 2
    stk.Transparency = 0.3

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 10
    lbl.TextWrapped = true

    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0.5, -4, 1, -12)
    dot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        stk.Color = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(136, 0, 255)
        stk.Transparency = state and 0 or 0.3
        dot.BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)

    local drag, ds, sp = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if BTL then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            ds = input.Position
            sp = btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and not BTL and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - ds
            btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    FloatBtns[name] = {
        btn = btn,
        setState = function(s)
            state = s
            stk.Color = s and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(136, 0, 255)
            stk.Transparency = s and 0 or 0.3
            dot.BackgroundColor3 = s and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)
        end
    }
    return btn
end

print("Part 1/4 Loaded ✅")
--[[ Msmsm Hub v8.0 – Part 2/4 ]]

-- ====================== ANTI RAGDOLL ======================
local ARC = nil
function startAntiRagdoll()
    if ARC then return end
    ARC = RunService.Heartbeat:Connect(function()
        if not Config.AntiRagdollEnabled then return end
        local c = getChar()
        if not c then return end
        local h = getHum()
        local r = getHRP()
        if h then
            local st = h:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                h:ChangeState(Enum.HumanoidStateType.Running)
                Camera.CameraSubject = h
                if r then
                    r.Velocity = Vector3.zero
                    r.RotVelocity = Vector3.zero
                end
            end
        end
        for _, o in ipairs(c:GetDescendants()) do
            if o:IsA("Motor6D") and not o.Enabled then o.Enabled = true end
        end
    end)
end
function stopAntiRagdoll()
    if ARC then ARC:Disconnect(); ARC = nil end
end

-- ====================== SPIN BOT ======================
local SB = nil
function startSpin()
    local r = getHRP()
    if not r then return end
    if SB then SB:Destroy() end
    SB = Instance.new("BodyAngularVelocity", r)
    SB.MaxTorque = Vector3.new(0, math.huge, 0)
    SB.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
end
function stopSpin()
    if SB then SB:Destroy(); SB = nil end
end

-- ====================== FLOAT ======================
local FC = nil
function startFloat()
    if FC then FC:Disconnect() end
    FC = RunService.Heartbeat:Connect(function()
        if not Config.FloatEnabled then return end
        local r = getHRP()
        if not r then return end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local c = getChar()
        if c then rp.FilterDescendantsInstances = {c} end
        local hit = workspace:Raycast(r.Position, Vector3.new(0, -200, 0), rp)
        if hit then
            local ty = hit.Position.Y + Config.FloatPower
            local diff = ty - r.Position.Y
            local vel = math.clamp(diff * 12, -40, 40)
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, vel, r.AssemblyLinearVelocity.Z)
        end
    end)
end
function stopFloat()
    if FC then FC:Disconnect(); FC = nil end
end

-- ====================== GALAXY ======================
local GV, GA = nil, nil
function setupGalaxy()
    local r = getHRP()
    if not r then return end
    if GV then GV:Destroy() end
    if GA then GA:Destroy() end
    GA = Instance.new("Attachment", r)
    GV = Instance.new("VectorForce", r)
    GV.Attachment0 = GA
    GV.RelativeTo = Enum.ActuatorRelativeTo.World
    GV.ApplyAtCenterOfMass = true
    GV.Force = Vector3.zero
end
function updateGalaxy()
    if not Config.GalaxyEnabled or not GV then return end
    local c = getChar()
    if not c then return end
    local m = 0
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then m = m + p:GetMass() end
    end
    local tg = DEFAULT_GRAVITY * (Config.GalaxyGravity / 100)
    GV.Force = Vector3.new(0, m * (DEFAULT_GRAVITY - tg) * 0.95, 0)
end
function galaxyHop()
    if tick() - GalaxyLastHop < 0.08 then return end
    GalaxyLastHop = tick()
    local r = getHRP()
    local h = getHum()
    if not r or not h then return end
    if h.FloorMaterial == Enum.Material.Air then
        r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 35, r.AssemblyLinearVelocity.Z)
    end
end
function startGalaxy()
    Config.GalaxyEnabled = true
    GalaxyHopEnabled = true
    setupGalaxy()
    local h = getHum()
    if h and h.JumpPower > 0 then OriginalJump = h.JumpPower end
    if h then
        local rt = math.sqrt((DEFAULT_GRAVITY * (Config.GalaxyGravity / 100)) / DEFAULT_GRAVITY)
        h.JumpPower = OriginalJump * rt
    end
end
function stopGalaxy()
    Config.GalaxyEnabled = false
    GalaxyHopEnabled = false
    if GV then GV:Destroy(); GV = nil end
    if GA then GA:Destroy(); GA = nil end
    local h = getHum()
    if h then h.JumpPower = OriginalJump end
end

-- ====================== AUTO DUEL (إحداثيات جديدة - أعمق داخل البيت) ======================
local DC, DP, DR, DRP = nil, 1, false, 1

local P1 = Vector3.new(-472.61, -6.81, 90.19)
local P2 = Vector3.new(-472.78, -6.81, 91.65)
local PE = Vector3.new(-488.50, -4.58, 95.27)

local R1 = Vector3.new(-473.05, -6.81, 30.29)
local R2 = Vector3.new(-473.19, -6.81, 28.32)
local RE = Vector3.new(-488.10, -4.63, 25.18)

function stopDuel()
    if DC then DC:Disconnect(); DC = nil end
    DP = 1; DR = false; DRP = 1; Config.DuelEnabled = false
    local r = getHRP()
    if r then r.AssemblyLinearVelocity = Vector3.zero end
end

function startDuelReturn(d)
    DR = true; DRP = 1
    if DC then DC:Disconnect() end
    local w = d == "right" and {P1, R1, R2} or {R1, P1, P2}
    DC = RunService.Heartbeat:Connect(function()
        if not Config.DuelEnabled then return end
        local r = getHRP()
        if not r then return end
        local t = w[DRP]
        if not t then stopDuel(); return end
        local flatTarget = Vector3.new(t.X, r.Position.Y, t.Z)
        local dir = (flatTarget - r.Position).Unit
        r.AssemblyLinearVelocity = Vector3.new(dir.X * Config.ReturnSpeed, r.AssemblyLinearVelocity.Y, dir.Z * Config.ReturnSpeed)
        if (flatTarget - r.Position).Magnitude < 2 then
            if DRP < #w then DRP = DRP + 1 else stopDuel() end
        end
    end)
end

function startDuelRight()
    stopDuel(); Config.DuelEnabled = true; DP = 1; DR = false
    local w = {P1, P2, PE}
    DC = RunService.Heartbeat:Connect(function()
        if not Config.DuelEnabled then return end
        local r = getHRP()
        if not r then return end
        local t = w[DP]
        if not t then startDuelReturn("right"); return end
        local flatTarget = Vector3.new(t.X, r.Position.Y, t.Z)
        local dir = (flatTarget - r.Position).Unit
        r.AssemblyLinearVelocity = Vector3.new(dir.X * Config.Speed, r.AssemblyLinearVelocity.Y, dir.Z * Config.Speed)
        if (flatTarget - r.Position).Magnitude < 2 then
            if DP < #w then DP = DP + 1 else startDuelReturn("right") end
        end
    end)
end

function startDuelLeft()
    stopDuel(); Config.DuelEnabled = true; DP = 1; DR = false
    local w = {R1, R2, RE}
    DC = RunService.Heartbeat:Connect(function()
        if not Config.DuelEnabled then return end
        local r = getHRP()
        if not r then return end
        local t = w[DP]
        if not t then startDuelReturn("left"); return end
        local flatTarget = Vector3.new(t.X, r.Position.Y, t.Z)
        local dir = (flatTarget - r.Position).Unit
        r.AssemblyLinearVelocity = Vector3.new(dir.X * Config.Speed, r.AssemblyLinearVelocity.Y, dir.Z * Config.Speed)
        if (flatTarget - r.Position).Magnitude < 2 then
            if DP < #w then DP = DP + 1 else startDuelReturn("left") end
        end
    end)
end

-- ====================== AUTO GRAB (fireproximityprompt + getconnections + بار يتحرك) ======================
local GrabConn, IsGrabbing, GrabData, AnimalCache = nil, false, {}, {}

local function IsMyPlot(name)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(name)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if not sign then return false end
    local yb = sign:FindFirstChild("YourBase")
    return yb and yb:IsA("BillboardGui") and yb.Enabled == true
end

local function ScanAnimals()
    local result = {}
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return result end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") and not IsMyPlot(plot.Name) then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    pcall(function()
                        local base = pod:FindFirstChild("Base")
                        local spawn = base and base:FindFirstChild("Spawn")
                        if spawn then
                            local att = spawn:FindFirstChild("PromptAttachment")
                            if att then
                                for _, ch in ipairs(att:GetChildren()) do
                                    if ch:IsA("ProximityPrompt") then
                                        table.insert(result, {p = ch, pos = spawn.Position})
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
    AnimalCache = result
end

local function GetNearestAnimal()
    local r = getHRP()
    if not r then return nil end
    local best, bd = nil, Config.GrabRadius
    for _, a in ipairs(AnimalCache) do
        local d = (a.pos - r.Position).Magnitude
        if d < bd then bd = d; best = a end
    end
    return best
end

local function BuildCallbacks(prompt)
    if GrabData[prompt] then return end
    local data = {h = {}, t = {}, rdy = true}
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                if c.Function then table.insert(data.h, c.Function) end
            end
            for _, c in ipairs(getconnections(prompt.Triggered)) do
                if c.Function then table.insert(data.t, c.Function) end
            end
        end
    end)
    if #data.h > 0 or #data.t > 0 then GrabData[prompt] = data end
end

local function ExecGrab(animal)
    if IsGrabbing then return end
    local p = animal.p
    if not p or not p.Parent then return end
    BuildCallbacks(p)
    local d = GrabData[p]
    if not d or not d.rdy then return end
    d.rdy = false; IsGrabbing = true

    -- أسرع طريقة: fireproximityprompt
    if fireproximityprompt then
        fireproximityprompt(p)
        -- حركة سريعة للبار
        if pbFill then pbFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0.1, true) end
        if pbLabel then pbLabel.Text = "GRABBED!" end
        task.wait(0.15)
        if pbFill then pbFill:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Linear", 0.1, true) end
        if pbLabel then pbLabel.Text = "READY" end
        d.rdy = true; IsGrabbing = false
        return
    end

    -- طريقة getconnections مع Progress Bar يتحرك
    local st = tick()
    if pbLabel then pbLabel.Text = "GRABBING..." end
    task.spawn(function()
        for _, f in ipairs(d.h) do task.spawn(f) end
        while tick() - st < Config.GrabDuration do
            local prog = math.clamp((tick() - st) / Config.GrabDuration, 0, 1)
            if pbFill then pbFill.Size = UDim2.new(prog, 0, 1, 0) end
            if pbLabel then pbLabel.Text = math.floor(prog * 100) .. "%" end
            task.wait()
        end
        for _, f in ipairs(d.t) do task.spawn(f) end
        if pbFill then pbFill.Size = UDim2.new(0, 0, 1, 0) end
        if pbLabel then pbLabel.Text = "READY" end
        d.rdy = true; IsGrabbing = false
    end)
end

function startGrab()
    if GrabConn then return end
    ScanAnimals()
    GrabConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoGrabEnabled or IsGrabbing then return end
        local a = GetNearestAnimal()
        if a then ExecGrab(a) end
    end)
    task.spawn(function()
        while Config.AutoGrabEnabled do
            task.wait(1.5)
            ScanAnimals()
        end
    end)
end

function stopGrab()
    if GrabConn then GrabConn:Disconnect(); GrabConn = nil end
    IsGrabbing = false
end

-- ====================== BAT AIMBOT ======================
local BCN, BAL, BATa = nil, nil, nil
local LE, LU = 0, 0
local function findBat()
    local c = getChar()
    if not c then return nil end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
        end
    end
    return nil
end
local function nearestEnemy()
    local r = getHRP()
    if not r then return nil, math.huge end
    local cl, md = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local er = p.Character:FindFirstChild("HumanoidRootPart")
            local eh = p.Character:FindFirstChildOfClass("Humanoid")
            if er and eh and eh.Health > 0 then
                local d = (er.Position - r.Position).Magnitude
                if d < md then md = d; cl = er end
            end
        end
    end
    return cl, md
end
function startBat()
    if BCN then return end
    local r = getHRP()
    local h = getHum()
    if not r or not h then return end
    h.AutoRotate = false
    if BATa then BATa:Destroy() end
    if BAL then BAL:Destroy() end
    BATa = Instance.new("Attachment", r)
    BAL = Instance.new("AlignOrientation", r)
    BAL.Attachment0 = BATa
    BAL.Mode = Enum.OrientationAlignmentMode.OneAttachment
    BAL.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    BAL.Responsiveness = 1000
    BAL.RigidityEnabled = true
    BCN = RunService.Heartbeat:Connect(function()
        if not Config.BatAimbotEnabled then return end
        local c = getChar()
        local mr = getHRP()
        local mh = getHum()
        if not c or not mr or not mh then return end
        mr.CanCollide = false
        local t, dist = nearestEnemy()
        if not t then return end
        mr.AssemblyLinearVelocity = (t.Position - mr.Position).Unit * Config.BatSpeed
        if dist <= Config.BatRange then
            if tick() - LE >= 0.3 then
                local b = findBat()
                if b and b.Parent ~= c then mh:EquipTool(b) end
                LE = tick()
            end
            if tick() - LU >= 0.3 then
                local b = findBat()
                if b then b:Activate() end
                LU = tick()
            end
        end
        if BAL then BAL.CFrame = CFrame.lookAt(mr.Position, Vector3.new(t.Position.X, mr.Position.Y, t.Position.Z)) end
    end)
end
function stopBat()
    if BCN then BCN:Disconnect(); BCN = nil end
    if BAL then BAL:Destroy(); BAL = nil end
    if BATa then BATa:Destroy(); BATa = nil end
    local h = getHum()
    if h then h.AutoRotate = true end
    local r = getHRP()
    if r then r.AssemblyLinearVelocity = Vector3.zero end
end

-- ====================== INVENT JUMP ======================
UserInputService.JumpRequest:Connect(function()
    if not Config.InventJumpEnabled then return end
    local r = getHRP()
    if r then r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, Config.InventJumpPower, r.AssemblyLinearVelocity.Z) end
end)

-- ====================== UNWALK ======================
local UWC, SAV = nil, nil
function startUnwalk()
    if UWC then return end
    local c = getChar()
    if c then
        local a = c:FindFirstChild("Animate")
        if a then SAV = a:Clone(); a:Destroy() end
    end
    UWC = RunService.Heartbeat:Connect(function()
        if not Config.UnwalkEnabled then return end
        local h = getHum()
        if not h then return end
        local an = h:FindFirstChildOfClass("Animator")
        if an then for _, t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop() end end
    end)
end
function stopUnwalk()
    if UWC then UWC:Disconnect(); UWC = nil end
    local c = getChar()
    if c and SAV then SAV:Clone().Parent = c; SAV = nil end
end

-- ====================== DROP ======================
local DA = false
function dropBrainrot()
    if DA then return end; DA = true
    local r = getHRP()
    if not r then return end
    r.AssemblyLinearVelocity = Vector3.new(0, 115, 0)
    task.wait(0.4)
    r.AssemblyLinearVelocity = Vector3.new(0, -575, 0)
    task.wait(1.5); DA = false
end

-- ====================== TP DOWN ======================
function tpDown()
    local c = getChar()
    local r = getHRP()
    local h = getHum()
    if not c or not r or not h then return end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {c}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local res = workspace:Raycast(r.Position, Vector3.new(0, -1000, 0), rp)
    if res then
        local ty = res.Position.Y + (h.HipHeight or 2) + r.Size.Y / 2 + 0.3
        r.CFrame = CFrame.new(r.Position.X, ty, r.Position.Z) * r.CFrame.Rotation
    end
end

-- ====================== HITBOX ======================
function expandPrompts()
    local p = workspace:FindFirstChild("Plots")
    if not p then return end
    for _, o in ipairs(p:GetDescendants()) do
        if o:IsA("ProximityPrompt") then
            pcall(function()
                o.MaxActivationDistance = Config.HitboxRadius
                o.RequiresLineOfSight = false
            end)
        end
    end
end
function restorePrompts()
    local p = workspace:FindFirstChild("Plots")
    if not p then return end
    for _, o in ipairs(p:GetDescendants()) do
        if o:IsA("ProximityPrompt") then
            pcall(function()
                o.MaxActivationDistance = 10
                o.RequiresLineOfSight = true
            end)
        end
    end
end

-- ====================== XRAY / OPTIMIZER ======================
local XC = {}
function enableOptimizer()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").FogEnd = 9e9
    end)
    pcall(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then o:Destroy()
                elseif o:IsA("BasePart") then o.CastShadow = false; o.Material = Enum.Material.Plastic end
            end)
        end
    end)
    pcall(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") and o.Anchored and (o.Name:lower():find("base") or (o.Parent and o.Parent.Name:lower():find("base"))) then
                XC[o] = o.LocalTransparencyModifier
                o.LocalTransparencyModifier = 0.88
            end
        end
    end)
end
function disableOptimizer()
    for p, v in pairs(XC) do if p then p.LocalTransparencyModifier = v end end
    XC = {}
end

-- ====================== ESP ======================
function createESP(pl)
    if pl == LocalPlayer then return end
    local c = pl.Character
    if not c or c:FindFirstChild("ESP_B") then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    local b = Instance.new("BoxHandleAdornment", c)
    b.Name = "ESP_B"; b.Adornee = hr
    b.Size = Vector3.new(4, 6, 2)
    b.Color3 = Color3.fromRGB(136, 0, 255)
    b.Transparency = 0.5; b.AlwaysOnTop = true
end
function removeESP(pl)
    local c = pl.Character
    if c then local b = c:FindFirstChild("ESP_B"); if b then b:Destroy() end end
end
function enableESP()
    Config.EspEnabled = true
    for _, pl in ipairs(Players:GetPlayers()) do createESP(pl) end
    Players.PlayerAdded:Connect(function(pl)
        pl.CharacterAdded:Connect(function()
            task.wait(0.3)
            if Config.EspEnabled then createESP(pl) end
        end)
    end)
end
function disableESP()
    Config.EspEnabled = false
    for _, pl in ipairs(Players:GetPlayers()) do removeESP(pl) end
end

-- ====================== FOV ======================
function setFOV(v)
    pcall(function() Camera.FieldOfView = v and 100 or 70 end)
end

-- ====================== ANTI FLING ======================
local AFC = nil
function startAntiFling()
    if AFC then AFC:Disconnect() end
    AFC = RunService.Stepped:Connect(function()
        if not Config.AntiFlingEnabled then return end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                for _, o in ipairs(pl.Character:GetDescendants()) do
                    if o:IsA("BasePart") then o.CanCollide = false end
                end
            end
        end
    end)
end
function stopAntiFling()
    if AFC then AFC:Disconnect(); AFC = nil end
end

-- ====================== BRAINROT DEFENSE ======================
local WasRagdolled, AlreadyTP = false, false
local DEFENSE_LEFT_FINAL = Vector3.new(-483.59, -5.04, 104.24)
local DEFENSE_RIGHT_FINAL = Vector3.new(-483.51, -5.10, 18.89)
local CHECKPOINT_A = Vector3.new(-472.60, -7.00, 57.52)
local CHECKPOINT_L = Vector3.new(-472.65, -7.00, 95.69)
local CHECKPOINT_R = Vector3.new(-471.76, -7.00, 26.22)

local function DoVortexTP()
    if AlreadyTP then return end
    AlreadyTP = true
    task.spawn(function()
        task.wait(0.15)
        local cc = getChar()
        if not cc then AlreadyTP = false; return end
        for _, v in ipairs(cc:GetDescendants()) do
            if v:IsA("BasePart") then
                v.AssemblyLinearVelocity = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end
        if Config.BrainrotDefenseSide == "left" then
            cc:PivotTo(CFrame.new(CHECKPOINT_A + Vector3.new(0, 3, 0)))
            task.wait(0.08)
            cc:PivotTo(CFrame.new(CHECKPOINT_L + Vector3.new(0, 3, 0)))
            task.wait(0.08)
            cc:PivotTo(CFrame.new(DEFENSE_LEFT_FINAL + Vector3.new(0, 3, 0)))
        else
            cc:PivotTo(CFrame.new(CHECKPOINT_A + Vector3.new(0, 3, 0)))
            task.wait(0.08)
            cc:PivotTo(CFrame.new(CHECKPOINT_R + Vector3.new(0, 3, 0)))
            task.wait(0.08)
            cc:PivotTo(CFrame.new(DEFENSE_RIGHT_FINAL + Vector3.new(0, 3, 0)))
        end
        task.wait(1.5)
        AlreadyTP = false
    end)
end

local function CheckRagdollState(c)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local state = hum:GetState()
    return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll
end

local BrainrotConn = nil
function startBrainrotDefense()
    if BrainrotConn then return end
    BrainrotConn = RunService.Heartbeat:Connect(function()
        if not Config.BrainrotDefenseEnabled then return end
        if Config.BatAimbotEnabled then return end
        if Config.DuelEnabled then return end
        local c = getChar()
        if not c then return end
        local ragNow = CheckRagdollState(c)
        if ragNow and not WasRagdolled then DoVortexTP() end
        WasRagdolled = ragNow
    end)
end
function stopBrainrotDefense()
    if BrainrotConn then BrainrotConn:Disconnect(); BrainrotConn = nil end
end
LocalPlayer.CharacterAdded:Connect(function()
    AlreadyTP = false; WasRagdolled = false
end)

-- ====================== MEDUSA COUNTER ======================
local MEDUSA_COOLDOWN = 25
local MedusaLastUsed = 0
local MedusaDebounce = false
local MedusaAnchorConns = {}

local function FindMedusaTool()
    local char = getChar()
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local tn = tool.Name:lower()
            if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local tn = tool.Name:lower()
                if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end
            end
        end
    end
    return nil
end

local function UseMedusaCounter()
    if MedusaDebounce then return end
    if tick() - MedusaLastUsed < MEDUSA_COOLDOWN then return end
    local char = getChar()
    if not char then return end
    MedusaDebounce = true
    local med = FindMedusaTool()
    if not med then MedusaDebounce = false; return end
    if med.Parent ~= char then
        local hum = getHum()
        if hum then hum:EquipTool(med) end
    end
    pcall(function() med:Activate() end)
    MedusaLastUsed = tick()
    MedusaDebounce = false
end

local function StopMedusaCounter()
    for _, c in pairs(MedusaAnchorConns) do
        pcall(function() c:Disconnect() end)
    end
    MedusaAnchorConns = {}
end

local function SetupMedusaCounter(char)
    StopMedusaCounter()
    if not char then return end
    local function onAnchorChanged(part)
        return part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if Config.MedusaCounterEnabled and part.Anchored and part.Transparency == 1 then
                UseMedusaCounter()
            end
        end)
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(MedusaAnchorConns, onAnchorChanged(part))
        end
    end
    table.insert(MedusaAnchorConns, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(MedusaAnchorConns, onAnchorChanged(part))
        end
    end))
end

-- ====================== HEARTBEAT ======================
RunService.Heartbeat:Connect(function()
    if Config.GalaxyEnabled and GalaxyHopEnabled and SpaceHeld then galaxyHop() end
    if Config.GalaxyEnabled then updateGalaxy() end
end)

-- ====================== RESPAWN HANDLER ======================
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(1)
    if Config.SpinEnabled then stopSpin(); startSpin() end
    if Config.AntiRagdollEnabled then stopAntiRagdoll(); startAntiRagdoll() end
    if Config.FloatEnabled then stopFloat(); startFloat() end
    if Config.GalaxyEnabled then stopGalaxy(); startGalaxy() end
    if Config.UnwalkEnabled then stopUnwalk(); startUnwalk() end
    if Config.DuelEnabled then stopDuel(); Config.DuelEnabled = false end
    if Config.BrainrotDefenseEnabled then startBrainrotDefense() end
    if Config.MedusaCounterEnabled then SetupMedusaCounter(c) end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h and h.JumpPower > 0 then OriginalJump = h.JumpPower end
end)

if LocalPlayer.Character then
    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h and h.JumpPower > 0 then OriginalJump = h.JumpPower end
end

-- ====================== INIT ======================
if Config.SpinEnabled then startSpin() end
if Config.AntiRagdollEnabled then startAntiRagdoll() end
if Config.FloatEnabled then startFloat() end
if Config.BrainrotDefenseEnabled then startBrainrotDefense() end
if Config.MedusaCounterEnabled and LocalPlayer.Character then SetupMedusaCounter(LocalPlayer.Character) end

print("Part 2/4 Loaded ✅")
--[[ Msmsm Hub v8.0 – Part 3/4 ]]

local MM = Instance.new("Frame", Screen)
MM.Size = UDim2.new(0, 230, 0, 370)
MM.Position = UDim2.new(0.5, -115, 0.5, -185)
MM.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MM.BorderSizePixel = 0
MM.Visible = false
MM.ZIndex = 30
Instance.new("UICorner", MM).CornerRadius = UDim.new(0, 14)
local mmStroke = Instance.new("UIStroke", MM)
mmStroke.Color = Color3.fromRGB(136, 0, 255)
mmStroke.Thickness = 2

local mT = Instance.new("TextLabel", MM)
mT.Size = UDim2.new(1, 0, 0, 30)
mT.BackgroundTransparency = 1
mT.Text = "Msmsm Hub v8.0"
mT.TextColor3 = Color3.fromRGB(255, 255, 255)
mT.Font = Enum.Font.GothamBlack
mT.TextSize = 14
mT.TextXAlignment = Enum.TextXAlignment.Center
mT.Position = UDim2.new(0, 0, 0, 6)

local mC = Instance.new("TextButton", MM)
mC.Size = UDim2.new(0, 26, 0, 26)
mC.Position = UDim2.new(1, -32, 0, 6)
mC.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mC.BorderSizePixel = 0
mC.Text = "X"
mC.TextColor3 = Color3.fromRGB(255, 255, 255)
mC.Font = Enum.Font.GothamBold
mC.TextSize = 12
Instance.new("UICorner", mC).CornerRadius = UDim.new(0, 6)
mC.MouseButton1Click:Connect(function() MM.Visible = false end)

local mDr = false
local mDS, mSP
MM.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDr = true
        mDS = i.Position
        mSP = MM.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if mDr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - mDS
        MM.Position = UDim2.new(mSP.X.Scale, mSP.X.Offset + d.X, mSP.Y.Scale, mSP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mDr = false end
end)

local TB = {}
local TC = {}
local TN = {"Settings", "Combat", "Control", "Visual"}

local TBa = Instance.new("Frame", MM)
TBa.Size = UDim2.new(1, 0, 0, 26)
TBa.Position = UDim2.new(0, 0, 0, 36)
TBa.BackgroundTransparency = 1
TBa.ZIndex = 31

for i, n in ipairs(TN) do
    local t = Instance.new("TextButton", TBa)
    t.Size = UDim2.new(0.25, -4, 1, 0)
    t.Position = UDim2.new((i - 1) * 0.25, 2, 0, 0)
    t.BackgroundColor3 = i == 1 and Color3.fromRGB(136, 0, 255) or Color3.fromRGB(25, 25, 25)
    t.BorderSizePixel = 0
    t.Text = n
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 9
    t.AutoButtonColor = false
    t.ZIndex = 32
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)

    local c = Instance.new("ScrollingFrame", MM)
    c.Size = UDim2.new(1, -8, 1, -68)
    c.Position = UDim2.new(0, 4, 0, 64)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = Color3.fromRGB(136, 0, 255)
    c.Visible = (i == 1)
    c.ZIndex = 31
    c.CanvasSize = UDim2.new(0, 0, 0, 800)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 5)

    TB[i] = t
    TC[i] = c

    t.MouseButton1Click:Connect(function()
        for j, tb in ipairs(TB) do
            tb.BackgroundColor3 = j == i and Color3.fromRGB(136, 0, 255) or Color3.fromRGB(25, 25, 25)
        end
        for j, cc in ipairs(TC) do
            cc.Visible = (j == i)
        end
    end)
end

local function CSL(p, n, min, max, def, cb)
    local ct = Instance.new("Frame", p)
    ct.Size = UDim2.new(1, 0, 0, 42)
    ct.BackgroundTransparency = 1
    ct.ZIndex = 32

    local lb = Instance.new("TextLabel", ct)
    lb.Size = UDim2.new(1, -50, 0, 14)
    lb.BackgroundTransparency = 1
    lb.Text = n
    lb.TextColor3 = Color3.fromRGB(200, 200, 200)
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 10
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 33

    local bx = Instance.new("TextBox", ct)
    bx.Size = UDim2.new(0, 42, 0, 16)
    bx.Position = UDim2.new(1, -42, 0, 0)
    bx.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bx.BorderSizePixel = 0
    bx.Text = tostring(def)
    bx.TextColor3 = Color3.fromRGB(255, 255, 255)
    bx.Font = Enum.Font.GothamBold
    bx.TextSize = 9
    bx.TextXAlignment = Enum.TextXAlignment.Center
    bx.ClearTextOnFocus = false
    bx.ZIndex = 33
    Instance.new("UICorner", bx).CornerRadius = UDim.new(0, 4)

    local bg = Instance.new("Frame", ct)
    bg.Size = UDim2.new(1, 0, 0, 6)
    bg.Position = UDim2.new(0, 0, 0, 22)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.BorderSizePixel = 0
    bg.ZIndex = 33
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fl = Instance.new("Frame", bg)
    fl.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fl.BackgroundColor3 = Color3.fromRGB(136, 0, 255)
    fl.BorderSizePixel = 0
    fl.ZIndex = 34
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

    local sb = Instance.new("TextButton", bg)
    sb.Size = UDim2.new(1, 0, 2, 0)
    sb.BackgroundTransparency = 1
    sb.Text = ""
    sb.ZIndex = 35

    local function up(v)
        local c = math.clamp(math.floor(v), min, max)
        fl.Size = UDim2.new((c - min) / (max - min), 0, 1, 0)
        bx.Text = tostring(c)
        cb(c)
    end

    bx.FocusLost:Connect(function()
        local n = tonumber(bx.Text)
        if n then up(n) else bx.Text = tostring(def) end
    end)

    local sd = false
    sb.MouseButton1Down:Connect(function() sd = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sd = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sd and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            up(min + (max - min) * pct)
        end
    end)
end

MenuToggles = {}

local function CMT(p, n, def, cb)
    local ct = Instance.new("Frame", p)
    ct.Size = UDim2.new(1, 0, 0, 30)
    ct.BackgroundTransparency = 1
    ct.ZIndex = 32

    local lb = Instance.new("TextLabel", ct)
    lb.Size = UDim2.new(1, -48, 1, 0)
    lb.Position = UDim2.new(0, 6, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = n
    lb.TextColor3 = Color3.fromRGB(255, 255, 255)
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 11
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 33

    local tk = Instance.new("Frame", ct)
    tk.Size = UDim2.new(0, 36, 0, 16)
    tk.Position = UDim2.new(1, -42, 0.5, -8)
    tk.BackgroundColor3 = def and Color3.fromRGB(136, 0, 255) or Color3.fromRGB(40, 40, 48)
    tk.BorderSizePixel = 0
    tk.ZIndex = 33
    Instance.new("UICorner", tk).CornerRadius = UDim.new(1, 0)

    local dt = Instance.new("Frame", tk)
    dt.Size = UDim2.new(0, 12, 0, 12)
    dt.Position = def and UDim2.new(1, -13, 0.1, 0) or UDim2.new(0, 2, 0.1, 0)
    dt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dt.BorderSizePixel = 0
    dt.ZIndex = 34
    Instance.new("UICorner", dt).CornerRadius = UDim.new(1, 0)

    local st = def
    local b = Instance.new("TextButton", ct)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.ZIndex = 35

    b.MouseButton1Click:Connect(function()
        st = not st
        tk.BackgroundColor3 = st and Color3.fromRGB(136, 0, 255) or Color3.fromRGB(40, 40, 48)
        dt.Position = st and UDim2.new(1, -13, 0.1, 0) or UDim2.new(0, 2, 0.1, 0)
        cb(st)
    end)

    local mt = {
        setState = function(s)
            st = s
            tk.BackgroundColor3 = s and Color3.fromRGB(136, 0, 255) or Color3.fromRGB(40, 40, 48)
            dt.Position = s and UDim2.new(1, -13, 0.1, 0) or UDim2.new(0, 2, 0.1, 0)
        end
    }
    MenuToggles[n] = mt
    return mt
end

-- ====================== TAB 1: SETTINGS ======================
CSL(TC[1], "Speed", 10, 200, Config.Speed, function(v) Config.Speed = v end)
CSL(TC[1], "Return", 10, 100, Config.ReturnSpeed, function(v) Config.ReturnSpeed = v end)
CSL(TC[1], "Spin Spd", 10, 500, Config.SpinSpeed, function(v)
    Config.SpinSpeed = v
    if SB then SB.AngularVelocity = Vector3.new(0, v, 0) end
end)
CSL(TC[1], "Float Pwr", 5, 50, Config.FloatPower, function(v) Config.FloatPower = v end)
CSL(TC[1], "Gravity %", 10, 95, Config.GalaxyGravity, function(v)
    Config.GalaxyGravity = v
    if Config.GalaxyEnabled then stopGalaxy(); startGalaxy() end
end)
CSL(TC[1], "Jump Pwr", 10, 200, Config.InventJumpPower, function(v) Config.InventJumpPower = v end)
CSL(TC[1], "Grab Rad", 5, 200, Config.GrabRadius, function(v) Config.GrabRadius = v end)
CSL(TC[1], "Grab Dur", 0.01, 1, Config.GrabDuration, function(v) Config.GrabDuration = v end)
CSL(TC[1], "Bat Spd", 10, 200, Config.BatSpeed, function(v) Config.BatSpeed = v end)

local svB = Instance.new("TextButton", TC[1])
svB.Size = UDim2.new(1, 0, 0, 36)
svB.BackgroundColor3 = Color3.fromRGB(136, 0, 255)
svB.BorderSizePixel = 0
svB.Text = "SAVE"
svB.TextColor3 = Color3.fromRGB(255, 255, 255)
svB.Font = Enum.Font.GothamBlack
svB.TextSize = 16
svB.ZIndex = 32
Instance.new("UICorner", svB).CornerRadius = UDim.new(0, 8)
svB.MouseButton1Click:Connect(function()
    saveConfig()
    svB.Text = "✅ SAVED!"
    task.delay(1.5, function() svB.Text = "SAVE" end)
end)

-- ====================== TAB 2: COMBAT ======================
CMT(TC[2], "RIGHT PLAY", false, function(s)
    Config.DuelEnabled = s
    if s then startDuelRight() else stopDuel() end
    if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(s) end
end)
CMT(TC[2], "LEFT PLAY", false, function(s)
    Config.DuelEnabled = s
    if s then startDuelLeft() else stopDuel() end
    if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(s) end
end)
CMT(TC[2], "GRAB", false, function(s)
    Config.AutoGrabEnabled = s
    if s then startGrab() else stopGrab() end
end)
CMT(TC[2], "BAT", false, function(s)
    Config.BatAimbotEnabled = s
    if s then startBat() else stopBat() end
    if FloatBtns["BAT"] then FloatBtns["BAT"].setState(s) end
end)
CMT(TC[2], "DROP", false, function(s)
    if s then task.spawn(dropBrainrot) end
end)
CMT(TC[2], "DUEL STOP", false, function(s)
    Config.DuelEnabled = false
    stopDuel()
    if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
    if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
end)
CMT(TC[2], "SPIN", false, function(s)
    Config.SpinEnabled = s
    if s then startSpin() else stopSpin() end
end)
CMT(TC[2], "INVENT JUMP", false, function(s)
    Config.InventJumpEnabled = s
end)
CMT(TC[2], "TP DOWN", false, function(s)
    if s then tpDown() end
end)
CMT(TC[2], "UNWALK", false, function(s)
    Config.UnwalkEnabled = s
    if s then startUnwalk() else stopUnwalk() end
end)

-- ====================== TAB 3: CONTROL ======================
CMT(TC[3], "Galaxy", false, function(s)
    Config.GalaxyEnabled = s
    if s then startGalaxy() else stopGalaxy() end
end)
CMT(TC[3], "Xray", false, function(s)
    Config.OptimizerEnabled = s
    if s then enableOptimizer() else disableOptimizer() end
end)
CMT(TC[3], "Anti Fling", false, function(s)
    Config.AntiFlingEnabled = s
    if s then startAntiFling() else stopAntiFling() end
end)
CMT(TC[3], "Brainrot Def", false, function(s)
    Config.BrainrotDefenseEnabled = s
    if s then startBrainrotDefense() else stopBrainrotDefense() end
end)

-- Defense Side Selector
do
    local ct = Instance.new("Frame", TC[3])
    ct.Size = UDim2.new(1, 0, 0, 30)
    ct.BackgroundTransparency = 1
    ct.ZIndex = 32
    local lb = Instance.new("TextLabel", ct)
    lb.Size = UDim2.new(0, 80, 1, 0)
    lb.Position = UDim2.new(0, 6, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = "Defense Side"
    lb.TextColor3 = Color3.fromRGB(255, 255, 255)
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 11
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 33
    local sideBtn = Instance.new("TextButton", ct)
    sideBtn.Size = UDim2.new(0, 42, 0, 18)
    sideBtn.Position = UDim2.new(1, -48, 0.5, -9)
    sideBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 60)
    sideBtn.BorderSizePixel = 0
    sideBtn.Text = Config.BrainrotDefenseSide == "left" and "LEFT" or "RIGHT"
    sideBtn.TextColor3 = Color3.fromRGB(200, 140, 255)
    sideBtn.Font = Enum.Font.GothamBold
    sideBtn.TextSize = 8
    sideBtn.ZIndex = 33
    Instance.new("UICorner", sideBtn).CornerRadius = UDim.new(0, 4)
    local sideStroke = Instance.new("UIStroke", sideBtn)
    sideStroke.Color = Color3.fromRGB(136, 0, 255)
    sideBtn.MouseButton1Click:Connect(function()
        Config.BrainrotDefenseSide = Config.BrainrotDefenseSide == "left" and "right" or "left"
        sideBtn.Text = Config.BrainrotDefenseSide == "left" and "LEFT" or "RIGHT"
        saveConfig()
    end)
end

CMT(TC[3], "Medusa Counter", false, function(s)
    Config.MedusaCounterEnabled = s
    if s and LocalPlayer.Character then
        SetupMedusaCounter(LocalPlayer.Character)
    else
        StopMedusaCounter()
    end
end)

-- ====================== TAB 4: VISUAL ======================
CMT(TC[4], "Hitbox Exp", false, function(s)
    Config.HitboxEnabled = s
    if s then expandPrompts() else restorePrompts() end
end)
CMT(TC[4], "FOV", false, function(s)
    Config.FovEnabled = s
    setFOV(s)
end)
CMT(TC[4], "ESP", false, function(s)
    if s then enableESP() else disableESP() end
end)

-- ====================== FLOATING BUTTONS ======================
createFloatBtn("LEFT\nPLAY", 90, 60, function(s)
    Config.DuelEnabled = s
    if s then startDuelRight() else stopDuel() end
    if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(s) end
end)

createFloatBtn("RIGHT\nPLAY", 160, 60, function(s)
    Config.DuelEnabled = s
    if s then startDuelLeft() else stopDuel() end
    if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(s) end
end)

createFloatBtn("BAT", 90, 130, function(s)
    Config.BatAimbotEnabled = s
    if s then startBat() else stopBat() end
    if MenuToggles["BAT"] then MenuToggles["BAT"].setState(s) end
end)

createFloatBtn("DROP", 160, 130, function(s)
    if s then task.spawn(dropBrainrot) end
end)

createFloatBtn("FLOAT", 90, 200, function(s)
    Config.FloatEnabled = s
    if s then startFloat() else stopFloat() end
end)

createFloatBtn("DUEL\nSTOP", 160, 200, function(s)
    Config.DuelEnabled = false
    stopDuel()
    if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
    if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
    if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(false) end
    if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(false) end
end)

createFloatBtn("TP\nDOWN", 90, 270, function(s)
    if s then tpDown() end
end)

-- ====================== MENU BUTTON ======================
local MB = Instance.new("TextButton", Screen)
MB.Size = UDim2.new(0, 44, 0, 44)
MB.Position = UDim2.new(0.5, -22, 0, 80)
MB.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MB.BorderSizePixel = 0
MB.Text = "M"
MB.TextColor3 = Color3.fromRGB(136, 0, 255)
MB.Font = Enum.Font.GothamBlack
MB.TextSize = 18
MB.ZIndex = 100
Instance.new("UICorner", MB).CornerRadius = UDim.new(0, 12)
local mbStroke = Instance.new("UIStroke", MB)
mbStroke.Color = Color3.fromRGB(136, 0, 255)
mbStroke.Thickness = 2
MB.MouseButton1Click:Connect(function() MM.Visible = not MM.Visible end)

-- ====================== LOAD FLOAT BUTTON POSITIONS ======================
if isfile and isfile(CFG) then
    pcall(function()
        local d = HttpService:JSONDecode(readfile(CFG))
        for k, v in pairs(d) do
            if k:match("^fb_") and FloatBtns then
                local name = k:gsub("fb_", "")
                if FloatBtns[name] and FloatBtns[name].btn then
                    FloatBtns[name].btn.Position = UDim2.new(0, v.x, 0, v.y)
                end
            end
        end
    end)
end

print("Part 3/4 Loaded ✅")
--[[ Msmsm Hub v8.0 – Part 4/4 ]]

local ProgBar = Instance.new("Frame", Screen)
ProgBar.Size = UDim2.new(0, 230, 0, 36)
ProgBar.Position = UDim2.new(0.5, -115, 1, -55)
ProgBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ProgBar.BorderSizePixel = 0
ProgBar.ZIndex = 50
Instance.new("UICorner", ProgBar).CornerRadius = UDim.new(0, 10)
local progStroke = Instance.new("UIStroke", ProgBar)
progStroke.Color = Color3.fromRGB(136, 0, 255)
progStroke.Thickness = 1.5

pbFill = Instance.new("Frame", ProgBar)
pbFill.Size = UDim2.new(0, 0, 1, 0)
pbFill.BackgroundColor3 = Color3.fromRGB(136, 0, 255)
pbFill.BorderSizePixel = 0
Instance.new("UICorner", pbFill).CornerRadius = UDim.new(0, 10)

pbLabel = Instance.new("TextLabel", ProgBar)
pbLabel.Size = UDim2.new(1, 0, 1, 0)
pbLabel.BackgroundTransparency = 1
pbLabel.Text = "READY"
pbLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pbLabel.Font = Enum.Font.GothamBold
pbLabel.TextSize = 12
pbLabel.ZIndex = 51

local pbDr = false
local pbDS, pbSP
ProgBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        pbDr = true
        pbDS = i.Position
        pbSP = ProgBar.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if pbDr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - pbDS
        ProgBar.Position = UDim2.new(pbSP.X.Scale, pbSP.X.Offset + d.X, pbSP.Y.Scale, pbSP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pbDr = false end
end)

-- ====================== KEYBINDS ======================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.RightControl then
        MM.Visible = not MM.Visible
        return
    end

    if input.KeyCode == Enum.KeyCode.R then
        Config.DuelEnabled = not Config.DuelEnabled
        if Config.DuelEnabled then
            startDuelRight()
            if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
        else
            stopDuel()
        end
        if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(Config.DuelEnabled) end
        if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(Config.DuelEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.L then
        Config.DuelEnabled = not Config.DuelEnabled
        if Config.DuelEnabled then
            startDuelLeft()
            if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
        else
            stopDuel()
        end
        if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(Config.DuelEnabled) end
        if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(Config.DuelEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.T then
        Config.DuelEnabled = false
        stopDuel()
        if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
        if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
        if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(false) end
        if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(false) end
        return
    end

    if input.KeyCode == Enum.KeyCode.G then
        Config.AutoGrabEnabled = not Config.AutoGrabEnabled
        if Config.AutoGrabEnabled then startGrab() else stopGrab() end
        if MenuToggles["GRAB"] then MenuToggles["GRAB"].setState(Config.AutoGrabEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.B then
        Config.BatAimbotEnabled = not Config.BatAimbotEnabled
        if Config.BatAimbotEnabled then startBat() else stopBat() end
        if FloatBtns["BAT"] then FloatBtns["BAT"].setState(Config.BatAimbotEnabled) end
        if MenuToggles["BAT"] then MenuToggles["BAT"].setState(Config.BatAimbotEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.P then
        task.spawn(dropBrainrot)
        return
    end

    if input.KeyCode == Enum.KeyCode.F then
        Config.FloatEnabled = not Config.FloatEnabled
        if Config.FloatEnabled then startFloat() else stopFloat() end
        if FloatBtns["FLOAT"] then FloatBtns["FLOAT"].setState(Config.FloatEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.V then
        Config.SpinEnabled = not Config.SpinEnabled
        if Config.SpinEnabled then startSpin() else stopSpin() end
        if MenuToggles["SPIN"] then MenuToggles["SPIN"].setState(Config.SpinEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.J then
        Config.InventJumpEnabled = not Config.InventJumpEnabled
        if MenuToggles["INVENT JUMP"] then MenuToggles["INVENT JUMP"].setState(Config.InventJumpEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.U then
        tpDown()
        return
    end

    if input.KeyCode == Enum.KeyCode.N then
        Config.UnwalkEnabled = not Config.UnwalkEnabled
        if Config.UnwalkEnabled then startUnwalk() else stopUnwalk() end
        if MenuToggles["UNWALK"] then MenuToggles["UNWALK"].setState(Config.UnwalkEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.Y then
        Config.GalaxyEnabled = not Config.GalaxyEnabled
        if Config.GalaxyEnabled then startGalaxy() else stopGalaxy() end
        if MenuToggles["Galaxy"] then MenuToggles["Galaxy"].setState(Config.GalaxyEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.X then
        Config.OptimizerEnabled = not Config.OptimizerEnabled
        if Config.OptimizerEnabled then enableOptimizer() else disableOptimizer() end
        if MenuToggles["Xray"] then MenuToggles["Xray"].setState(Config.OptimizerEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.M then
        Config.AntiFlingEnabled = not Config.AntiFlingEnabled
        if Config.AntiFlingEnabled then startAntiFling() else stopAntiFling() end
        if MenuToggles["Anti Fling"] then MenuToggles["Anti Fling"].setState(Config.AntiFlingEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.Z then
        Config.HitboxEnabled = not Config.HitboxEnabled
        if Config.HitboxEnabled then expandPrompts() else restorePrompts() end
        if MenuToggles["Hitbox Exp"] then MenuToggles["Hitbox Exp"].setState(Config.HitboxEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.O then
        Config.FovEnabled = not Config.FovEnabled
        setFOV(Config.FovEnabled)
        if MenuToggles["FOV"] then MenuToggles["FOV"].setState(Config.FovEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.K then
        if Config.EspEnabled then disableESP() else enableESP() end
        if MenuToggles["ESP"] then MenuToggles["ESP"].setState(Config.EspEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.H then
        Config.BrainrotDefenseEnabled = not Config.BrainrotDefenseEnabled
        if Config.BrainrotDefenseEnabled then startBrainrotDefense() else stopBrainrotDefense() end
        if MenuToggles["Brainrot Def"] then MenuToggles["Brainrot Def"].setState(Config.BrainrotDefenseEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.Semicolon then
        Config.MedusaCounterEnabled = not Config.MedusaCounterEnabled
        if Config.MedusaCounterEnabled and LocalPlayer.Character then
            SetupMedusaCounter(LocalPlayer.Character)
        else
            StopMedusaCounter()
        end
        if MenuToggles["Medusa Counter"] then MenuToggles["Medusa Counter"].setState(Config.MedusaCounterEnabled) end
        return
    end

    if input.KeyCode == Enum.KeyCode.Space then
        SpaceHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then SpaceHeld = false end
end)

-- ====================== CLEANUP ======================
LocalPlayer.OnTeleport:Connect(function()
    saveConfig()
end)

Screen.Destroying:Connect(function()
    stopDuel()
    stopSpin()
    stopFloat()
    stopGalaxy()
    stopAntiRagdoll()
    stopUnwalk()
    stopGrab()
    stopBat()
    stopAntiFling()
    stopBrainrotDefense()
    StopMedusaCounter()
    saveConfig()
end)

-- ====================== WELCOME ======================
notify("🌟 Msmsm Hub v8.0 Ready! 🌟", 3)

print(string.rep("=", 55))
print("  Msmsm Hub v8.0 - Blood Hub Duel Style")
print("  ✅ Auto Duel: Return System (إحداثيات جديدة)")
print("  ✅ Auto Grab: fireproximityprompt + getconnections + بار يتحرك")
print(string.rep("=", 55))
print("  KEYBINDS:")
print("  RCTRL=Menu  R=Right  L=Left  T=Stop")
print("  G=Grab  B=Bat  P=Drop  F=Float  V=Spin")
print("  J=Jump  U=TP    N=Unwalk  Y=Galaxy")
print("  X=Xray  M=AntiFling  Z=Hitbox  O=FOV")
print("  K=ESP   H=Brainrot  ;=Medusa")
print(string.rep("=", 55))

-- ============================================================
-- END OF MSMSM HUB v8.0
-- ============================================================
