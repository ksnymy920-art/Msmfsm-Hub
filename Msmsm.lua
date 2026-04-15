--[[
    ★ MSMSM HUB V25 • FINAL VERSION ★
    - FIXED: All Missing Buttons Restored.
    - FIXED: Strict Inventory Protection (Safe for items).
    - FIXED: Pinned Search & Fast Loading.
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftPanel = Instance.new("Frame")
local RightPanel = Instance.new("ScrollingFrame")
local Title = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")
local UIGridLayout = Instance.new("UIGridLayout")

local player = game.Players.LocalPlayer
local ProtectedPlayers = {} 
local PlayerIcons = {}

-- تحميل الصور مسبقاً فوراً
local function preLoad()
    for _, p in pairs(game.Players:GetPlayers()) do
        task.spawn(function()
            pcall(function()
                PlayerIcons[p.UserId] = game.Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
        end)
    end
end
preLoad()

-- الواجهة الأساسية
ScreenGui.Name = "MsmsmGlobalV25"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
MainFrame.Position = UDim2.new(0.5, -400, 0.1, 0)
MainFrame.Size = UDim2.new(0, 800, 0, 600)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Thickness = 3; FrameStroke.Color = Color3.fromRGB(255, 0, 0)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 70)
Title.Text = "★ MSMSM HUB V25 • GLOBAL ★"
Title.TextColor3 = Color3.new(1, 1, 1); Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 26
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 20)

TextBox.Parent = MainFrame
TextBox.Size = UDim2.new(0.65, 0, 0, 60); TextBox.Position = UDim2.new(0.32, 0, 0.14, 0)
TextBox.PlaceholderText = "Msmsm Hub"; TextBox.Text = "Msmsm Hub"
TextBox.BackgroundColor3 = Color3.fromRGB(40, 0, 0); TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.Font = Enum.Font.GothamBold; TextBox.TextSize = 20
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 15)

LeftPanel.Parent = MainFrame
LeftPanel.Size = UDim2.new(0, 220, 0, 440); LeftPanel.Position = UDim2.new(0.02, 0, 0.25, 0)
LeftPanel.BackgroundTransparency = 1

RightPanel.Parent = MainFrame
RightPanel.Size = UDim2.new(0, 530, 0, 440); RightPanel.Position = UDim2.new(0.32, 0, 0.25, 0)
RightPanel.CanvasSize = UDim2.new(0, 0, 6, 0) -- مساحة كبيرة عشان كل الأزرار تطلع
RightPanel.ScrollBarThickness = 8; RightPanel.BackgroundTransparency = 1

UIGridLayout.Parent = RightPanel
UIGridLayout.CellSize = UDim2.new(0, 245, 0, 80); UIGridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SearchFrame = Instance.new("Frame", MainFrame)
SearchFrame.Size = UDim2.new(0, 530, 0, 60); SearchFrame.Position = UDim2.new(0.32, 0, 0.25, 0)
SearchFrame.BackgroundTransparency = 1; SearchFrame.Visible = false

local SearchInput = Instance.new("TextBox", SearchFrame)
SearchInput.Size = UDim2.new(0.95, 0, 0, 50); SearchInput.PlaceholderText = "🔍 ابحث عن اليوزر هنا..."; SearchInput.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
SearchInput.TextColor3 = Color3.new(1, 1, 1); SearchInput.Font = Enum.Font.GothamBold; SearchInput.TextSize = 18
Instance.new("UICorner", SearchInput).CornerRadius = UDim.new(0, 12)

--- [ دالة الإرسال الذكية ] ---
local function send(txt)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteFunction") and v.Name == "RemoteFunction" then
            local isProtected = false
            for _, p in pairs(game.Players:GetPlayers()) do
                -- حماية إيفنتوري وشخصية أي لاعب محمي أو أنت
                if v:IsDescendantOf(p.Backpack) or (p.Character and v:IsDescendantOf(p.Character)) then
                    if p == player or ProtectedPlayers[p.UserId] or v:IsDescendantOf(p.Backpack) then
                        isProtected = true; break
                    end
                end
            end
            if not isProtected then
                task.spawn(function() pcall(function() v:InvokeServer(txt) end) end)
            end
        end
    end
end

local function updateList(filter)
    for _, v in pairs(RightPanel:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    filter = filter:lower()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower():find(filter) or p.DisplayName:lower():find(filter) then
            local card = Instance.new("Frame", RightPanel)
            card.BackgroundColor3 = ProtectedPlayers[p.UserId] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 0, 0)
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
            local img = Instance.new("ImageLabel", card)
            img.Size = UDim2.new(0, 60, 0, 60); img.Position = UDim2.new(0.05, 0, 0.12, 0)
            img.Image = PlayerIcons[p.UserId] or "rbxassetid://0"
            Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
            local btn = Instance.new("TextButton", card)
            btn.Size = UDim2.new(0.6, 0, 1, 0); btn.Position = UDim2.new(0.35, 0, 0, 0); btn.BackgroundTransparency = 1
            btn.Text = p.DisplayName; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextScaled = true
            btn.MouseButton1Click:Connect(function()
                ProtectedPlayers[p.UserId] = not ProtectedPlayers[p.UserId]
                card.BackgroundColor3 = ProtectedPlayers[p.UserId] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 0, 0)
            end)
        end
    end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function() updateList(SearchInput.Text) end)

