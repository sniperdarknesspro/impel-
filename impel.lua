--[[
-- Sử dụng game:HttpGet để tải nội dung từ GitHub về
local success, scriptContent = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/sniperdarknesspro/impel-/main/impel.lua")
end)

if success then
    -- Chuyển chuỗi văn bản thành code có thể chạy được
    local runScript = loadstring(scriptContent)
    runScript() 
    print("Script GPO của bạn đã chạy!")
else
    warn("Không thể kết nối tới GitHub. Kiểm tra lại internet hoặc link!")
end
]]
-- [[ AUTO IMPEL DOWN - FULL BYPASS & PRIORITY COLLECT ]]
-- Thứ tự ưu tiên: Key > Bomb > ImpelGuard > Chest (Rương số)

getgenv().AC = true
local lp = game.Players.LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Re = game:GetService("ReplicatedStorage")

-- [[ 1. HỆ THỐNG BYPASS & GEPPO (CHỐNG PHÁT HIỆN) ]]
task.spawn(function()
    pcall(function()
        -- Xóa ClientMover & Adonis để tránh chữ đỏ (Natalie Wood Logic)
        for _, v in pairs(game:GetDescendants()) do
            if v.Name:lower():match("adonis") or v.Name:match("ClientMover") then v:Destroy() end
        end
        -- Chặn quét Remote từ Server
        local old; old = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(s, ...)
            local a = {...}
            if typeof(a[1]) == "table" and a[1].Mode == "Get" then return nil end
            return old(s, ...)
        end))
    end)
end)

-- Hàm nhảy Geppo ảo để hợp lệ hóa việc ở trên không
local function FakeGeppo()
    pcall(function()
        local g = Re:FindFirstChild("Events") and Re.Events:FindFirstChild("Geppo")
        if g then g:FireServer() end
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

-- [[ 2. HÀM DI CHUYỂN CỐ ĐỊNH TRỤC Y (FIX GIẬT) ]]
local function ElevatorMove(target, landH)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not target then return end

    local flying = true
    local targetLanding = target:GetPivot().Position + Vector3.new(0, landH or 5, 0)
    local skyY = root.Position.Y + 250 -- Nhảy lên 250m từ vị trí hiện tại

    -- Khóa va chạm và triệt tiêu vận tốc (Fix giật)
    local noclip = RS.Stepped:Connect(function()
        if not flying then return end
        root.Velocity = Vector3.new(0, 0, 0) -- Ép vận tốc về 0 để không bị rung
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    -- BƯỚC 1: TELE LÊN CAO
    root.CFrame = CFrame.new(root.Position.X, skyY, root.Position.Z)
    task.wait(0.1)

    -- BƯỚC 2: BAY NGANG CỐ ĐỊNH (FIX GIẬT TUYỆT ĐỐI)
    local skyPoint = Vector3.new(targetLanding.X, skyY, targetLanding.Z)
    local dist = (root.Position - skyPoint).Magnitude
    local tween = TS:Create(root, TweenInfo.new(dist/120, Enum.EasingStyle.Linear), {CFrame = CFrame.new(skyPoint)})
    
    tween:Play()
    -- Chạy Infinity Geppo ngầm để server không báo lỗi
    task.spawn(function()
        while flying and tween.PlaybackState == Enum.PlaybackState.Playing do
            FakeGeppo()
            task.wait(0.3)
        end
    end)
    tween.Completed:Wait()

    -- BƯỚC 3: TELE XUỐNG ĐÍCH
    root.CFrame = CFrame.new(targetLanding)
    task.wait(0.2)

    -- TỰ ĐỘNG NHẶT ĐỒ
    local p = target:FindFirstChildOfClass("ProximityPrompt", true)
    if p then
        p.HoldDuration = 0
        p:InputHoldBegin()
        task.wait(0.1)
        fireproximityprompt(p)
        p:InputHoldEnd()
    end

    flying = false
    noclip:Disconnect()
    -- Auto Skill nổ bom
    pcall(function() Re.Events.Skill:InvokeServer("Explosive Mines") end)
end

-- [[ 3. LOGIC QUÉT ƯU TIÊN ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(1)
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            -- P1: Vera > P2: Key > P3: Chest > P4: Bomb > P5: Guard
            local t = workspace.NPCs:FindFirstChild("Vera") or workspace.Effects:FindFirstChild("Key")
            if not t then
                for _, v in pairs(workspace:GetDescendants()) do
                    if (tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then t = v break end
                end
            end
            if not t then t = workspace.Effects:FindFirstChild("Bomb") end
            if not t then
                local m = math.huge
                for _, v in pairs(workspace.NPCs:GetChildren()) do
                    if v.Name == "ImpelGuard" then
                        local d = (lp.Character.HumanoidRootPart.Position - v:GetPivot().Position).Magnitude
                        if d < m then m = d t = v end
                    end
                end
            end
            if t then ElevatorMove(t, 5) task.wait(1) end
        end
    end
end)