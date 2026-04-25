-- نظام المفتاح لـ MSMSM HUB
local correctKey = "msmsms" -- المفتاح يبدأ بـ m وينتهي بـ s

if _G.ScriptKey ~= correctKey then
    -- إذا كان المفتاح خطأ، تظهر رسالة طرد (Kick) للمستخدم
    game.Players.LocalPlayer:Kick("خطأ في المفتاح! المفتاح الصحيح يبدأ بـ m وينتهي بـ s")
    return
end
print("with Msmsm Hub...")

----[[ Msmsm Hub v7.0 - Final God Mode ]]
repeat task.wait() until game:IsLoaded()

-- Anti-Kick Delay
pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(false) end)
task.wait(0.3)
pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(true) end)
task.wait(4)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Anti-Cheat
getgenv().AC_BYPASS = true
pcall(function()
    if hookfunction and debug and debug.info then
        local oldInfo = debug.info
        hookfunction(oldInfo, function(...)
            local ok, src = pcall(function() return oldInfo(1, "s") end)
            if ok and type(src) == "string" and (src:find("Synchronizer") or src:find("Packages.Net")) then return nil end
            return oldInfo(...)
        end)
    end
end)
pcall(function()
    if hookmetamethod and newcclosure then
        local oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local rem = tostring(self)
            if (method == "InvokeServer" or method == "FireServer") and (rem:find("Kick") or rem:find("Ban") or rem:find("AntiCheat")) then return nil end
            return oldNC(self, ...)
        end))
    end
end)

-- Config
local Config = {
    Speed = 59, ReturnSpeed = 29, DuelEnabled = false,
    AntiRagdollEnabled = false, SpinEnabled = false, SpinSpeed = 100,
    FloatEnabled = false, FloatPower = 12,
    AutoGrabEnabled = false, GrabRadius = 20, GrabDuration = 0.12,
    GalaxyEnabled = false, GalaxyGravity = 70,
    BatAimbotEnabled = false, BatSpeed = 56.5, BatRange = 20,
    InventJumpEnabled = false, InventJumpPower = 70,
    UnwalkEnabled = false, HitboxEnabled = false, HitboxRadius = 20,
    OptimizerEnabled = false, EspEnabled = false, FovEnabled = false, AntiFlingEnabled = false,
}
local GalaxyHopEnabled = false
local GalaxyLastHop = 0
local SpaceHeld = false
local OriginalJump = 50
local DEFAULT_GRAVITY = 196.2

-- Save/Load
local CFG = "MsmsmHub_v7.json"
local function saveConfig()
    if not writefile then return end
    local data = {Config = Config}
    if FloatBtns then for k, v in pairs(FloatBtns) do if v.btn then data["fb_"..k] = {x = v.btn.Position.X.Offset, y = v.btn.Position.Y.Offset} end end end
    pcall(function() writefile(CFG, HttpService:JSONEncode(data)) end)
end
local function loadConfig()
    if not isfile or not readfile then return end
    pcall(function()
        if isfile(CFG) then
            local d = HttpService:JSONDecode(readfile(CFG))
            if d.Config then for k, v in pairs(d.Config) do if Config[k] ~= nil then Config[k] = v end end end
            if d.fb_positions then _savedPos = d.fb_positions end
        end
    end)
end
local _savedPos = {}
loadConfig()

-- ScreenGui
local Screen = Instance.new("ScreenGui", gethui and gethui() or CoreGui)
Screen.Name = "MsmsmHub_v7"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Helpers
local function getChar() return LocalPlayer.Character end
local function getHRP() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- Notification
local function notify(msg, dur)
    local g = Instance.new("ScreenGui", Screen); g.ResetOnSpawn = false
    local f = Instance.new("Frame", g); f.Size = UDim2.new(0, 220, 0, 40); f.Position = UDim2.new(0.5, -110, 0, -50); f.BackgroundColor3 = Color3.fromRGB(10,10,10); f.BorderSizePixel = 0; Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(136,0,255); Instance.new("UIStroke", f).Thickness = 1.5
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = msg; t.TextColor3 = Color3.fromRGB(255,255,255); t.Font = Enum.Font.GothamBold; t.TextSize = 13; t.TextXAlignment = Enum.TextXAlignment.Center
    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -110, 0, 10)}):Play()
    task.delay(dur or 2.5, function() TweenService:Create(f, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -110, 0, -50)}):Play(); task.wait(0.3); g:Destroy() end)
end

-- Anti Ragdoll
local AntiRagdollConn = nil
local function startAntiRagdoll()
    if AntiRagdollConn then return end
    AntiRagdollConn = RunService.Heartbeat:Connect(function()
        if not Config.AntiRagdollEnabled then return end
        local char = getChar(); if not char then return end
        local hum = getHum(); local root = getHRP()
        if hum then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running); Camera.CameraSubject = hum
                if root then root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end
            end
        end
        for _, o in ipairs(char:GetDescendants()) do if o:IsA("Motor6D") and not o.Enabled then o.Enabled = true end end
    end)
end
local function stopAntiRagdoll() if AntiRagdollConn then AntiRagdollConn:Disconnect(); AntiRagdollConn = nil end end

-- Spin
local SpinBAV = nil
local function startSpin()
    local root = getHRP(); if not root then return end
    if SpinBAV then SpinBAV:Destroy() end
    SpinBAV = Instance.new("BodyAngularVelocity", root)
    SpinBAV.MaxTorque = Vector3.new(0, math.huge, 0); SpinBAV.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
end
local function stopSpin() if SpinBAV then SpinBAV:Destroy(); SpinBAV = nil end end

-- Float
local FloatConn = nil
local function startFloat()
    if FloatConn then FloatConn:Disconnect() end
    FloatConn = RunService.Heartbeat:Connect(function()
        if not Config.FloatEnabled then return end
        local root = getHRP(); if not root then return end
        local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude
        local char = getChar(); if char then rp.FilterDescendantsInstances = {char} end
        local hit = workspace:Raycast(root.Position, Vector3.new(0, -200, 0), rp)
        if hit then
            local ty = hit.Position.Y + Config.FloatPower
            local diff = ty - root.Position.Y
            local vel = math.clamp(diff * 12, -40, 40)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, vel, root.AssemblyLinearVelocity.Z)
        end
    end)
end
local function stopFloat() if FloatConn then FloatConn:Disconnect(); FloatConn = nil end end

-- Galaxy
local GalaxyVF, GalaxyAttach = nil, nil
local function setupGalaxy()
    local root = getHRP(); if not root then return end
    if GalaxyVF then GalaxyVF:Destroy() end; if GalaxyAttach then GalaxyAttach:Destroy() end
    GalaxyAttach = Instance.new("Attachment", root); GalaxyVF = Instance.new("VectorForce", root)
    GalaxyVF.Attachment0 = GalaxyAttach; GalaxyVF.RelativeTo = Enum.ActuatorRelativeTo.World; GalaxyVF.ApplyAtCenterOfMass = true; GalaxyVF.Force = Vector3.zero
