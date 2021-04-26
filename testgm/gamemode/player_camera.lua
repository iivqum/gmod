local camera=include("camera.lua")

if SERVER then
	util.AddNetworkString("camera_set")
	
	local pl_mt=FindMetaTable("Player")
	
	function pl_mt:setCamera(cam)
		print("sent")
		net.Start("camera_set")
		net.WriteVector(cam.p)
		net.WriteAngle(cam.a)
		net.WriteInt(cam.fov,8)
		net.Send(self)
	end
else
local cam=camera()

hook.Add("CalcView","view_calc",function(ply,pos)
    local view = {}
    view.origin = cam.p
    view.angles = cam.a
    view.fov = cam.fov
	view.drawviewer=true
 
    return view
end)

net.Receive("camera_set",function()
	local pos=net.ReadVector()
	local ang=net.ReadAngle()
	local fov=net.ReadInt(8)
	cam.p=pos
	cam.a=ang
	cam.fov=fov
	print(pos,ang,fov)
end)
end