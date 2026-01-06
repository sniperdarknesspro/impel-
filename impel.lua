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
local Re = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

-- [[ 1. HÀM BYPASS GEPPO (QUAN TRỌNG NHẤT) ]]
-- Phải gửi gói tin Geppo liên tục để server tin rằng bạn đang nhảy nên mới cách sàn xa
local function GeppoBypass()
    pcall(function()
        if Re:FindFirstChild("Events") and Re.Events:FindFirstChild("Geppo") then
            Re.Events.Geppo:FireServer()
        end
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

-- [[ 2. CƠ CHẾ DỊCH CHUYỂN TỨC THỜI (INSTANT TP) ]]
local function ZephyrionTeleport(targetPos)
    local r = lp.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end

    -- Tắt va chạm để không bị văng khi xuất hiện trong vật thể
    local nc = RS.Stepped:Connect(function()
        for _, p in pairs(lp.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end)

    -- ĐÓNG BĂNG NHÂN VẬT -> DỊCH CHUYỂN -> GIẢI PHÓNG
    r.Anchored = true
    GeppoBypass() -- Gửi Geppo ngay trước khi Tele
    task.wait(0.05)
    
    r.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0)) -- Đáp trên đầu 5m
    task.wait(0.15) -- Đợi server cập nhật vị trí
    
    r.Anchored = false
    nc:Disconnect()
end

-- [[ 3. VÒNG LẶP THỰC THI (CHỈ TELE) ]]
task.spawn(function()
    while getgenv().AC do
        task.wait(0.8) -- Delay thấp để Tele liên tục
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            -- Quét mục tiêu ưu tiên: Vera > Key > Chest > Bomb > Guard
            local target = workspace.NPCs:FindFirstChild("Vera") or workspace.Effects:FindFirstChild("Key")
            if not target then
                for _, v in pairs(workspace:GetDescendants()) do
                    if (tonumber(v.Name) or v.Name:match("Chest")) and v:FindFirstChildOfClass("ProximityPrompt", true) then
                        target = v break
                    end
                end
            end
            
            if target then
                print("Instant Teleport to: " .. target.Name)
                ZephyrionTeleport(target:GetPivot().Position)
                
                -- Tự động nhặt ngay khi vừa tới
                local p = target:FindFirstChildOfClass("ProximityPrompt", true)
                if p then
                    p.HoldDuration = 0
                    fireproximityprompt(p)
                end
            end
        end
    end
end)