end
local function updateGalaxy()
    if not Config.GalaxyEnabled or not GalaxyVF then return end
    local char = getChar(); if not char then return end
    local mass = 0; for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
    local tg = DEFAULT_GRAVITY * (Config.GalaxyGravity / 100); GalaxyVF.Force = Vector3.new(0, mass * (DEFAULT_GRAVITY - tg) * 0.95, 0)
end
local function galaxyHop()
    if tick() - GalaxyLastHop < 0.08 then return end; GalaxyLastHop = tick()
    local root = getHRP(); local hum = getHum(); if not root or not hum then return end
    if hum.FloorMaterial == Enum.Material.Air then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 35, root.AssemblyLinearVelocity.Z) end
end
local function startGalaxy()
    Config.GalaxyEnabled = true; GalaxyHopEnabled = true; setupGalaxy()
    local hum = getHum(); if hum and hum.JumpPower > 0 then OriginalJump = hum.JumpPower end
    if hum then local ratio = math.sqrt((DEFAULT_GRAVITY * (Config.GalaxyGravity / 100)) / DEFAULT_GRAVITY); hum.JumpPower = OriginalJump * ratio end
end
local function stopGalaxy()
    Config.GalaxyEnabled = false; GalaxyHopEnabled = false
    if GalaxyVF then GalaxyVF:Destroy(); GalaxyVF = nil end; if GalaxyAttach then GalaxyAttach:Destroy(); GalaxyAttach = nil end
    local hum = getHum(); if hum then hum.JumpPower = OriginalJump end
end

-- Auto Duel
local DuelConn = nil; local DuelPhase = 1; local DuelReturning = false; local DuelReturnPhase = 1
local POS_R1 = Vector3.new(-473.05, -6.81, 30.29); local POS_R2 = Vector3.new(-473.19, -6.81, 28.32); local POS_REXTRA = Vector3.new(-485.97, -4.63, 25.18)
local POS_P1 = Vector3.new(-472.61, -6.81, 90.19); local POS_P2 = Vector3.new(-472.78, -6.81, 91.65); local POS_PEXTRA = Vector3.new(-486.38, -4.58, 95.27)

local function stopDuel()
    if DuelConn then DuelConn:Disconnect(); DuelConn = nil end
    DuelPhase = 1; DuelReturning = false; DuelReturnPhase = 1
    local hum = getHum(); if hum then hum:Move(Vector3.zero) end
    local root = getHRP(); if root then root.AssemblyLinearVelocity = Vector3.zero end
end
local function startDuelReturn(dir)
    DuelReturning = true; DuelReturnPhase = 1
    if DuelConn then DuelConn:Disconnect() end
    local wps = dir == "right" and {POS_P1, POS_R1, POS_R2} or {POS_R1, POS_P1, POS_P2}
    DuelConn = RunService.Heartbeat:Connect(function()
        if not Config.DuelEnabled then return end
        local root = getHRP(); local hum = getHum(); if not root or not hum then return end
        local target = wps[DuelReturnPhase]; if not target then stopDuel(); Config.DuelEnabled = false; return end
        local d = (target - root.Position).Unit; hum:Move(d)
        root.AssemblyLinearVelocity = Vector3.new(d.X * Config.ReturnSpeed, root.AssemblyLinearVelocity.Y, d.Z * Config.ReturnSpeed)
        if (Vector3.new(target.X, root.Position.Y, target.Z) - root.Position).Magnitude < 2 then
            if DuelReturnPhase < #wps then DuelReturnPhase = DuelReturnPhase + 1 else stopDuel(); Config.DuelEnabled = false end
        end
    end)
end
local function startDuelRight()
    stopDuel(); DuelPhase = 1; DuelReturning = false
    local wps = {POS_P1, POS_P2, POS_PEXTRA}
    DuelConn = RunService.Heartbeat:Connect(function()
        if not Config.DuelEnabled then return end
        local root = getHRP(); local hum = getHum(); if not root or not hum then return end
        local target = wps[DuelPhase]; if not target then startDuelReturn("right"); return end
        local d = (target - root.Position).Unit; hum:Move(d)
        root.AssemblyLinearVelocity = Vector3.new(d.X * Config.Speed, root.AssemblyLinearVelocity.Y, d.Z * Config.Speed)
        if (Vector3.new(target.X, root.Position.Y, target.Z) - root.Position).Magnitude < 2 then
            if DuelPhase < #wps then DuelPhase = DuelPhase + 1 else startDuelReturn("right") end
        end
    end)
end
local function startDuelLeft()
    stopDuel(); DuelPhase = 1; DuelReturning = false
    local wps = {POS_R1, POS_R2, POS_REXTRA}
    DuelConn = RunService.Heartbeat:Connect(function()
        if not Config.DuelEnabled then return end
        local root = getHRP(); local hum = getHum(); if not root or not hum then return end
        local target = wps[DuelPhase]; if not target then startDuelReturn("left"); return end
        local d = (target - root.Position).Unit; hum:Move(d)
        root.AssemblyLinearVelocity = Vector3.new(d.X * Config.Speed, root.AssemblyLinearVelocity.Y, d.Z * Config.Speed)
        if (Vector3.new(target.X, root.Position.Y, target.Z) - root.Position).Magnitude < 2 then
            if DuelPhase < #wps then DuelPhase = DuelPhase + 1 else startDuelReturn("left") end
        end
    end)
end

-- Auto Grab
local GrabConn = nil; local IsGrabbing = false; local GrabData = {}; local CachedAnimals = {}
local GrabRadius = 20; local GrabDuration = 0.12
local function isMyPlot(n)
    local plots = workspace:FindFirstChild("Plots"); if not plots then return false end
    local plot = plots:FindFirstChild(n); if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign"); if sign then local yb = sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end end
    return false
