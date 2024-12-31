--!strict
--[[
	Author: buutterfiies
	MM/DD/YY: 12/30/24
	Description: Path based cutscene system using TweenService.

	TODO:
	Make plugin to create paths
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FastSignal = require(ReplicatedStorage.Packages.Signal)

type cutsceneSystem = {
	Path: Folder,
	Camera: Camera,
	TweenParams: TweenInfo,
	__janitor: typeof(Janitor.new()),
	NodeReached: FastSignal.ScriptSignal,

	new: (camera: Camera?, pathFolder: Folder, TweenParams: TweenInfo?) -> cutsceneSystem,
	Run: (self: cutsceneSystem) -> (),
	SetTweenInfo: (self: cutsceneSystem, newTweenInfo: TweenInfo) -> (),
	Destroy: (self: cutsceneSystem) -> (),
}

local cutsceneSystem = {}
cutsceneSystem.__index = cutsceneSystem

function cutsceneSystem.new(camera: Camera?, pathFolder: Folder, TweenParams: TweenInfo?): cutsceneSystem
	assert(not RunService:IsServer(), "Cutscene system does not work on the server")

	local self = setmetatable({}, cutsceneSystem) :: cutsceneSystem
	self.Path = pathFolder

	if camera == nil and workspace.CurrentCamera ~= nil then
		self.Camera = workspace.CurrentCamera :: Camera
	elseif camera ~= nil then
		self.Camera = camera
	else
		error("Workspace camera and camera do not exist.")
	end

	if TweenParams then
		self.TweenParams = TweenParams
	else
		self.TweenParams = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	end

	self.__janitor = Janitor.new()
	self.NodeReached = FastSignal.new()
	self.__janitor:Add(self.NodeReached, "Destroy")

	return self
end

function cutsceneSystem.Run(self: cutsceneSystem)
	self.__janitor:Add(
		task.spawn(function()
			if self.Camera.CameraType ~= Enum.CameraType.Scriptable then
				repeat
					self.Camera.CameraType = Enum.CameraType.Scriptable
				until self.Camera.CameraType == Enum.CameraType.Scriptable
			end

			for i = 1, #self.Path:GetChildren() do
				local node = self.Path:FindFirstChild(i)

				local waitTime: IntValue = node:FindFirstChild("Wait")
				local Tween = TweenService:Create(self.Camera, self.TweenParams, {
					CFrame = node.CFrame,
				})

				Tween:Play()
				Tween.Completed:Wait()
				self.NodeReached:Fire(i)
				if waitTime then
					task.wait(waitTime.Value)
				end
			end
		end),
		true
	)
end

function cutsceneSystem.SetTweenInfo(self: cutsceneSystem, newTweenInfo: TweenInfo)
	self.TweenParams = newTweenInfo
end

function cutsceneSystem.Destroy(self: cutsceneSystem)
	self.__janitor:Destroy()
	self.Camera.CameraType = Enum.CameraType.Custom
	setmetatable(self, nil)
end

return cutsceneSystem
