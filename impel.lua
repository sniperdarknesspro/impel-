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

getgenv().AC = true -- Đổi thành false để dừng script

local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local lp = game.Players.LocalPlayer
local Re = game:GetService("ReplicatedStorage")

-- ==========================================================
-- PHẦN 1: ANTI-CHEAT BYPASS (Từ Natalie Wood)
-- ==========================================================
task.spawn(function()
    pcall(function()
        -- Xóa Adonis và ClientMover chống bị Kick/Ban
        for _, v in pairs(game:GetDescendants()) do
            if v.Name:lower():match("adonis") or v.Name:match("ClientMover") then 
                v:Destroy() 
            end
        end
    end)
end)

-- Chặn RemoteEvent gửi dữ liệu kiểm tra về Server
task.spawn(function()
    pcall(function()
        local originalFireServer
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            local args = {...}
            if typeof(args[1]) == "table" and args[1].Mode == "Get" then 
                return nil 
            end
            return originalFireServer(self, ...)
        end))
    end)
end)

-- ==========================================================
-- PHẦN 2: HÀM KỸ NĂNG & DI CHUYỂN
-- ==========================================================

-- Tự động tăng Stats và đặt mìn (Explosive Mines)
local function useSkill()
    pcall(function()
        -- Ép Mastery lên 700 để dùng chiêu
        Re.Events.stats:FireServer("DevilFruitMastery", nil, 700)
        
        local container = Re:FindFirstChild(lp.Name .. "|ServerScriptService.Skills.Skills.SkillContainer.Bomb-Bomb.Explosive Mines")
        if container then
            container:InvokeServer({ cf = lp.Character.HumanoidRootPart.CFrame })
        else
            Re.Events.Skill:InvokeServer("Explosive Mines")
        end
    end)
end

-- Hàm thực hiện bay (Tween) và nhặt đồ (ProximityPrompt)
local function goToTarget(target, height)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not target then return end

    -- Bật Noclip (Xuyên tường) khi đang bay
    local flying = true
    local noclipConnection = RS.Stepped:Connect(function()
        if not flying then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    -- Tính toán vị trí bay (đứng trên đầu mục tiêu để an toàn)
    local targetPos = target:GetPivot() * CFrame.new(0, height or 5, 0)
    local distance = (root.Position - targetPos.Position).Magnitude
    
    -- Thực hiện bay với tốc độ 50
    local tween = TS:Create(root, TweenInfo.new(distance / 50, Enum.EasingStyle.Linear), {CFrame = targetPos})
    tween:Play()
    tween.Completed:Wait()

    task.wait(0.4) -- Đợi ổn định vị trí

    -- Thực hiện nhấn giữ nút E để nhặt/mở
    local prompt = target:FindFirstChildOfClass("ProximityPrompt", true)
    if prompt then
        prompt.HoldDuration = 0 -- Ép thời gian giữ về 0
        prompt:InputHoldBegin()
        task.wait(0.2)
        fireproximityprompt(prompt)
        prompt:InputHoldEnd()
    end

    flying = false
    noclipConnection:Disconnect()
    useSkill() -- Đặt mìn sau khi nhặt xong
end

-- ==========================================================
-- PHẦN 3: VÒNG LẶP QUÉT MỤC TIÊU THEO ƯU TIÊN
-- ==========================================================
task.spawn(function()
    while getgenv().AC do
        task.wait(1)
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Quét ưu tiên: Key > Bomb
            local target = workspace.Effects:FindFirstChild("Key") or workspace.Effects:FindFirstChild("Bomb")
            
            -- Nếu không có Key/Bomb, tìm ImpelGuard hoặc Rương gần nhất
            if not target then
                local minDistance = math.huge
                for _, v in pairs(workspace:GetDescendants()) do
                    local isEnemy = (v.Name == "ImpelGuard")
                    local isChest = (tonumber(v.Name) or v.Name:match("Chest"))
                    
                    if (isEnemy or isChest) and v:FindFirstChildOfClass("ProximityPrompt", true) then
                        local dist = (root.Position - v:GetPivot().Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            target = v
                        end
                    end
                end
            end

            -- Nếu tìm thấy mục tiêu, tiến hành bay tới
            if target then
                print("Target Found: " .. target.Name)
                goToTarget(target, 5)
                task.wait(1)
            end
        end
    end
end)