end
local function scanAnimals()
    local results = {}
    local plots = workspace:FindFirstChild("Plots"); if not plots then return results end
    for _, plot in ipairs(plots:GetChildren()) do if not isMyPlot(plot.Name) then
        local podiums = plot:FindFirstChild("AnimalPodiums"); if podiums then for _, pod in ipairs(podiums:GetChildren()) do pcall(function()
            local base = pod:FindFirstChild("Base"); local spawn = base and base:FindFirstChild("Spawn")
            if spawn then local att = spawn:FindFirstChild("PromptAttachment"); if att then for _, ch in ipairs(att:GetChildren()) do if ch:IsA("ProximityPrompt") then results[#results+1] = {prompt = ch, pos = spawn.Position} end end end end
        end) end end
    end end
    CachedAnimals = results
end
local function getNearestAnimal()
    local root = getHRP(); if not root then return nil end
    local best, bd = nil, GrabRadius
    for _, a in ipairs(CachedAnimals) do local d = (a.pos - root.Position).Magnitude; if d < bd then bd = d; best = a end end
    return best
end
local function execGrab(animal)
    if IsGrabbing then return end
    local p = animal.prompt; if not p or not p.Parent then return end
    if not GrabData[p] then GrabData[p] = {hold={}, trigger={}, ready=true}
        pcall(function() if getconnections then for _, c in ipairs(getconnections(p.PromptButtonHoldBegan)) do if c.Function then table.insert(GrabData[p].hold, c.Function) end end; for _, c in ipairs(getconnections(p.Triggered)) do if c.Function then table.insert(GrabData[p].trigger, c.Function) end end end end)
    end
    local data = GrabData[p]; if not data.ready then return end
    data.ready = false; IsGrabbing = true
    task.spawn(function() for _, f in ipairs(data.hold) do task.spawn(f) end; task.wait(GrabDuration); for _, f in ipairs(data.trigger) do task.spawn(f) end; data.ready = true; IsGrabbing = false end)
end
local function startGrab()
    if GrabConn then return end; scanAnimals()
    GrabConn = RunService.Heartbeat:Connect(function() if not Config.AutoGrabEnabled or IsGrabbing then return end; local a = getNearestAnimal(); if a then execGrab(a) end end)
    task.spawn(function() while Config.AutoGrabEnabled do task.wait(1.5); scanAnimals() end end)
end
local function stopGrab() if GrabConn then GrabConn:Disconnect(); GrabConn = nil end; IsGrabbing = false end

-- Bat Aimbot
local BatConn = nil; local BatAlign, BatAttach = nil, nil; local LastBatEquip, LastBatUse = 0, 0
local function findBat()
    local char = getChar(); if not char then return nil end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("bat") then return t end end
    if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("bat") then return t end end end
    return nil
end
local function nearestEnemy()
    local root = getHRP(); if not root then return nil, math.huge end
    local closest, md = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then
        local er = plr.Character:FindFirstChild("HumanoidRootPart"); local eh = plr.Character:FindFirstChildOfClass("Humanoid")
        if er and eh and eh.Health > 0 then local d = (er.Position - root.Position).Magnitude; if d < md then md = d; closest = er end end
    end end
    return closest, md
end
local function startBat()
    if BatConn then return end
    local root = getHRP(); local hum = getHum(); if not root or not hum then return end
    hum.AutoRotate = false
    if BatAttach then BatAttach:Destroy() end; if BatAlign then BatAlign:Destroy() end
    BatAttach = Instance.new("Attachment", root); BatAlign = Instance.new("AlignOrientation", root)
    BatAlign.Attachment0 = BatAttach; BatAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment; BatAlign.MaxTorque = Vector3.new(1e9,1e9,1e9); BatAlign.Responsiveness = 1000; BatAlign.RigidityEnabled = true
    BatConn = RunService.Heartbeat:Connect(function()
        if not Config.BatAimbotEnabled then return end
        local char = getChar(); local myRoot = getHRP(); local myHum = getHum(); if not char or not myRoot or not myHum then return end
        myRoot.CanCollide = false; local target, dist = nearestEnemy(); if not target then return end
        myRoot.AssemblyLinearVelocity = (target.Position - myRoot.Position).Unit * Config.BatSpeed
        if dist <= Config.BatRange then
            if tick() - LastBatEquip >= 0.3 then local bat = findBat(); if bat and bat.Parent ~= char then myHum:EquipTool(bat) end; LastBatEquip = tick() end
            if tick() - LastBatUse >= 0.3 then local bat = findBat(); if bat then bat:Activate() end; LastBatUse = tick() end
        end
        if BatAlign then BatAlign.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(target.Position.X, myRoot.Position.Y, target.Position.Z)) end
    end)
end
local function stopBat()
    if BatConn then BatConn:Disconnect(); BatConn = nil end
    if BatAlign then BatAlign:Destroy(); BatAlign = nil end; if BatAttach then BatAttach:Destroy(); BatAttach = nil end
    local hum = getHum(); if hum then hum.AutoRotate = true end
    local root = getHRP(); if root then root.AssemblyLinearVelocity = Vector3.zero end
end

-- Invent Jump (Ø¨Ø¯ÙÙ Ø£Ø¯Ø§Ø©)
UserInputService.JumpRequest:Connect(function()
    if not Config.InventJumpEnabled then return end
    local root = getHRP()
    if root then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.InventJumpPower, root.AssemblyLinearVelocity.Z) end
end)

-- Unwalk
local UnwalkConn = nil; local SavedAnimate = nil
local function startUnwalk()
    if UnwalkConn then return end
    local char = getChar(); if char then local anim = char:FindFirstChild("Animate"); if anim then SavedAnimate = anim:Clone(); anim:Destroy() end; local hum = getHum(); if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end end
    UnwalkConn = RunService.Heartbeat:Connect(function() if not Config.UnwalkEnabled then return end; local hum = getHum(); if not hum then return end; local animator = hum:FindFirstChildOfClass("Animator"); if animator then for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop() end end end)
end
local function stopUnwalk() if UnwalkConn then UnwalkConn:Disconnect(); UnwalkConn = nil end; local char = getChar(); if char and SavedAnimate then local na = SavedAnimate:Clone(); na.Parent = char; SavedAnimate = nil end end

-- Drop Brainrot
local DropActive = false
local function dropBrainrot()
    if DropActive then return end; DropActive = true
    local root = getHRP(); if not root then return end
    root.AssemblyLinearVelocity = Vector3.new(0, 115, 0); task.wait(0.4)
    root.AssemblyLinearVelocity = Vector3.new(0, -575, 0); task.wait(1.5); DropActive = false
end

-- TP Down
local function tpDown()
    local char = getChar(); local root = getHRP(); local hum = getHum(); if not char or not root or not hum then return end
    local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {char}; rp.FilterType = Enum.RaycastFilterType.Exclude; rp.IgnoreWater = true
    local result = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rp)
    if result then local ty = result.Position.Y + (hum.HipHeight or 2) + root.Size.Y/2 + 0.3; root.CFrame = CFrame.new(root.Position.X, ty, root.Position.Z) * root.CFrame.Rotation end
end

-- Hitbox
local function expandPrompts()
    local plots = workspace:FindFirstChild("Plots"); if not plots then return end
    for _, o in ipairs(plots:GetDescendants()) do if o:IsA("ProximityPrompt") then pcall(function() o.MaxActivationDistance = Config.HitboxRadius; o.RequiresLineOfSight = false end) end end
end
local function restorePrompts()
    local plots = workspace:FindFirstChild("Plots"); if not plots then return end
    for _, o in ipairs(plots:GetDescendants()) do if o:IsA("ProximityPrompt") then pcall(function() o.MaxActivationDistance = 10; o.RequiresLineOfSight = true end) end end
end

