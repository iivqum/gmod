local script={}

local scr={}
local scr_mt={__index=scr}

local handlers={
	call=function(self,args)
		local func=args[1]
		if #args>1 then
			func(unpack(args,2))
		else
			func()
		end
	end,
	wait=function(self,args)
		self.time=CurTime()+args[1]
	end,
	restart=function(self,args)
		self.event=#self.events
		self.time=0
	end
}

function scr:wait(delay)
	self:pushEvent("wait",delay)
end

function scr:restart()
	self:pushEvent("restart")
end

function scr:halt()
	self.halted=true
end

function scr:call(...)
	self:pushEvent("call",...)
end

function scr:currentEvent()
	return self.events[self.event]
end

function scr:pushEvent(event,...)
	assert(handlers[event],"pushEvent")
	for i=#self.events,1,-1 do
		self.events[i+1]=self.events[i]
	end
	self.events[1]={event=event,args={...}}
end

function scr:popEvent()
	self.event=self.event-1
end

function scr:run()
	self.halted=false
end

function scr:reset()
	self.time=0
	self.event=#self.events
end

local function new()
	return setmetatable({events={},event=0,time=0,halted=true},scr_mt)
end

local function returnHandler(event)
	return handlers[event]
end

script.getHandle=returnHandler

setmetatable(script,{__call=function(t,...)return new(...)end})

return script