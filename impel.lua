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
local RS = game:GetService("RunService")
local Re = game:GetService("ReplicatedStorage")

-- [[ 1. BYPASS RAYCAST & GEPPO (CHỐNG CHỮ ĐỎ KHI TELE) ]]
local function ZephyrionBypass()
    pcall(function()
        -- Gửi Geppo liên tục để server ghi nhận trạng thái lơ lửng hợp lệ
        if Re:FindFirstChild("Events") and Re.Events:FindFirstChild("Geppo") then
            Re.Events.Geppo:FireServer()
        end
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

-- [[ 2. CƠ CHẾ INSTANT TELEPORT (DỊCH CHUYỂN TỨC THỜI) ]]
local function InstantTP(target, landH)
    local r = lp.Character:FindFirstChild("HumanoidRootPart")
    if not r or not target then return end

    local targetPos = target:GetPivot().Position + Vector3.new(0, landH or 5, 0)
    
    -- Tắt va chạm toàn thân để không bị văng khi xuất hiện trong vật thể
    local f = true
    local nc = RS.Stepped:Connect(function()
        if not f then return end
        r.Velocity = Vector3.new(0,0,0)
        for _, p in pairs(lp.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end)

    -- CƠ CHẾ CHỐNG BAN CỦA ZEPHYRION: Dịch chuyển qua 1 điểm trung gian cực nhanh
    r.Anchored = true
    r.CFrame = CFrame.new(r.Position.X, r.Position.Y + 500, r.Position.Z) -- Điểm đệm trên trời
    ZephyrionBypass()
    task.wait(0.1)
    
    r.CFrame = CFrame.new(targetPos) -- Tele thẳng xuống đích
    task.wait(0.2)
    r.Anchored = false

    -- TỰ ĐỘNG NHẬT TỨC THỜI
    local p = target:FindFirstChildOfClass("ProximityPrompt", true)
    if p then
        p.HoldDuration = 0
        p:InputHoldBegin() task.wait(0.1)
        fireproximityprompt(p)
        p:InputHoldEnd()
    end

    f = false
    nc:Disconnect()
end

-- [[ 3. VÒNG LẶP QUÉT ƯU TIÊN GIỐNG VIDEO ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(0.5) -- Tốc độ quét cực nhanh (0.5 giây)
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            -- Thứ tự ưu tiên: Vera > Key > Chest > Bomb > ImpelGuard
            local t = workspace.NPCs:FindFirstChild("Vera") or workspace.Effects:FindFirstChild("Key")
            if not t then
                for _, v in pairs(workspace:GetDescendants()) do
                    if (tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then
                        t = v break
                    end
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
            
            if t then InstantTP(t, 5) end
        end
    end
end)