-- Xray
local XrayCache = {}
local function enableOptimizer()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01; game:GetService("Lighting").GlobalShadows = false; game:GetService("Lighting").Brightness = 2; game:GetService("Lighting").FogEnd = 9e9 end)
    pcall(function() for _, o in ipairs(workspace:GetDescendants()) do pcall(function() if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then o:Destroy() elseif o:IsA("BasePart") then o.CastShadow = false; o.Material = Enum.Material.Plastic end end) end end)
    pcall(function() for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o.Anchored and (o.Name:lower():find("base") or (o.Parent and o.Parent.Name:lower():find("base"))) then XrayCache[o] = o.LocalTransparencyModifier; o.LocalTransparencyModifier = 0.88 end end end)
end
local function disableOptimizer() for p, v in pairs(XrayCache) do if p then p.LocalTransparencyModifier = v end end; XrayCache = {} end

-- ESP
local function createESP(pl)
    if pl == LocalPlayer then return end; local c = pl.Character; if not c or c:FindFirstChild("ESP_Box") then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local box = Instance.new("BoxHandleAdornment", c); box.Name = "ESP_Box"; box.Adornee = hrp; box.Size = Vector3.new(4, 6, 2); box.Color3 = Color3.fromRGB(136, 0, 255); box.Transparency = 0.5; box.AlwaysOnTop = true; box.ZIndex = 10
end
local function removeESP(pl) local c = pl.Character; if c then local b = c:FindFirstChild("ESP_Box"); if b then b:Destroy() end end end
local function enableESP() Config.EspEnabled = true; for _, pl in ipairs(Players:GetPlayers()) do createESP(pl) end; Players.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function() task.wait(0.3); if Config.EspEnabled then createESP(pl) end end) end) end
local function disableESP() Config.EspEnabled = false; for _, pl in ipairs(Players:GetPlayers()) do removeESP(pl) end end

-- FOV
local function setFOV(v) pcall(function() Camera.FieldOfView = v and 100 or 70 end) end

-- Anti Fling
local AntiFlingConn = nil
local function startAntiFling()
    if AntiFlingConn then AntiFlingConn:Disconnect() end
    AntiFlingConn = RunService.Stepped:Connect(function() if not Config.AntiFlingEnabled then return end; for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LocalPlayer and pl.Character then for _, o in ipairs(pl.Character:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide = false end end end end end)
end
local function stopAntiFling() if AntiFlingConn then AntiFlingConn:Disconnect(); AntiFlingConn = nil end end

-- Discord
local DISCORD_LINK = "https://discord.gg/XpxhSsYfUc"
local function copyDiscord() pcall(function() setclipboard(DISCORD_LINK); notify("â Discord Copied!", 2) end) end

-- Anti AFK
LocalPlayer.Idled:Connect(function() VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame); task.wait(0.5); VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame) end)

-- Heartbeat
RunService.Heartbeat:Connect(function()
    if Config.GalaxyEnabled and GalaxyHopEnabled and SpaceHeld then galaxyHop() end
    if Config.GalaxyEnabled then updateGalaxy() end
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Config.SpinEnabled then stopSpin(); startSpin() end
    if Config.AntiRagdollEnabled then stopAntiRagdoll(); startAntiRagdoll() end
    if Config.FloatEnabled then stopFloat(); startFloat() end
    if Config.GalaxyEnabled then stopGalaxy(); startGalaxy() end
    if Config.UnwalkEnabled then stopUnwalk(); startUnwalk() end
    if Config.DuelEnabled then stopDuel(); Config.DuelEnabled = false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if hum and hum.JumpPower > 0 then OriginalJump = hum.JumpPower end
end)

-- Init
if LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum and hum.JumpPower > 0 then OriginalJump = hum.JumpPower end end
if Config.SpinEnabled then startSpin() end; if Config.AntiRagdollEnabled then startAntiRagdoll() end; if Config.FloatEnabled then startFloat() end
-- ============================================================
-- DISCORD + COPY (ÙØ¹ Ø§ÙÙÙÙØ´Ù)
-- ============================================================
local DiscordFrame = Instance.new("Frame", Screen)
DiscordFrame.Size = UDim2.new(0, 160, 0, 32)
DiscordFrame.Position = UDim2.new(1, -170, 0, 5)
DiscordFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
DiscordFrame.BorderSizePixel = 0
DiscordFrame.ZIndex = 200
Instance.new("UICorner", DiscordFrame).CornerRadius = UDim.new(0, 8)

local discordStroke = Instance.new("UIStroke", DiscordFrame)
discordStroke.Color = Color3.fromRGB(136, 0, 255)
discordStroke.Thickness = 1.5

local discordLabel = Instance.new("TextLabel", DiscordFrame)
discordLabel.Size = UDim2.new(1, -28, 1, 0)
discordLabel.Position = UDim2.new(0, 8, 0, 0)
discordLabel.BackgroundTransparency = 1
discordLabel.Text = "DISCORD"
discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
discordLabel.Font = Enum.Font.GothamBold
discordLabel.TextSize = 11
discordLabel.TextXAlignment = Enum.TextXAlignment.Left
discordLabel.ZIndex = 201

local copyIcon = Instance.new("TextButton", DiscordFrame)
copyIcon.Size = UDim2.new(0, 24, 0, 24)
copyIcon.Position = UDim2.new(1, -28, 0.5, -12)
copyIcon.BackgroundTransparency = 1
copyIcon.Text = "ð"
copyIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
copyIcon.Font = Enum.Font.GothamBold
copyIcon.TextSize = 12
copyIcon.ZIndex = 202
copyIcon.MouseButton1Click:Connect(copyDiscord)

-- Discord Animation
task.spawn(function()
    local t = 0
    while DiscordFrame and DiscordFrame.Parent do
        t = t + 0.03
        local r = 136 + math.sin(t * 3) * 60
        local g = 0
        local b = 255 - math.sin(t * 3) * 60
        discordStroke.Color = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
        task.wait(0.03)
    end
end)

local discordBtn = Instance.new("TextButton", DiscordFrame)
discordBtn.Size = UDim2.new(1, -30, 1, 0)
discordBtn.BackgroundTransparency = 1
discordBtn.Text = ""
discordBtn.ZIndex = 203
discordBtn.MouseButton1Click:Connect(copyDiscord)

-- ============================================================
-- LOCK + RESET BUTTONS
-- ============================================================
local ButtonsLocked = false

local LockBtn = Instance.new("TextButton", Screen)
LockBtn.Size = UDim2.new(0, 60, 0, 32)
LockBtn.Position = UDim2.new(0.5, -66, 0, 42)
LockBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LockBtn.BorderSizePixel = 0
LockBtn.Text = "ð"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 14
LockBtn.AutoButtonColor = false
LockBtn.ZIndex = 200
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 8)
local lockStroke = Instance.new("UIStroke", LockBtn)
lockStroke.Color = Color3.fromRGB(136, 0, 255)
lockStroke.Thickness = 2

LockBtn.MouseButton1Click:Connect(function()
    ButtonsLocked = not ButtonsLocked
    LockBtn.Text = ButtonsLocked and "ð" or "ð"
    lockStroke.Color = ButtonsLocked and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(136, 0, 255)
end)

