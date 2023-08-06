AddCSLuaFile("flexanim/spline.lua")
AddCSLuaFile("flexanim/graph.lua")

if SERVER then return end

include("flexanim/graph.lua")

local addsssdddsd

local body=vgui.Create("DFrame")
body:SetPos(5,5) 
body:SetSize(ScrW()*0.7,ScrH()*0.7) 
body:DockPadding(50,50,50,50)
body:SetSizable(true)
body:SetTitle("Name window") 
body:SetVisible(true) 
body:SetDraggable(true) 
body:ShowCloseButton(true) 
body:MakePopup()
body:Center()

local graph=vgui.Create("interactive_graph",body)
graph:Dock(FILL)

local slider=vgui.Create("DNumSlider",body)
slider:SetMax(1)
slider:SetMin(0)
slider:Dock(TOP)

function slider:OnValueChanged(value)
	graph:sample(value)
end
