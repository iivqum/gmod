AddCSLuaFile("flexanim/spline.lua")
AddCSLuaFile("flexanim/graph.lua")

if SERVER then return end

include("flexanim/graph.lua")

local adddddsddssdsddddddsddsddddddsdsdddsdsdssdsssdsddddsdddd

local dropdown_color=Color(98,98,98)
local timeline_color=Color(102,255,102)

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
slider:DockPadding(10,10,10,10)
slider.progress=0

local model_viewer

function slider:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,color_white)
	draw.RoundedBox(0,0,5,w*self.progress,h-10,color_black)
	self.progress=self.progress+FrameTime()*0.1
	if self.progress>1 then self.progress=0 end
	
	for k,v in ipairs(flex_curves) do
		model_viewer:GetEntity():SetFlexWeight(v.flex,math.Clamp(1-v.spline:sample(self.progress).y,0,1))
	end
end

function slider:Think(code)
	if not input.IsMouseDown(MOUSE_LEFT) then return end
	local x,y=self:ScreenToLocal(gui.MouseX(),gui.MouseY())
	local w,h=self:GetSize()
	local nx=x/w
	self.progress=nx
end

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