-- Reset Button
local defaultPositions = {
    ["RIGHT\nPLAY"] = {90, 60},
    ["LEFT\nPLAY"] = {160, 60},
    ["BAT"] = {90, 130},
    ["DROP"] = {160, 130},
    ["FLOAT"] = {90, 200},
    ["DUEL\nSTOP"] = {160, 200},
    ["TP\nDOWN"] = {90, 270},
}
local function resetAllButtons()
    for name, pos in pairs(defaultPositions) do
        if FloatBtns[name] then
            FloatBtns[name].btn.Position = UDim2.new(0, pos[1], 0, pos[2])
        end
    end
    notify("â Buttons Reset!", 2)
end

local ResetBtn = Instance.new("TextButton", Screen)
ResetBtn.Size = UDim2.new(0, 60, 0, 32)
ResetBtn.Position = UDim2.new(0.5, 6, 0, 42)
ResetBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ResetBtn.BorderSizePixel = 0
ResetBtn.Text = "ð"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 14
ResetBtn.AutoButtonColor = false
ResetBtn.ZIndex = 200
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8)
local resetStroke = Instance.new("UIStroke", ResetBtn)
resetStroke.Color = Color3.fromRGB(255, 100, 100)
resetStroke.Thickness = 2
ResetBtn.MouseButton1Click:Connect(resetAllButtons)

-- ============================================================
-- FLOATING BUTTONS (7 Ø£Ø²Ø±Ø§Ø±: RIGHT/LEFT, BAT/DROP, FLOAT/DUEL STOP, TP DOWN)
-- ============================================================
local FloatBtns = {}
local function createFloatBtn(name, posX, posY, callback)
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

    -- Drag
    local drag = false
    local ds, sp
    btn.InputBegan:Connect(function(input)
        if ButtonsLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = input.Position; sp = btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and not ButtonsLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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

createFloatBtn("RIGHT\nPLAY", 90, 60, function(s)
    Config.DuelEnabled = s
    if s then startDuelRight() else stopDuel() end
end)

createFloatBtn("LEFT\nPLAY", 160, 60, function(s)
    Config.DuelEnabled = s
    if s then startDuelLeft() else stopDuel() end
end)

createFloatBtn("BAT", 90, 130, function(s)
    Config.BatAimbotEnabled = s
    if s then startBat() else stopBat() end
end)

createFloatBtn("DROP", 160, 130, function(s)
    if s then task.spawn(dropBrainrot) end
end)

createFloatBtn("FLOAT", 90, 200, function(s)
    Config.FloatEnabled = s
    if s then startFloat() else stopFloat() end
end)

createFloatBtn("DUEL\nSTOP", 160, 200, function(s)
    Config.DuelEnabled = false; stopDuel()
    if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
    if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
end)

createFloatBtn("TP\nDOWN", 90, 270, function(s)
    if s then tpDown() end
end)

-- ============================================================
-- SPEED DISPLAY (Ø£Ø¨ÙØ¶ ÙÙÙ Ø§ÙØ±Ø£Ø³)
-- ============================================================
local SpeedBillboard = nil
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    local head = char:FindFirstChild("Head")
    if head then
        if SpeedBillboard and SpeedBillboard.Parent then SpeedBillboard:Destroy() end
        SpeedBillboard = Instance.new("BillboardGui", head)
        SpeedBillboard.Size = UDim2.new(0, 100, 0, 18)
        SpeedBillboard.StudsOffset = Vector3.new(0, 2.8, 0)
        SpeedBillboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel", SpeedBillboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextStrokeTransparency = 0.4
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if SpeedBillboard and SpeedBillboard.Parent then
        local root = getHRP()
        if root then
            local spd = math.floor(Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude + 0.5)
            local label = SpeedBillboard:FindFirstChildOfClass("TextLabel")
            if label then label.Text = spd end
        end
    end
end)

-- ============================================================
-- MAIN MENU (4 TABS)
-- ============================================================
local MainMenu = Instance.new("Frame", Screen)
MainMenu.Size = UDim2.new(0, 230, 0, 370)
MainMenu.Position = UDim2.new(0.5, -115, 0.5, -185)
MainMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.ZIndex = 30
Instance.new("UICorner", MainMenu).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", MainMenu).Color = Color3.fromRGB(136, 0, 255)
Instance.new("UIStroke", MainMenu).Thickness = 2

local mmTitle = Instance.new("TextLabel", MainMenu)
mmTitle.Size = UDim2.new(1, 0, 0, 30); mmTitle.BackgroundTransparency = 1; mmTitle.Text = "Msmsm Hub v7.0"; mmTitle.TextColor3 = Color3.fromRGB(255,255,255); mmTitle.Font = Enum.Font.GothamBlack; mmTitle.TextSize = 14; mmTitle.TextXAlignment = Enum.TextXAlignment.Center; mmTitle.Position = UDim2.new(0,0,0,6)

local mmClose = Instance.new("TextButton", MainMenu)
mmClose.Size = UDim2.new(0, 26, 0, 26); mmClose.Position = UDim2.new(1, -32, 0, 6); mmClose.BackgroundColor3 = Color3.fromRGB(25,25,25); mmClose.BorderSizePixel = 0; mmClose.Text = "X"; mmClose.TextColor3 = Color3.fromRGB(255,255,255); mmClose.Font = Enum.Font.GothamBold; mmClose.TextSize = 12; Instance.new("UICorner", mmClose).CornerRadius = UDim.new(0,6)
mmClose.MouseButton1Click:Connect(function() MainMenu.Visible = false end)

-- Drag MainMenu
local mmDrag = false; local mmDS, mmSP
MainMenu.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mmDrag = true; mmDS = input.Position; mmSP = MainMenu.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if mmDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - mmDS
        MainMenu.Position = UDim2.new(mmSP.X.Scale, mmSP.X.Offset + d.X, mmSP.Y.Scale, mmSP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then mmDrag = false end
end)

-- Tabs
local Tabs = {}
local TabContents = {}
local TabNames = {"Settings", "Combat", "Control", "Visual"}
local TabBar = Instance.new("Frame", MainMenu)
TabBar.Size = UDim2.new(1, 0, 0, 26); TabBar.Position = UDim2.new(0, 0, 0, 36); TabBar.BackgroundTransparency = 1; TabBar.ZIndex = 31

