AddCSLuaFile("flexanim/spline.lua")
AddCSLuaFile("flexanim/graph.lua")

if SERVER then return end

include("flexanim/graph.lua")

local addsdfdsddsddssss

local flex_ui={}

local dropdown_color=Color(98,98,98)
local timeline_color=Color(102,255,102)

flex_ui.window=vgui.Create("DFrame")
flex_ui.window:SetPos(5,5) 
flex_ui.window:SetSize(ScrW()*0.7,ScrH()*0.7)

flex_ui.window:SetSizable(false)
flex_ui.window:SetTitle("Name window") 
flex_ui.window:SetVisible(true) 
flex_ui.window:SetDraggable(true) 
flex_ui.window:ShowCloseButton(true) 
flex_ui.window:MakePopup()
flex_ui.window:Center()

flex_ui.left_panel=vgui.Create("DPanel",flex_ui.window)
flex_ui.left_panel:SetWidth(flex_ui.window:GetWide()*0.2)
flex_ui.left_panel:Dock(LEFT)

flex_ui.list=vgui.Create("DScrollPanel",flex_ui.window)
flex_ui.list:Dock(FILL)
flex_ui.list.splines={}

function flex_ui.list:PaintOver(w,h)
	local x=self:GetX()
	local y=self:GetY()
	surface.SetDrawColor(255,0,0)
	surface.DrawLine(flex_ui.timeline.progress*w-1,0,flex_ui.timeline.progress*w-1,h)
end

flex_ui.timeline=vgui.Create("DPanel",flex_ui.window)
flex_ui.timeline:SetHeight(flex_ui.window:GetTall()*0.05)
flex_ui.timeline:Dock(TOP)
flex_ui.timeline:DockPadding(10,10,10,10)
flex_ui.timeline.progress=0

function flex_ui.timeline:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,color_white)
	draw.RoundedBox(0,0,5,w*self.progress,h-10,color_black)
	self.progress=self.progress+FrameTime()*0.1
	if self.progress>1 then self.progress=0 end
end

function flex_ui.timeline:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,color_white)
	draw.RoundedBox(0,0,5,w*self.progress,h-10,color_black)
	self.progress=self.progress+FrameTime()
	if self.progress>1 then self.progress=0 end
	for k,v in ipairs(flex_ui.list.splines) do
		flex_ui.face:GetEntity():SetFlexWeight(v.flex,math.Clamp(1-v.spline:sample(self.progress).y,0,1))
		--LocalPlayer():GetEyeTrace().Entity:SetFlexWeight(v.flex,math.Clamp(1-v.spline:sample(self.progress).y,0,1))
	end
end

function flex_ui.timeline:Think(code)
	if not input.IsMouseDown(MOUSE_LEFT) then return end
	local x,y=self:ScreenToLocal(gui.MouseX(),gui.MouseY())
	local w,h=self:GetSize()
	if x<0 or x>w or y<0 or y>h then return end
	local nx=x/w
	self.progress=math.Clamp(nx,0,1)
end

flex_ui.face=vgui.Create("DModelPanel",flex_ui.left_panel)
flex_ui.face:Dock(FILL)
flex_ui.face:SetModel("models/Humans/Group03/male_02.mdl")
flex_ui.face:SetAnimated(false)
flex_ui.face:SetFOV(40)

function flex_ui.face:PreDrawModel(ent)
	cam.Start2D()
	local w,h=self:GetSize()
	draw.RoundedBox(0,0,0,w,h,color_black)
	cam.End2D()
end

function flex_ui.face:LayoutEntity()
	local headpos=self:GetEntity():GetBonePosition(self:GetEntity():LookupBone("ValveBiped.Bip01_Head1"))
	self:SetLookAt(headpos)
	self:SetCamPos(headpos-Vector(-15, 0, 0))
	self:GetEntity():SetEyeTarget(headpos-Vector(-15, 0, 0))
end

flex_ui.left_misc=vgui.Create("DPanel",flex_ui.left_panel)
flex_ui.left_misc:SetHeight(flex_ui.window:GetTall()*0.4)
flex_ui.left_misc:Dock(BOTTOM)

local ent=flex_ui.face:GetEntity()

for i=1,ent:GetFlexNum() do
	local name=ent:GetFlexName(i)

	local collapse=vgui.Create("DCollapsibleCategory",flex_ui.list)
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
	
	table.insert(flex_ui.list.splines,{flex=i,spline=spline})
end