-- About: Use the Module ShoulderCamera.lua
-- Minhnormal

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerScripts = localPlayer.PlayerScripts
local shoulderCameraModules = playerScripts:WaitForChild("ClientModules"):WaitForChild("ShoulderCamera")

local shoulderCamera = require(shoulderCameraModules:WaitForChild("ShoulderCamera")):create()
shoulderCamera:activate()