for i, name in ipairs(TabNames) do
    local tab = Instance.new("TextButton", TabBar)
    tab.Size = UDim2.new(0.25, -4, 1, 0); tab.Position = UDim2.new((i-1)*0.25, 2, 0, 0); tab.BackgroundColor3 = i==1 and Color3.fromRGB(136,0,255) or Color3.fromRGB(25,25,25); tab.BorderSizePixel = 0; tab.Text = name; tab.TextColor3 = Color3.fromRGB(255,255,255); tab.Font = Enum.Font.GothamBold; tab.TextSize = 9; tab.AutoButtonColor = false; tab.ZIndex = 32; Instance.new("UICorner", tab).CornerRadius = UDim.new(0,5)

    local content = Instance.new("ScrollingFrame", MainMenu)
    content.Size = UDim2.new(1, -8, 1, -68); content.Position = UDim2.new(0, 4, 0, 64); content.BackgroundTransparency = 1; content.BorderSizePixel = 0; content.ScrollBarThickness = 3; content.ScrollBarImageColor3 = Color3.fromRGB(136,0,255); content.Visible = (i==1); content.ZIndex = 31; content.CanvasSize = UDim2.new(0, 0, 0, 800)
    local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 5); layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tabs[i] = tab; TabContents[i] = content

    tab.MouseButton1Click:Connect(function()
        for j, t in ipairs(Tabs) do t.BackgroundColor3 = j==i and Color3.fromRGB(136,0,255) or Color3.fromRGB(25,25,25) end
        for j, c in ipairs(TabContents) do c.Visible = (j==i) end
    end)
end

-- Slider with TextBox
local function createSlider(parent, name, minVal, maxVal, default, callback)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1, 0, 0, 42); container.BackgroundTransparency = 1; container.ZIndex = 32
    local lbl = Instance.new("TextLabel", container); lbl.Size = UDim2.new(1, -50, 0, 14); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(200,200,200); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
    local box = Instance.new("TextBox", container); box.Size = UDim2.new(0, 42, 0, 16); box.Position = UDim2.new(1, -42, 0, 0); box.BackgroundColor3 = Color3.fromRGB(25,25,25); box.BorderSizePixel = 0; box.Text = tostring(default); box.TextColor3 = Color3.fromRGB(255,255,255); box.Font = Enum.Font.GothamBold; box.TextSize = 9; box.TextXAlignment = Enum.TextXAlignment.Center; box.ClearTextOnFocus = false; box.ZIndex = 33; Instance.new("UICorner", box).CornerRadius = UDim.new(0,4)
    local bg = Instance.new("Frame", container); bg.Size = UDim2.new(1, 0, 0, 6); bg.Position = UDim2.new(0,0,0,22); bg.BackgroundColor3 = Color3.fromRGB(30,30,30); bg.BorderSizePixel = 0; bg.ZIndex = 33; Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((default-minVal)/(maxVal-minVal), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(136,0,255); fill.BorderSizePixel = 0; fill.ZIndex = 34; Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local sbtn = Instance.new("TextButton", bg); sbtn.Size = UDim2.new(1,0,2,0); sbtn.BackgroundTransparency = 1; sbtn.Text = ""; sbtn.ZIndex = 35
    local function update(val) local c = math.clamp(math.floor(val), minVal, maxVal); fill.Size = UDim2.new((c-minVal)/(maxVal-minVal), 0, 1, 0); box.Text = tostring(c); callback(c) end
    box.FocusLost:Connect(function() local n = tonumber(box.Text); if n then update(n) else box.Text = tostring(default) end end)
    local sDrag = false; sbtn.MouseButton1Down:Connect(function() sDrag = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sDrag = false end end)
    UserInputService.InputChanged:Connect(function(input) if sDrag and input.UserInputType == Enum.UserInputType.MouseMovement then local pct = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1); update(minVal + (maxVal-minVal)*pct) end end)
end

