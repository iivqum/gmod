AddCSLuaFile("camera.lua")
AddCSLuaFile("script.lua")
AddCSLuaFile("script_run.lua")
AddCSLuaFile("player_camera.lua")
AddCSLuaFile("shared.lua")

include("script_run.lua")
include("transitions.lua")
include("shared.lua")

local script=include("script.lua")
local mt=FindMetaTable("Entity")

hook.Add("InitPostEntity","init",function()
local scareme=script()
scareme:call(function()
	Entity(1):EmitSound("ambient/levels/streetwar/city_chant1.wav")
end)
scareme:wait(8)
scareme:restart()
LoadScript("scareme",scareme)
end)