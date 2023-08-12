AddCSLuaFile("flexaddon/spline.lua")
AddCSLuaFile("flexaddon/graph.lua")
AddCSLuaFile("flexaddon/animator.lua")
AddCSLuaFile("flexaddon/file.lua")

if SERVER then return end

include("flexaddon/graph.lua")
include("flexaddon/file.lua")

local function open_ui()

local flex_ui={}

flex_ui.animator=create_animator("myanimation")

local dropdown_color=Color(120,120,120)
local timeline_color=Color(102,255,102)
local color_red=Color(255,51,51)
local color_darkgray=Color(61,61,61)
local background_color=Color(220,220,220)

flex_ui.window=vgui.Create("DFrame")
flex_ui.window:SetSize(ScrW()*0.7,ScrH()*0.7)
flex_ui.window:SetSizable(false)
flex_ui.window:SetTitle(flex_ui.animator.name) 
flex_ui.window:SetVisible(true) 
flex_ui.window:SetDraggable(true) 
flex_ui.window:ShowCloseButton(true) 
flex_ui.window:MakePopup()
flex_ui.window:Center()

function flex_ui.window:OnKeyCodePressed(code)
	if code~=KEY_SPACE then return end
	flex_ui.timeline.paused=not flex_ui.timeline.paused and true or false
end

flex_ui.main_contents=vgui.Create("DPanel",flex_ui.window)
flex_ui.main_contents:Dock(FILL)

flex_ui.optional_bar=vgui.Create("DMenuBar",flex_ui.window)
flex_ui.optional_bar:SetHeight(flex_ui.window:GetTall()*0.03)

