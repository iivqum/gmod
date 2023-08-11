AddCSLuaFile("flexanim/spline.lua")
AddCSLuaFile("flexanim/graph.lua")
AddCSLuaFile("flexanim/animator.lua")
AddCSLuaFile("flexanim/file.lua")

if SERVER then return end

include("flexanim/graph.lua")

local addsddfdddsdddssdsddddsssdSdddddddssssssdsdss

local flex_ui={}

flex_ui.animator=create_animator("")

local dropdown_color=Color(98,98,98)
local timeline_color=Color(102,255,102)
local color_red=Color(255,51,51)
local background_color=Color(230,230,230)

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
	local fraction=flex_ui.animator:get_fraction()
	surface.DrawLine(fraction*w-1,0,fraction*w-1,h)
end

flex_ui.timeline=vgui.Create("DPanel",flex_ui.window)
flex_ui.timeline:SetHeight(flex_ui.window:GetTall()*0.05)
flex_ui.timeline:Dock(TOP)
flex_ui.timeline:DockPadding(10,10,10,10)
flex_ui.timeline.timer_font="Trebuchet24"

function flex_ui.timeline:Paint(w,h)
	local fraction=flex_ui.animator:get_fraction()
	local progress=flex_ui.animator:get_progress()
	draw.RoundedBox(0,0,0,w,h,background_color)
	draw.RoundedBox(0,0,5,w,h-10,dropdown_color)
	draw.RoundedBox(0,0,5,w*fraction,h-10,color_red)
	draw.DrawText(math.Truncate(progress,2),self.timer_font,0,draw.GetFontHeight(self.timer_font)*0.5,color_white,TEXT_ALIGN_LEFT)
	flex_ui.animator:update_time(FrameTime())
	flex_ui.animator:update_flexes()
end

function flex_ui.timeline:Think(code)
	if not input.IsMouseDown(MOUSE_LEFT) then return end
	local x,y=self:ScreenToLocal(gui.MouseX(),gui.MouseY())
	local w,h=self:GetSize()
	if x<0 or x>w or y<0 or y>h then return end
	local nx=x/w
	local progress=math.Clamp(nx*flex_ui.animator:get_length(),0,flex_ui.animator:get_length())
	flex_ui.animator:set_progress(progress)
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
	flex_ui.animator:attach_entity(self:GetEntity())
end

flex_ui.left_misc=vgui.Create("DPanel",flex_ui.left_panel)
flex_ui.left_misc:SetHeight(flex_ui.window:GetTall()*0.4)
flex_ui.left_misc:Dock(BOTTOM)

flex_ui.blah=vgui.Create("DPanel",flex_ui.window)
flex_ui.blah:SetHeight(flex_ui.window:GetTall()*0.2)
flex_ui.blah:Dock(BOTTOM)

function flex_ui.left_misc:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,background_color)
end

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
		if not self.spline or not self.spline:is_edited() then return end
		local barw=w*0.1
		draw.RoundedBox(4,w-barw,0,barw,h,color_red)
	end
	
	local spline=vgui.Create("interactive_graph")
	spline:Dock(FILL)
	spline:SetHeight(300)
	collapse:SetContents(spline)
	
	collapse.spline=spline
	
	flex_ui.animator:add_flex_curve(name,spline:get_spline())
end
file.CreateDir("flexanim")
file.Open("flexanim/test.json","w","DATA")