local Players = game:GetService("Players")
local player = Players.LocalPlayer
player.CharacterAdded:Wait()
task.wait(2)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CutsceneSystem = require(ReplicatedStorage.Shared.CutsceneSystem)
local cutscene = CutsceneSystem.new(workspace.CurrentCamera, workspace.Path, nil)
cutscene:Run()
cutscene.NodeReached:Connect(print)
