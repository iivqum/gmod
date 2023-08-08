include("flexanim/spline.lua")

local panel={}

panel.point_selector_width=10
panel.point_selector_height=10

local background_color=Color(255,248,215)
local point_color=Color(0,0,255)
local point_color_selected=Color(255,0,0)

local function point_in_rect(p0,p1,w,h)
	local d=Vector(math.abs(p1.x-p0.x),math.abs(p1.y-p0.y))
	return d.x<=w and d.y<=h
end

function panel:Init()
	self.spline=catmull_rom_spline(nil,nil,Vector(-0.1,1),Vector(1.1,1))
	self.spline:add_point(0,1)
	self.spline:add_point(1,1)
	self.pos=Vector()
	self.mouse_is_down=false
	self.t=0
end

function panel:draw_spline(steps,w,h)
	local scale=Vector(w,h)
	for k,v in ipairs(self.spline:get_segments()) do
		--draw.DrawText(v.length, "DermaDefault",v.p2.pos.x*w,v.p2.pos.y*h, color_black, TEXT_ALIGN_CENTER )
		surface.SetDrawColor(0,0,0)
		local t=0
		local fraction=1/steps
		local last
		for i=0,steps do
			local xy=self.spline:sample(k,t)*scale
			if last then
				surface.DrawLine(math.Clamp(last.x,1,w-1),math.Clamp(last.y,1,h-1),math.Clamp(xy.x,1,w-1),math.Clamp(xy.y,1,h-1))
			end
			last=xy
			t=t+fraction
		end
	end
	for i,point in ipairs(self.spline:get_points()) do
		local pos=point.pos*scale
		if i~=1 and i~=#self.spline:get_points() then
			draw.RoundedBox(0,pos.x-0.5*self.point_selector_width,pos.y-0.5*self.point_selector_height,self.point_selector_width,self.point_selector_height,point==self.selected_point and point_color_selected or point_color)
		end
	end
	surface.DrawCircle(self.pos.x*w,self.pos.y*h,10,0,0,0)
end

function panel:sample(t)
	self.t=math.Clamp(t,0,1)
	self.pos=Vector(t,self.spline:sample_fofx(t))
	return self.pos
end

function panel:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,background_color)
	self:draw_spline(24,w,h)
end

function panel:normalized_mouse_pos()
	local x,y=self:ScreenToLocal(gui.MouseX(),gui.MouseY())
	local w,h=self:GetSize()
	return x/w,y/h
end

function panel:Think()
	if self.selected_point==nil or self.spline:get_point(self.selected_point.index)==nil then return end
	if self.mouse_is_down==false then return end
	local n=Vector(self:normalized_mouse_pos())
	local w,h=self:GetSize()
	local scale=Vector(w,h)
	self.spline:set_point(self.selected_point.index,math.Clamp(n.y,0,1))
end

function panel:OnMousePressed(code)
	local n=Vector(self:normalized_mouse_pos())
	if code==MOUSE_LEFT and input.IsKeyDown(KEY_LCONTROL) then
		local id=self.spline:add_point(n.x,n.y)
		self.selected_point=nil
	elseif code==MOUSE_RIGHT and self.selected_point~=nil then
		self.spline:remove_point(self.selected_point.index)
		self.selected_point=nil
	elseif code==MOUSE_LEFT then
		local w,h=self:GetSize()
		local scale=Vector(w,h)
		self.selected_point=nil
		for i,point in ipairs(self.spline:get_points()) do
			if point_in_rect(n*scale,point.pos*scale,self.point_selector_width,self.point_selector_height) then
				if i~=1 and i~=#self.spline:get_points() then
					self.selected_point=point
					break
				end
			end
		end
		self.mouse_is_down=true
	end
end

function panel:OnMouseReleased(code)
	self.mouse_is_down=false
end

vgui.Register("interactive_graph",panel,"DPanel")