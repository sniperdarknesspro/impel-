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
--[[ 
    GPO Script Project
    Phần 1: Khởi tạo Dịch vụ và Biến người chơi
]]
-- Dịch vụ hệ thống
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Thông tin người chơi
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local serverCode = "In20xJeHOC"
-- CÀI ĐẶT TỌA ĐỘ TẠI ĐÂY
local targetPos = Vector3.new(1000, 50, 2000) -- Thay số này bằng tọa độ bạn cần
local speed = 100 -- Tốc độ bay (nên để từ 100-150 để tránh bị kick)


-- [[ CẤU HÌNH ]] --
local TARGET = Vector3.new(1000, 30, 2000) -- Nhập tọa độ đích vào đây
local HEIGHT = 200 -- Độ cao trên trời (đủ cao để né núi)
local SPEED = 2.5 -- Tốc độ bay ngang

local moving = true -- Biến kiểm soát

if root then
    RunService.RenderStepped:Connect(function()
        if not moving then return end
        
        root.Anchored = true -- Khóa nhân vật
        local curPos = root.Position
        local hDist = Vector3.new(TARGET.X - curPos.X, 0, TARGET.Z - curPos.Z).Magnitude

        -- BƯỚC 1: TP LÊN TRỜI (Nếu đang ở thấp)
        if curPos.Y < HEIGHT - 10 and hDist > 5 then
            -- Dịch chuyển tức thời trục Y lên 500 (Xuyên qua trần nhà)
            root.CFrame = CFrame.new(curPos.X, HEIGHT, curPos.Z)
            
        -- BƯỚC 2: BAY NGANG (Nếu chưa tới đích)
        elseif hDist > 5 then
            -- Tính toán vị trí tiếp theo trên trời
            local skyTarget = Vector3.new(TARGET.X, HEIGHT, TARGET.Z)
            local direction = (skyTarget - curPos).Unit
            root.CFrame = root.CFrame + (direction * SPEED)

        -- BƯỚC 3: TP XUỐNG & KẾT THÚC
        else
            root.CFrame = CFrame.new(TARGET) -- Bùm xuống đích
            root.Anchored = false -- Mở khóa
            moving = false -- Tắt script
        end
    end)
end

--[[
-- Tính toán thời gian dựa trên khoảng cách và tốc độ
local distance = (rootPart.Position - targetPos).Magnitude
local duration = distance / speed

local tweenInfo = TweenInfo.new(
    duration, 
    Enum.EasingStyle.Linear, -- Bay đều, không nhanh dần hay chậm dần
    Enum.EasingDirection.Out
)

local targetCFrame = {CFrame = CFrame.new(targetPos)}
local flyTween = TweenService:Create(rootPart, tweenInfo, targetCFrame)

-- Thông báo bắt đầu bay
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "GPO Fly",
    Text = "Đang bay đến tọa độ mục tiêu...",
    Duration = 3
})

flyTween:Play()

-- Khi bay xong sẽ thông báo
flyTween.Completed:Connect(function()
    print("Đã đến nơi!")
end)
]]