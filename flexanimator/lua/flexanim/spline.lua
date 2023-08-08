local function distance2d(p0,p1)
	local dx=p1.x-p0.x
	local dy=p1.y-p0.y
	return math.sqrt(dx^2+dy^2)
end

local function catmull_rom(alpha,tension,p0,p1,p2,p3)
	local t0=0
	local t1=t0+math.pow(distance2d(p0,p1),alpha)
	local t2=t1+math.pow(distance2d(p1,p2),alpha)
	local t3=t2+math.pow(distance2d(p2,p3),alpha)
	
	local m1=(1-tension)*(t2-t1)*((p1-p0)/(t1-t0)-(p2-p0)/(t2-t0)+(p2-p1)/(t2-t1))
	local m2=(1-tension)*(t2-t1) *((p2-p1)/(t2-t1)-(p3-p1)/(t3-t1)+(p3-p2)/(t3-t2))
	
	local a=2*(p1-p2)+m1+m2
	local b=-3*(p1-p2)-m1-m1-m2
	local c=m1
	local d=p1
	
	return a,b,c,d
end

local catmull_rom_spline_mt={
	alpha=0.5,
	tension=0
}
catmull_rom_spline_mt.__index=catmull_rom_spline_mt

function catmull_rom_spline(alpha,tension,ca,cb)
	assert(type(ca)=="Vector","spline: control point not specified")
	assert(type(cb)=="Vector","spline: control point not specified")
	return setmetatable({
		alpha=alpha,
		tension=tension,
		points={},
		segments={},
		--control points which are not drawn
		ca=Vector(),
		cb=Vector(),
		--length of all segments combined
		length=0
	},catmull_rom_spline_mt)
end

function catmull_rom_spline_mt:compute_coefficients(i)
	if not self.segments[i] then return end
	local segment=self.segments[i]
	local p0=self.segments[i-1]
	local p3=self.segments[i+1]
	if not p0 then p0=self.ca else p0=p0.p1.pos end
	if not p3 then p3=self.cb else p3=p3.p2.pos end
	segment.coef={catmull_rom(self.alpha,self.tension,p0,segment.p1.pos,segment.p2.pos,p3)}
end

function catmull_rom_spline_mt:compute_distance(k)
	local segment=self.segments[k]
	if not segment then return end
	local steps=50
	local fraction=1/steps
	local t=0
	local old_point=segment.p1.pos
	local new_point
	local length=0
	for i=1,steps do
		t=t+fraction
		new_point=self:sample(k,t)
		length=length+distance2d(old_point,new_point)
		old_point=new_point
	end
	segment.length=length
	return length
end

function catmull_rom_spline_mt:compute_all()
	local length=0
	for k,v in pairs(self.segments) do
		self:compute_coefficients(k)
		length=length+self:compute_distance(k)
	end
	self.length=length
end

function catmull_rom_spline_mt:get_points()
	return self.points
end

function catmull_rom_spline_mt:get_segments()
	return self.segments
end

function catmull_rom_spline_mt:update_point_indices()
	for i,point in ipairs(self.points) do
		point.index=i
	end
end

function catmull_rom_spline_mt:add_point(x,y)
	local point={pos=Vector(x,y)}
	local index
	--order points by x value
	for i,p in ipairs(self.points) do
		if x<p.pos.x then
			local segment=i-1
			if segment==0 then
				table.insert(self.segments,1,{p1=point,p2=p})
			else
				self.segments[segment].p2=point
				table.insert(self.segments,i,{p1=point,p2=p})
			end
			self:compute_all()
			table.insert(self.points,i,point)
			--performance improvement: only have to update indices after i
			self:update_point_indices()
			return
		end
	end
	index=index or table.insert(self.points,point)
	point.index=index
	if index>1 then
		table.insert(self.segments,{p1=self.points[index-1],p2=point})
	end
	self:compute_all()
	return point
end

function catmull_rom_spline_mt:remove_point(i)
	if not self.points[i] then return end
	local segment=i-1
	table.remove(self.points,i)
	if segment==0 then
		table.remove(self.segments,1)
	elseif segment==#self.segments then
		table.remove(self.segments)
	else
		self.segments[segment].p2=self.segments[i].p2
		table.remove(self.segments,i)
	end
	self:update_point_indices()
	self:compute_all()
end

function catmull_rom_spline_mt:get_point(i)
	return self.points[i]
end

function catmull_rom_spline_mt:set_point(i,y)
	if not self.points[i] or y==nil then return end
	local pos=self.points[i].pos
	pos.y=y
	self:compute_all()
end

function catmull_rom_spline_mt:sample(i,t)
	if not self.segments[i] then return end
	local segment=self.segments[i]
	return segment.coef[1]*t*t*t+segment.coef[2]*t*t+segment.coef[3]*t+segment.coef[4]
end

function catmull_rom_spline_mt:sample_along(t)
	local fraction=self.length*t
	local distance=0
	for k,v in ipairs(self.segments) do
		local check=distance+v.length
		if check>=fraction then
			return self:sample(k,(fraction-distance)/v.length)
		else
			distance=check
		end
	end
	return Vector()
end

function catmull_rom_spline_mt:sample_fofx(d)
	--bsp way
	for k,v in ipairs(self.segments) do
		local pos1=v.p1.pos
		local pos2=v.p2.pos
		if d<=pos2.x and d>=pos1.x then
			local startt=0
			local endt=1
			local pos
			for i=1,10 do
				local delta=(endt-startt)*0.5
				pos=self:sample(k,startt+delta)
				if d<pos.x then
					endt=endt-delta
				elseif d>pos.x then
					startt=startt+delta
				end
			end
			return pos.y
		end
	end	
end