-- Menu Toggle
local MenuToggles = {}
local function createMenuToggle(parent, name, default, callback)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1, 0, 0, 30); container.BackgroundTransparency = 1; container.ZIndex = 32
    local lbl = Instance.new("TextLabel", container); lbl.Size = UDim2.new(1, -48, 1, 0); lbl.Position = UDim2.new(0, 6, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
    local track = Instance.new("Frame", container); track.Size = UDim2.new(0, 36, 0, 16); track.Position = UDim2.new(1, -42, 0.5, -8); track.BackgroundColor3 = default and Color3.fromRGB(136,0,255) or Color3.fromRGB(40,40,48); track.BorderSizePixel = 0; track.ZIndex = 33; Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame", track); dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = default and UDim2.new(1, -13, 0.1, 0) or UDim2.new(0, 2, 0.1, 0); dot.BackgroundColor3 = Color3.fromRGB(255,255,255); dot.BorderSizePixel = 0; dot.ZIndex = 34; Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local state = default
    local btn = Instance.new("TextButton", container); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 35
    btn.MouseButton1Click:Connect(function() state = not state; track.BackgroundColor3 = state and Color3.fromRGB(136,0,255) or Color3.fromRGB(40,40,48); dot.Position = state and UDim2.new(1, -13, 0.1, 0) or UDim2.new(0, 2, 0.1, 0); callback(state) end)
    local mt = {setState = function(s) state = s; track.BackgroundColor3 = s and Color3.fromRGB(136,0,255) or Color3.fromRGB(40,40,48); dot.Position = s and UDim2.new(1, -13, 0.1, 0) or UDim2.new(0, 2, 0.1, 0) end}
    MenuToggles[name] = mt; return mt
end

-- POPULATE TABS
-- Settings
createSlider(TabContents[1], "Speed", 10, 200, Config.Speed, function(v) Config.Speed = v end)
createSlider(TabContents[1], "Return", 10, 100, Config.ReturnSpeed, function(v) Config.ReturnSpeed = v end)
createSlider(TabContents[1], "Spin Spd", 10, 500, Config.SpinSpeed, function(v) Config.SpinSpeed = v; if SpinBAV then SpinBAV.AngularVelocity = Vector3.new(0, v, 0) end end)
createSlider(TabContents[1], "Float Pwr", 5, 50, Config.FloatPower, function(v) Config.FloatPower = v end)
createSlider(TabContents[1], "Gravity %", 10, 95, Config.GalaxyGravity, function(v) Config.GalaxyGravity = v; if Config.GalaxyEnabled then stopGalaxy(); startGalaxy() end end)
createSlider(TabContents[1], "Jump Pwr", 10, 200, Config.InventJumpPower, function(v) Config.InventJumpPower = v end)
createSlider(TabContents[1], "Grab Rad", 5, 200, Config.GrabRadius, function(v) Config.GrabRadius = v; GrabRadius = v end)
createSlider(TabContents[1], "Bat Spd", 10, 200, Config.BatSpeed, function(v) Config.BatSpeed = v end)

local saveBtn = Instance.new("TextButton", TabContents[1])
saveBtn.Size = UDim2.new(1, 0, 0, 36); saveBtn.BackgroundColor3 = Color3.fromRGB(136,0,255); saveBtn.BorderSizePixel = 0; saveBtn.Text = "SAVE"; saveBtn.TextColor3 = Color3.fromRGB(255,255,255); saveBtn.Font = Enum.Font.GothamBlack; saveBtn.TextSize = 16; saveBtn.ZIndex = 32; Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
saveBtn.MouseButton1Click:Connect(function() saveConfig(); saveBtn.Text = "â SAVED!"; task.delay(1.5, function() saveBtn.Text = "SAVE" end) end)

-- Combat
createMenuToggle(TabContents[2], "RIGHT PLAY", false, function(s) Config.DuelEnabled = s; if s then startDuelRight() else stopDuel() end; if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(s) end end)
createMenuToggle(TabContents[2], "LEFT PLAY", false, function(s) Config.DuelEnabled = s; if s then startDuelLeft() else stopDuel() end; if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(s) end end)
createMenuToggle(TabContents[2], "GRAB", false, function(s) Config.AutoGrabEnabled = s; if s then startGrab() else stopGrab() end end)
createMenuToggle(TabContents[2], "BAT", false, function(s) Config.BatAimbotEnabled = s; if s then startBat() else stopBat() end; if FloatBtns["BAT"] then FloatBtns["BAT"].setState(s) end end)
createMenuToggle(TabContents[2], "DROP", false, function(s) if s then task.spawn(dropBrainrot) end end)
createMenuToggle(TabContents[2], "DUEL STOP", false, function(s) Config.DuelEnabled = false; stopDuel(); if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end; if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end end)
createMenuToggle(TabContents[2], "SPIN", false, function(s) Config.SpinEnabled = s; if s then startSpin() else stopSpin() end end)
createMenuToggle(TabContents[2], "INVENT JUMP", false, function(s) Config.InventJumpEnabled = s end)
createMenuToggle(TabContents[2], "TP DOWN", false, function(s) if s then tpDown() end end)
createMenuToggle(TabContents[2], "UNWALK", false, function(s) Config.UnwalkEnabled = s; if s then startUnwalk() else stopUnwalk() end end)

-- Control
createMenuToggle(TabContents[3], "Galaxy", false, function(s) Config.GalaxyEnabled = s; if s then startGalaxy() else stopGalaxy() end end)
createMenuToggle(TabContents[3], "Xray", false, function(s) Config.OptimizerEnabled = s; if s then enableOptimizer() else disableOptimizer() end end)
createMenuToggle(TabContents[3], "Anti Fling", false, function(s) Config.AntiFlingEnabled = s; if s then startAntiFling() else stopAntiFling() end end)

-- Visual
createMenuToggle(TabContents[4], "Hitbox Exp", false, function(s) Config.HitboxEnabled = s; if s then expandPrompts() else restorePrompts() end end)
createMenuToggle(TabContents[4], "FOV", false, function(s) Config.FovEnabled = s; setFOV(s) end)
createMenuToggle(TabContents[4], "ESP", false, function(s) if s then enableESP() else disableESP() end end)

-- Menu Button
local MenuBtn = Instance.new("TextButton", Screen)
MenuBtn.Size = UDim2.new(0, 44, 0, 44); MenuBtn.Position = UDim2.new(0.5, -22, 0, 80); MenuBtn.BackgroundColor3 = Color3.fromRGB(12,12,12); MenuBtn.BorderSizePixel = 0; MenuBtn.Text = "M"; MenuBtn.TextColor3 = Color3.fromRGB(136,0,255); MenuBtn.Font = Enum.Font.GothamBlack; MenuBtn.TextSize = 18; MenuBtn.ZIndex = 100; Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0,12); Instance.new("UIStroke", MenuBtn).Color = Color3.fromRGB(136,0,255); Instance.new("UIStroke", MenuBtn).Thickness = 2
MenuBtn.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
-- ============================================================
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Menu Toggle
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainMenu.Visible = not MainMenu.Visible
        return
    end

    -- Right Duel (R)
    if input.KeyCode == Enum.KeyCode.R then
        Config.DuelEnabled = not Config.DuelEnabled
        if Config.DuelEnabled then startDuelRight() else stopDuel() end
        if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(Config.DuelEnabled) end
        if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(Config.DuelEnabled) end
        if Config.DuelEnabled then
            if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
            if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(false) end
        end
        return
    end

    -- Left Duel (L)
    if input.KeyCode == Enum.KeyCode.L then
        Config.DuelEnabled = not Config.DuelEnabled
        if Config.DuelEnabled then startDuelLeft() else stopDuel() end
        if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(Config.DuelEnabled) end
        if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(Config.DuelEnabled) end
        if Config.DuelEnabled then
            if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
            if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(false) end
        end
        return
    end

    -- Stop Duel (T)
    if input.KeyCode == Enum.KeyCode.T then
        Config.DuelEnabled = false; stopDuel()
        if FloatBtns["RIGHT\nPLAY"] then FloatBtns["RIGHT\nPLAY"].setState(false) end
        if FloatBtns["LEFT\nPLAY"] then FloatBtns["LEFT\nPLAY"].setState(false) end
        if MenuToggles["RIGHT PLAY"] then MenuToggles["RIGHT PLAY"].setState(false) end
        if MenuToggles["LEFT PLAY"] then MenuToggles["LEFT PLAY"].setState(false) end
        return
    end

    -- Grab (G)
    if input.KeyCode == Enum.KeyCode.G then
        Config.AutoGrabEnabled = not Config.AutoGrabEnabled
        if Config.AutoGrabEnabled then startGrab() else stopGrab() end
        if MenuToggles["GRAB"] then MenuToggles["GRAB"].setState(Config.AutoGrabEnabled) end
        return
    end

    -- Bat (B)
    if input.KeyCode == Enum.KeyCode.B then
        Config.BatAimbotEnabled = not Config.BatAimbotEnabled
        if Config.BatAimbotEnabled then startBat() else stopBat() end
        if FloatBtns["BAT"] then FloatBtns["BAT"].setState(Config.BatAimbotEnabled) end
        if MenuToggles["BAT"] then MenuToggles["BAT"].setState(Config.BatAimbotEnabled) end
        return
    end

    -- Drop (P)
    if input.KeyCode == Enum.KeyCode.P then
        task.spawn(dropBrainrot)
        return
    end

    -- Float (F)
    if input.KeyCode == Enum.KeyCode.F then
        Config.FloatEnabled = not Config.FloatEnabled
        if Config.FloatEnabled then startFloat() else stopFloat() end
        if FloatBtns["FLOAT"] then FloatBtns["FLOAT"].setState(Config.FloatEnabled) end
        return
    end

    -- Spin (V)
    if input.KeyCode == Enum.KeyCode.V then
        Config.SpinEnabled = not Config.SpinEnabled
        if Config.SpinEnabled then startSpin() else stopSpin() end
        if MenuToggles["SPIN"] then MenuToggles["SPIN"].setState(Config.SpinEnabled) end
        return
    end

    -- Invent Jump (J)
    if input.KeyCode == Enum.KeyCode.J then
        Config.InventJumpEnabled = not Config.InventJumpEnabled
        if MenuToggles["INVENT JUMP"] then MenuToggles["INVENT JUMP"].setState(Config.InventJumpEnabled) end
        return
    end

    -- TP Down (U)
    if input.KeyCode == Enum.KeyCode.U then
        tpDown()
        return
    end

    -- Unwalk (N)
    if input.KeyCode == Enum.KeyCode.N then
        Config.UnwalkEnabled = not Config.UnwalkEnabled
        if Config.UnwalkEnabled then startUnwalk() else stopUnwalk() end
        if MenuToggles["UNWALK"] then MenuToggles["UNWALK"].setState(Config.UnwalkEnabled) end
        return
    end

    -- Galaxy (Y)
    if input.KeyCode == Enum.KeyCode.Y then
        Config.GalaxyEnabled = not Config.GalaxyEnabled
        if Config.GalaxyEnabled then startGalaxy() else stopGalaxy() end
        if MenuToggles["Galaxy"] then MenuToggles["Galaxy"].setState(Config.GalaxyEnabled) end
        return
    end

    -- Xray (X)
    if input.KeyCode == Enum.KeyCode.X then
        Config.OptimizerEnabled = not Config.OptimizerEnabled
        if Config.OptimizerEnabled then enableOptimizer() else disableOptimizer() end
        if MenuToggles["Xray"] then MenuToggles["Xray"].setState(Config.OptimizerEnabled) end
        return
    end

    -- Anti Fling (M)
    if input.KeyCode == Enum.KeyCode.M then
        Config.AntiFlingEnabled = not Config.AntiFlingEnabled
        if Config.AntiFlingEnabled then startAntiFling() else stopAntiFling() end
        if MenuToggles["Anti Fling"] then MenuToggles["Anti Fling"].setState(Config.AntiFlingEnabled) end
        return
    end

    -- Hitbox (Z)
    if input.KeyCode == Enum.KeyCode.Z then
        Config.HitboxEnabled = not Config.HitboxEnabled
        if Config.HitboxEnabled then expandPrompts() else restorePrompts() end
        if MenuToggles["Hitbox Exp"] then MenuToggles["Hitbox Exp"].setState(Config.HitboxEnabled) end
        return
    end

    -- FOV (O)
    if input.KeyCode == Enum.KeyCode.O then
        Config.FovEnabled = not Config.FovEnabled
        setFOV(Config.FovEnabled)
        if MenuToggles["FOV"] then MenuToggles["FOV"].setState(Config.FovEnabled) end
        return
    end

    -- ESP (K)
    if input.KeyCode == Enum.KeyCode.K then
        if Config.EspEnabled then disableESP() else enableESP() end
        if MenuToggles["ESP"] then MenuToggles["ESP"].setState(Config.EspEnabled) end
        return
    end

    -- Space for Galaxy
    if input.KeyCode == Enum.KeyCode.Space then
        SpaceHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then SpaceHeld = false end
