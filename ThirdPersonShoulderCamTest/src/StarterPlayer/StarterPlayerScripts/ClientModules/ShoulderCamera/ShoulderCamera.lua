-- About: Shoulder Camera Module
-- Creator: Minhnormal

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local ShoulderCamera = {}

function ShoulderCamera:create()
    local newShoulderCamera = setmetatable({
        shoulderCameraRenderStep = nil;
        offsetProfiles = {
            default = Vector3.new(5, 3, -10)
        };
        
        currentOffsetProfile = nil;
        lockMouseCenter = true;
        yAngle = math.rad(-90)
    }, self)

    self.__index = self
    return newShoulderCamera
end


function ShoulderCamera:changeOffsetProfile(offsetProfileName)
    offsetProfileName = offsetProfileName or "default"
    self.currentProfile = self.offsetProfiles[string.lower(offsetProfileName)]
end


function ShoulderCamera:_setupAttributes()
    self.camera = workspace.CurrentCamera
    self.player = Players.LocalPlayer
    self.character = self.player.Character or self.player.CharacterAdded:Wait()
    self.playerHumanoid = self.character:WaitForChild("Humanoid")

    if not self.currentOffset then
        self.currentOffsetProfile = self.offsetProfiles.default
    end
end


function ShoulderCamera:_setupForCamera()
    self.playerHumanoid.AutoRotate = false
    if self.lockMouseCenter then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end


function ShoulderCamera:deactivate()
    if not self.shoulderCameraRenderStep then return end
    if not self.shoulderCameraRenderStep.Disconnect then return end

    self.shoulderCameraRenderStep:Disconnect()
    self.shoulderCameraRenderStep = nil
end


function ShoulderCamera:getYAndZPosition(angle)
    local y = math.cos(angle) * self.yRotationRadius
    local z = math.sin(angle) * self.yRotationRadius
    return y, z
end


function ShoulderCamera:updateCamera()
    local currentOffsetProfile = self.currentOffsetProfile or Vector3.new(0, 0, 0)
    local offsetX = currentOffsetProfile.X
    local offsetY = currentOffsetProfile.Y
    local offsetZ = currentOffsetProfile.Z

    local currentPlayerCharacterCFrame = self.character.PrimaryPart.CFrame
    local offsetPoint = currentPlayerCharacterCFrame
    + currentPlayerCharacterCFrame.RightVector * offsetX
    + currentPlayerCharacterCFrame.UpVector * offsetY

    self.yRotationRadius = offsetZ
    self.fullCircle = math.pi * 2

    local y, z = self:getYAndZPosition(self.yAngle)
    local position = (offsetPoint * CFrame.new(0, y, z)).p
    local lookAt = offsetPoint.Position
    
    self.camera.CFrame = CFrame.new(position, lookAt)
end


function ShoulderCamera:updateYAngle()
    local mouseDeltaY = UserInputService:GetMouseDelta().Y

    -- Limiter Code. Prevents players from rotating their camera overboard
    if self.yAngle - math.rad(mouseDeltaY) > -math.rad(10) then
        return
    elseif self.yAngle - math.rad(mouseDeltaY) < -math.rad(160) then
        return
    end

    self.yAngle -= math.rad(mouseDeltaY)
end


function ShoulderCamera:activate()
    self:_setupAttributes()
    self:_setupForCamera()
    self:deactivate()

    self.shoulderCameraRenderStep = RunService.RenderStepped:Connect(function()
        self:updateYAngle()
        self:updateCamera()
    end)
end

return ShoulderCamera