local function createActionBtn(name, color, func)
    local btn = Instance.new("TextButton")
    btn.Text = name; btn.BackgroundColor3 = color; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 200, 0) or color
        task.spawn(function() func(active) end)
    end)
    return btn
end

local function clear()
    SearchFrame.Visible = false; RightPanel.Position = UDim2.new(0.32, 0, 0.25, 0); RightPanel.Size = UDim2.new(0, 530, 0, 440)
    for _, v in pairs(RightPanel:GetChildren()) do if not v:IsA("UIGridLayout") then v:Destroy() end end
end

local function createTab(name, pos, callback)
    local btn = Instance.new("TextButton", LeftPanel)
    btn.Size = UDim2.new(1, 0, 0, 65); btn.Position = UDim2.new(0, 0, 0, (pos-1)*75)
    btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0); btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)
    btn.MouseButton1Click:Connect(function() clear(); callback() end)
end

--- [ الأقسام والأزرار - كاملة ] ---

createTab("اللوحات 📝", 1, function()
    createActionBtn("تغيير النص ✍️", Color3.fromRGB(60,0,0), function() send(TextBox.Text) end).Parent = RightPanel
    createActionBtn("تكرار النص 🔄", Color3.fromRGB(60,0,0), function(s) _G.lp=s while _G.lp do send(TextBox.Text) task.wait(1) end end).Parent = RightPanel
    createActionBtn("مسح اللوحات ✨", Color3.fromRGB(50,50,50), function() send("\160") end).Parent = RightPanel
    createActionBtn("تخطي التشفير 🛠️", Color3.fromRGB(60,60,0), function() 
        local t="" for i=1,#TextBox.Text do t=t..TextBox.Text:sub(i,i).." ." end send(t) 
    end).Parent = RightPanel
    createActionBtn("نص طولي ⬆️", Color3.fromRGB(0,100,100), function() 
        local t="" for i=1,#TextBox.Text do t=t..TextBox.Text:sub(i,i).."\n" end send(t) 
    end).Parent = RightPanel
    createActionBtn("فلاش 💡", Color3.fromRGB(150,150,150), function(s) 
        _G.fl=s while _G.fl do send("---") task.wait(0.3) send(TextBox.Text) task.wait(0.3) end 
    end).Parent = RightPanel
end)

createTab("الاعفاء 🔚", 2, function()
    SearchFrame.Visible = true; RightPanel.Position = UDim2.new(0.32, 0, 0.36, 0); RightPanel.Size = UDim2.new(0, 530, 0, 370)
    updateList("")
end)

createTab("اللاق 💥", 3, function()
    createActionBtn("تجميد السيرفر ❄️", Color3.fromRGB(0,100,200), function(s) _G.fr=s while _G.fr do send("SERVER FROZEN") task.wait(0.01) end end).Parent = RightPanel
    createActionBtn("انفجار اللاق 💣", Color3.fromRGB(200,0,0), function(s) _G.l2=s while _G.l2 do send(string.rep("█", 30000)) task.wait(0.05) end end).Parent = RightPanel
    createActionBtn("لاق الرسائل 📧", Color3.fromRGB(100,0,0), function(s) _G.l3=s while _G.l3 do send("LAG LAG LAG") task.wait(0.01) end end).Parent = RightPanel
    createActionBtn("لاق قوي 🔥", Color3.fromRGB(80,0,0), function(s) _G.l4=s while _G.l4 do send("░░░░░░░") task.wait(0.01) end end).Parent = RightPanel
end)

createTab("السيطرة 🛡️", 4, function()
    createActionBtn("إعلان رسمي", Color3.fromRGB(40,40,40), function() send("إعلان: يرجى الالتزام بالقوانين") end).Parent = RightPanel
    createActionBtn("تنبيه أمني ⚠️", Color3.fromRGB(150,100,0), function() send("SECURITY BREACH!") end).Parent = RightPanel
    createActionBtn("اختراق الإدارة", Color3.fromRGB(30,30,30), function() send("ADMIN ACCESS GRANTED") end).Parent = RightPanel
    createActionBtn("سيطرة كاملة 👑", Color3.fromRGB(20,20,20), function() send("SERVER CONTROLLED BY MSMSM") end).Parent = RightPanel
end)

createTab("إسلاميات ✨", 5, function()
    createActionBtn("ذكر الله ✨", Color3.fromRGB(0,120,120), function() send("سبحان الله وبحمده") end).Parent = RightPanel
    createActionBtn("صلّ على النبي", Color3.fromRGB(0,100,100), function() send("اللهم صلّ على محمد") end).Parent = RightPanel
    createActionBtn("استغفر الله", Color3.fromRGB(0,80,80), function() send("أستغفر الله العظيم") end).Parent = RightPanel
    createActionBtn("الحمد لله", Color3.fromRGB(0,150,150), function() send("الحمد لله رب العالمين") end).Parent = RightPanel
end)
