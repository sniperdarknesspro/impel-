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
local RunService = game:GetService("RunService")

-- Thông tin người chơi
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
-- SỬA LỖI: Đặt tên thống nhất là 'root' để khớp với code bên dưới
local root = character:WaitForChild("HumanoidRootPart") 

-- [[ CẤU HÌNH ]] --
-- Bạn chỉ cần chỉnh 3 dòng này thôi
local TARGET = Vector3.new(1000, 30, 2000) -- Nhập tọa độ đích vào đây
local HEIGHT = 400 -- Độ cao an toàn (Nên để 400-500 để chắc chắn qua núi)
local SPEED = 2.5 -- Tốc độ bay ngang (2.5 là ổn định)

-- Biến kiểm soát
local moving = true 

-- Nếu tìm thấy nhân vật thì mới chạy
if root then
    print("Script bắt đầu chạy...") -- In ra để biết script đã nhận
    
    RunService.RenderStepped:Connect(function()
        if not moving then return end
        
        -- Luôn giữ nhân vật không bị rơi
        root.Anchored = true 
        
        local curPos = root.Position
        -- Tính khoảng cách ngang tới đích
        local hDist = Vector3.new(TARGET.X - curPos.X, 0, TARGET.Z - curPos.Z).Magnitude

        -- BƯỚC 1: TP LÊN TRỜI (Nếu đang ở thấp và còn xa đích)
        if curPos.Y < HEIGHT - 10 and hDist > 10 then
            -- Dịch chuyển tức thời lên độ cao an toàn
            root.CFrame = CFrame.new(curPos.X, HEIGHT, curPos.Z)
            
        -- BƯỚC 2: BAY NGANG (Nếu chưa tới đích)
        elseif hDist > 5 then
            -- Tính toán hướng bay
            local skyTarget = Vector3.new(TARGET.X, HEIGHT, TARGET.Z)
            local direction = (skyTarget - curPos).Unit
            
            -- Di chuyển nhân vật
            root.CFrame = root.CFrame + (direction * SPEED)

        -- BƯỚC 3: TP XUỐNG & KẾT THÚC
        else
            root.CFrame = CFrame.new(TARGET) -- Bùm xuống đích
            root.Anchored = false -- Mở khóa nhân vật
            moving = false -- Tắt script
            print("Đã đến nơi!")
        end
    end)
else
    warn("Không tìm thấy nhân vật! Hãy reset và chạy lại.")
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