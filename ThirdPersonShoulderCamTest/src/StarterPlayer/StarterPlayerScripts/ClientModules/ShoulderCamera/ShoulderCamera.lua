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
        yAngleRotation = math.rad(-90);
    }, self)

    self.__index = self
    return newShoulderCamera
end


function ShoulderCamera:addOffsetProfile(offsetProfileName, offsetVector3)
    assert(typeof(offsetProfileName) == "string", "Provided offsetProfileName argument needs to be a string. Given argument is a " .. typeof(offsetProfileName))
    assert(typeof(offsetVector3) == "Vector3", "Provided offsetVector3 argument needs to be a Vector3. Given argument is a " .. typeof(offsetVector3))

    self.offsetProfiles[offsetProfileName] = offsetVector3
end


function ShoulderCamera:changeOffsetProfile(offsetProfileName)
    assert(typeof(offsetProfileName) == "string", "offsetProfileName argument needs to be a string. Given argument is a " .. typeof(offsetProfileName))

    -- Making every name to be lower cased. To prevent case sensitive errors
    offsetProfileName = offsetProfileName or "default"
    self.currentProfile = self.offsetProfiles[string.lower(offsetProfileName)] or self.offsetProfiles["default"]
end


function ShoulderCamera:setupAttributes()
    -- This method needs to be recalled when the player dies

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
    assert(type(angle) == "number", "Given argument angle needs to be a number. Given argument is a " .. type(angle))

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

    local y, z = self:getYAndZPosition(self.yAngleRotation)
    local position = (offsetPoint * CFrame.new(0, y, z)).p
    local lookAt = offsetPoint.Position
    
    self.camera.CFrame = CFrame.new(position, lookAt)
end


function ShoulderCamera:updateYAngleRotation()
    local mouseDeltaY = UserInputService:GetMouseDelta().Y

    local newYAngleRotation = self.yAngleRotation - math.rad(mouseDeltaY)

    -- Prevents players from rotating their camera overboard
    -- -10 (limit for the rotating downward) and -160 (limit for rotating downward) are expected to be the good numbers

    local newYAngleRotationWillExceedMaxUpwardRotation = newYAngleRotation > -math.rad(10)
    local newYAngleRotationWillExceedMaxDownwardRotation = newYAngleRotation < -math.rad(160)

    -- limit player from rotating upwards
    if newYAngleRotationWillExceedMaxUpwardRotation then
        return
    -- Limit player from rotating downwards
    elseif newYAngleRotationWillExceedMaxDownwardRotation then
        return
    end

    -- Returning makes it so this statement right here does not have the permission to run
    self.yAngleRotation -= math.rad(mouseDeltaY)
end


function ShoulderCamera:updateCharacterXRotation()
    local mouseDeltaX = UserInputService:GetMouseDelta().X
    -- No idea why but the mouseDeltaX is the equivalent of y on CFrame.Angles
    self.character.PrimaryPart.CFrame *= CFrame.Angles(0, -math.rad(mouseDeltaX), 0)
end


function ShoulderCamera:activate()
    self:setupAttributes()
    self:_setupForCamera()
    self:deactivate()

    self.shoulderCameraRenderStep = RunService.RenderStepped:Connect(function()
        self:updateYAngleRotation()
        self:updateCharacterXRotation()
        self:updateCamera()
    end)

    self.player.CharacterAdded:Connect(self.setupAttributes)
end

return ShoulderCamera