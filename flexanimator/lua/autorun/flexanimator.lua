AddCSLuaFile("flexanim/spline.lua")
AddCSLuaFile("flexanim/graph.lua")

if SERVER then return end

include("flexanim/graph.lua")

local adddddsddddddddddsdsdddsdsdssdsssdsddddsdddd

local dropdown_color=Color(98,98,98)

local body=vgui.Create("DFrame")
body:SetPos(5,5) 
body:SetSize(ScrW()*0.7,ScrH()*0.7) 

body:SetSizable(false)
body:SetTitle("Name window") 
body:SetVisible(true) 
body:SetDraggable(true) 
body:ShowCloseButton(true) 
body:MakePopup()
body:Center()

local left_body=vgui.Create("DPanel",body)
left_body:SetWidth(body:GetWide()*0.2)
left_body:Dock(LEFT)

local curves=vgui.Create("DScrollPanel",body)
curves:Dock(FILL)

local flex_curves={}

--local graph=vgui.Create("interactive_graph",body)
--graph:Dock(FILL)

local slider=vgui.Create("DPanel",body)
slider:SetHeight(body:GetTall()*0.05)
slider:Dock(TOP)

local model_viewer


model_viewer=vgui.Create("DModelPanel",left_body)
model_viewer:Dock(FILL)
model_viewer:SetModel("models/Humans/Group03/male_02.mdl")
model_viewer:SetAnimated(false)
model_viewer:SetFOV(40)

function model_viewer:PreDrawModel(ent)
	cam.Start2D()
	local w,h=self:GetSize()
	draw.RoundedBox(0,0,0,w,h,color_black)
	cam.End2D()
end

function model_viewer:LayoutEntity()
	local headpos=self:GetEntity():GetBonePosition(self:GetEntity():LookupBone("ValveBiped.Bip01_Head1"))
	self:SetLookAt(headpos)
	self:SetCamPos(headpos-Vector(-15, 0, 0))
	self:GetEntity():SetEyeTarget(headpos-Vector(-15, 0, 0))
	
	for k,v in ipairs(flex_curves) do
		self:GetEntity():SetFlexWeight(v.flex,math.Clamp(1-v.spline:sample(1).y,0,1))
	end
end

left_body:InvalidateLayout()

local test=vgui.Create("DPanel",left_body)
test:SetHeight(body:GetTall()*0.4)
test:Dock(BOTTOM)

local ent=model_viewer:GetEntity()

for i=1,ent:GetFlexNum() do
	local name=ent:GetFlexName(i)

	local collapse=vgui.Create("DCollapsibleCategory",curves)
	collapse:Dock(TOP)
	collapse:SetHeight(200)
	collapse:SetExpanded(false)
	collapse:SetLabel(name)
	collapse.test=10
	
	function collapse:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,dropdown_color)
	end
	
	local spline=vgui.Create("interactive_graph")
	spline:Dock(FILL)
	spline:SetHeight(300)
	collapse:SetContents(spline)
	
	table.insert(flex_curves,{flex=i,spline=spline})
end