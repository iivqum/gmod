local script=include("script.lua")

local scripts={}

function LoadScript(id,scr)
	assert(scripts[id]==nil,"LoadScript")
	print("loaded script "..id)
	scr:halt()
	scr:reset()
	scripts[id]=scr
end

function RunScript(id)
	local scr=scripts[id]
	assert(scr,"RunScript")
	scr:run()
end

hook.Add("Think","script_run",function()
	for k,scr in pairs(scripts) do
		if not scr.halted then
			local waiting=scr.time>CurTime()
			if not waiting then
				local evt=scr:currentEvent()
				if evt~=nil then
					local handle=script.getHandle(evt.event)
					scr:popEvent()
					if handle~=nil then
						handle(scr,evt.args)
					end
				else
					scr:reset()
					scr:halt()
				end
			end
		end
	end
end)

if SERVER then
util.AddNetworkString("run_script")

local pl_mt=FindMetaTable("Player")
	
function pl_mt:runScript(id)
	net.Start("run_script")
	net.WriteString(id)
	net.Send(self)
end
else
net.Receive("run_script",function()
	local id=net.ReadString()
	if scripts[id] then
		RunScript(id)
	else
		MsgN("run_script bad id "..id)
	end
end)
end