end)

-- ============================================================
-- PROGRESS BAR
-- ============================================================
local ProgBar = Instance.new("Frame", Screen)
ProgBar.Size = UDim2.new(0, 230, 0, 36)
ProgBar.Position = UDim2.new(0.5, -115, 1, -55)
ProgBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ProgBar.BorderSizePixel = 0
ProgBar.ZIndex = 50
Instance.new("UICorner", ProgBar).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ProgBar).Color = Color3.fromRGB(136, 0, 255)
Instance.new("UIStroke", ProgBar).Thickness = 1.5

local pbFill = Instance.new("Frame", ProgBar)
pbFill.Size = UDim2.new(0, 0, 1, 0)
pbFill.BackgroundColor3 = Color3.fromRGB(136, 0, 255)
pbFill.BorderSizePixel = 0
Instance.new("UICorner", pbFill).CornerRadius = UDim.new(0, 10)

local pbLabel = Instance.new("TextLabel", ProgBar)
pbLabel.Size = UDim2.new(1, 0, 1, 0)
pbLabel.BackgroundTransparency = 1
pbLabel.Text = "READY"
pbLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pbLabel.Font = Enum.Font.GothamBold
pbLabel.TextSize = 12
pbLabel.ZIndex = 51

-- Hook Grab to Progress Bar
local oldExecGrab = execGrab
execGrab = function(animal)
    if IsGrabbing then return end
    local p = animal.prompt; if not p or not p.Parent then return end
    if not GrabData[p] then GrabData[p] = {hold={}, trigger={}, ready=true}
        pcall(function() if getconnections then for _, c in ipairs(getconnections(p.PromptButtonHoldBegan)) do if c.Function then table.insert(GrabData[p].hold, c.Function) end end; for _, c in ipairs(getconnections(p.Triggered)) do if c.Function then table.insert(GrabData[p].trigger, c.Function) end end end end)
    end
    local data = GrabData[p]; if not data.ready then return end
    data.ready = false; IsGrabbing = true
    local st = tick()
    pbLabel.Text = "GRABBING..."
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        while tick() - st < GrabDuration do
            local prog = math.clamp((tick() - st) / GrabDuration, 0, 1)
            pbFill.Size = UDim2.new(prog, 0, 1, 0)
            pbLabel.Text = math.floor(prog * 100) .. "%"
            task.wait()
        end
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        pbFill.Size = UDim2.new(0, 0, 1, 0)
        pbLabel.Text = "READY"
        data.ready = true; IsGrabbing = false
    end)
end

-- ProgBar Drag
local pbDrag = false; local pbDS, pbSP
ProgBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pbDrag = true; pbDS = input.Position; pbSP = ProgBar.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if pbDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - pbDS
        ProgBar.Position = UDim2.new(pbSP.X.Scale, pbSP.X.Offset + d.X, pbSP.Y.Scale, pbSP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pbDrag = false end
end)

-- ============================================================
-- AUTO SAVE ON TELEPORT
-- ============================================================
LocalPlayer.OnTeleport:Connect(function()
    saveConfig()
end)

-- ============================================================
-- CLEANUP ON DESTROY
-- ============================================================
Screen.Destroying:Connect(function()
    stopDuel(); stopSpin(); stopFloat(); stopGalaxy(); stopAntiRagdoll()
    stopUnwalk(); stopGrab(); stopBat(); stopAntiFling()
    if DuelConn then DuelConn:Disconnect() end
    if GrabConn then GrabConn:Disconnect() end
    if FloatConn then FloatConn:Disconnect() end
    if AntiRagdollConn then AntiRagdollConn:Disconnect() end
    if UnwalkConn then UnwalkConn:Disconnect() end
    if BatConn then BatConn:Disconnect() end
    if AntiFlingConn then AntiFlingConn:Disconnect() end
    if GalaxyVF then GalaxyVF:Destroy() end
    if GalaxyAttach then GalaxyAttach:Destroy() end
    if BatAlign then BatAlign:Destroy() end
    if BatAttach then BatAttach:Destroy() end
    saveConfig()
end)

-- ============================================================
-- WELCOME NOTIFICATION
-- ============================================================
task.delay(5, function()
    notify("â Msmsm Hub v7.0 Ready!", 3)
end)

-- ============================================================
-- FINAL INIT
-- ============================================================
task.spawn(function()
    task.wait(0.3)
    if Config.SpinEnabled then startSpin() end
    if Config.AntiRagdollEnabled then startAntiRagdoll() end
    if Config.FloatEnabled then startFloat() end
end)

-- ============================================================
-- END OF MSMSM HUB v7.0 - FINAL GOD MO
