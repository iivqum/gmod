local script=include("script.lua")
local camera=include("camera.lua")

local loader=script()

loader:call(function()
local trans_room_1=script()
local trans_room_2=script()
local trans_room_3=script()
local trans_room_4=script()
local trans_room_5=script()

local cam_room_1=camera.initializeFromEntity("cam_room_1")
local cam_room_2=camera.initializeFromEntity("cam_room_2")
local cam_room_3=camera.initializeFromEntity("cam_room_3")
local cam_room_4=camera.initializeFromEntity("cam_room_4")
local cam_room_5=camera.initializeFromEntity("cam_room_5")

trans_room_1:call(function()Entity(1):setCamera(cam_room_1)end)
trans_room_2:call(function()Entity(1):setCamera(cam_room_2)end)
trans_room_3:call(function()Entity(1):setCamera(cam_room_3)end)
trans_room_4:call(function()Entity(1):setCamera(cam_room_4)end)
trans_room_5:call(function()Entity(1):setCamera(cam_room_5)end)

LoadScript("trans_room_1",trans_room_1)
LoadScript("trans_room_2",trans_room_2)
LoadScript("trans_room_3",trans_room_3)
LoadScript("trans_room_4",trans_room_4)
LoadScript("trans_room_5",trans_room_5)
end)

LoadScript("loader",loader)