local opt1=flex_ui.optional_bar:AddMenu("File")
opt1:AddOption("Open", function() 
	local body=vgui.Create("DFrame")
	body:SetSize(ScrW()*0.2,ScrH()*0.2)
	body:SetSizable(false)
	body:SetTitle("Select animation") 
	body:SetVisible(true) 
	body:SetDraggable(true) 
	body:ShowCloseButton(true) 
	body:MakePopup()
	body:Center()
	body:SetParent(flex_ui.window)
	
	local browser=vgui.Create("DFileBrowser",body)
	browser:Dock(FILL)
	browser:SetPath("DATA")
	browser:SetBaseFolder(FLEX_ANIMATION_BASEFOLDER)
	browser:SetOpen(true)
	browser:SetCurrentFolder(FLEX_ANIMATION_BASEFOLDER)
	
	function browser:OnDoubleClick(path,panel)
		local name=string.GetFileFromFilename(path)
		name=string.sub(name,0,#name-4)
		local anim=open_animation_file(name)
		if not anim then return end
		flex_ui.animator=anim
		flex_ui.list:GetCanvas():Clear()
		flex_ui.build_flex_table()
		body:Close()
		flex_ui.window:SetTitle(flex_ui.animator.name)
	end
end):SetIcon("icon16/page_white_go.png")
opt1:AddOption("Save", function()
	local body=vgui.Create("DFrame")
	body:SetSize(ScrW()*0.1,ScrH()*0.1)
	body:SetSizable(false)
	body:SetTitle("Save animation") 
	body:SetVisible(true) 
	body:SetDraggable(true) 
	body:ShowCloseButton(true) 
	body:MakePopup()
	body:Center()
	body:SetParent(flex_ui.window)
	
	local text=vgui.Create("DTextEntry",body)
	text:SetWidth(body:GetWide()*0.8)
	text:Center()
	text:SetText(flex_ui.animator.name)

	local button=vgui.Create("DButton",body)
	button:Center()
	button:SetY(body:GetTall()*0.7)
	button:SetText("SAVE")
	
	function button:DoClick()
		local name=text:GetValue()
		if string.match(name,"[\\/:\"*?<>|]+") then return end
		flex_ui.animator.name=text:GetValue()
		save_animation_file(flex_ui.animator)
		body:Close()
		flex_ui.window:SetTitle(flex_ui.animator.name)
	end
end):SetIcon("icon16/page_white_go.png")

local opt2=flex_ui.optional_bar:AddMenu("Edit")
opt2:AddOption("Change model", function()
	local body=vgui.Create("DFrame")
	body:SetSize(ScrW()*0.45,ScrH()*0.45)
	body:SetSizable(false)
	body:SetTitle("Save animation") 
	body:SetVisible(true) 
	body:SetDraggable(true) 
	body:ShowCloseButton(true) 
	body:MakePopup()
	body:Center()
	body:SetParent(flex_ui.window)
	
	local browser=vgui.Create("DFileBrowser",body)
	browser:SetModels(true)
	browser:SetOpen(true)
	browser:SetFileTypes("*.mdl")
	browser:Dock(FILL)
	browser:SetPath("GAME")
	browser:SetBaseFolder("models")
	
	function browser:OnDoubleClick(path,panel)
		local oldmodel=flex_ui.face:GetModel()
		flex_ui.face:SetModel(path)
		if flex_ui.face:GetEntity():GetFlexNum()==0 then
			flex_ui.face:SetModel(oldmodel)
			return
		end
		flex_ui.build_flex_table()
	end	
end):SetIcon("icon16/page_white_go.png")

flex_ui.left_panel=vgui.Create("DPanel",flex_ui.main_contents)
flex_ui.left_panel:SetWidth(flex_ui.window:GetWide()*0.2)
flex_ui.left_panel:Dock(LEFT)

flex_ui.list=vgui.Create("DScrollPanel",flex_ui.main_contents)
flex_ui.list:Dock(FILL)
flex_ui.list.splines={}

function flex_ui.list:PaintOver(w,h)
	local x=self:GetX()
	local y=self:GetY()
	surface.SetDrawColor(255,0,0)
	local fraction=flex_ui.animator:get_fraction()
	surface.DrawLine(fraction*w-1,0,fraction*w-1,h)
end

flex_ui.timeline=vgui.Create("DPanel",flex_ui.main_contents)
flex_ui.timeline:SetHeight(flex_ui.window:GetTall()*0.05)
flex_ui.timeline:Dock(TOP)
flex_ui.timeline:DockPadding(10,10,10,10)
flex_ui.timeline.timer_font="HDRDemoText"

function flex_ui.timeline:Paint(w,h)
	local fraction=flex_ui.animator:get_fraction()
	local progress=flex_ui.animator:get_progress()
	draw.RoundedBox(0,0,0,w,h,background_color)
	draw.RoundedBox(0,0,5,w,h-10,dropdown_color)
	draw.RoundedBox(0,0,5,w*fraction,h-10,color_darkgray)
	draw.DrawText(math.Truncate(progress,2),self.timer_font,w*0.5,draw.GetFontHeight(self.timer_font)*0.5,color_white,TEXT_ALIGN_CENTER)
	if not self.paused then 
		flex_ui.animator:update_time(FrameTime())
	end
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
flex_ui.face:SetModel("models/Humans/Group02/male_02.mdl")
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

flex_ui.hints=vgui.Create("DPanel",flex_ui.left_panel)
flex_ui.hints:SetHeight(flex_ui.window:GetTall()*0.4)
flex_ui.hints:DockPadding(10,10,10,10)
flex_ui.hints:Dock(BOTTOM)
flex_ui.hints.help={
	"SPACEBAR to pause the timeline",
	"CNTL + left click to add control points",
	"Right click to remove control points",
	"Click and drag points to change their amplitude",
	"Use scrollwheel to zoom on graph"
}

for i=1,#flex_ui.hints.help do
	local label=vgui.Create("DLabel",flex_ui.hints)
	label:SetFont("Default")
	label:SetColor(color_black)
	label:SetText(flex_ui.hints.help[i])

	label:Dock(TOP)
end

function flex_ui.hints:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,background_color)
end

function flex_ui.build_flex_table()
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
		
		if flex_ui.animator:has_flex(name) then
			spline:use_spline(flex_ui.animator:get_flex_curve(name))
		else
			flex_ui.animator:add_flex_curve(name,spline:get_spline())
		end
		
		if spline:is_edited() then
			collapse:SetExpanded(true)
		end
	end
end

flex_ui.build_flex_table()

end

concommand.Add("flexui",open_ui)