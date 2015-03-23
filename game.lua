local args = {...}

local levels,level,load,s,saveLevel,saveGame,loadLevel,sw=unpack(args)

local description=true --false when closed
local MenuState="Editor"

--why Lua, why? ;(
local menu={}


--[[
local f=fs.open("/CleanCode/args","w")
f.write(Debug.Serialize(args))
f.close()]]


--local c={colours.black,colours.grey,colours.lightGrey,colours.white}
term.setBackgroundColour(colours.black)
term.clear()
term.setBackgroundColour(colours.grey)


local function s()
	os.queueEvent"QuickSleep"
	return coroutine.yield"QuickSleep"
end

local w,h=term.getSize()

local length=5
--[[
	for x=w,-length*2,-4 do
		for y=1,h do
			local len=length
			

			for i=0,w-length do
				if i%len==0 then
					term.setCursorPos(x+i+(y%2),y)
					term.write(" ")
					if i>length*2 then
						break
					end
					if len>1 then
						len=len-1
					end
				end
			end
		end
		sleep(0)
	end
]]

term.setCursorPos(1,1)


local function wrap(text, maxWidth)
	local lines = {''}
	for word, space in text:gmatch('(%S+)(%s*)') do
		local temp = lines[#lines] .. word .. space:gsub('\n','')
		if #temp > maxWidth then
				table.insert(lines, '')
		end
		if space:find('\n') then
			lines[#lines] = lines[#lines] .. word

			space = space:gsub('\n', function()
				table.insert(lines, '')
				return ''
			end)
		else
			lines[#lines] = lines[#lines] .. word .. space
		end
	end
	if #lines[1] == 0 then
		table.remove(lines,1)
	end
	return lines
end



local function printgui()
	term.setBackgroundColour(colours.grey)
	term.clear()
	--print level name as title
	term.setCursorPos(4,(description and 3 or 2))
	term.write(levels[level].name)

	--print menu of options (hints, docs, leave etc)
		--calculate how far from right the items should be positioned
		local distance = 0
		for k,v in pairs(menu) do
			distance=distance+#v[1]
		end
		distance=distance+#menu
	term.setCursorPos(w-distance,1)
	term.setBackgroundColour(colours.white)
	
	term.write((" "):rep(w-distance))
	term.setCursorPos(w-distance,1)
	
	term.setTextColour(colours.lightGrey)
	term.write"|"
	term.setTextColour(colours.black)

	for i,v in ipairs(menu) do
		local _x,_y=term.getCursorPos()
		term.write(v[1])
		term.setTextColour(colours.lightGrey)

		term.write"|"

		term.setTextColour(colours.black)
		term.setCursorPos(_x+#v[1]+1,_y)
	end

	--if the description is open
	if description then
		--print description (task) of the level
		--term.setCursorPos(w/2,4)
		term.setBackgroundColour(colours.grey)
		term.setTextColour(colours.lightGrey)

		for i,v in pairs(wrap(levels[level].desc,math.ceil(w/2))) do
			term.setCursorPos(w/2,3+i)
			term.write(v)
		end

		--print "x" button for closing the description
		term.setCursorPos(w-1,3)
		term.setTextColour(colours.red)
		term.write"x"
	else 
		--print "v" button to show the desc.
		term.setCursorPos(w-2,2)
		term.setTextColour(colours.lightGrey)
		term.setBackgroundColour(colours.grey)
		term.write"v"
	end
	--print the placeholder for the editor
	term.setBackgroundColour(colours.white)
	term.setCursorPos(1,1)
	for y=(description and math.ceil(h/2)-1 or 3),h-1 do
		term.setCursorPos(2,y)
		term.write(string.rep(" ",w-2))
	end

	--print the run button
	term.setTextColour(colours.white)
	term.setBackgroundColour(colours.green)
	term.setCursorPos(w-4,h)
	term.write"Run >"

end

local function printHints()
	local oldDesc=description
	description=false
	printgui()

	term.setBackgroundColour(colours.grey)
	for y=3,h do
		term.setCursorPos(1,y)
		term.clearLine()
	end

	description=oldDesc
end

--why Lua? :'(
menu={
	{"Hints",function()printHints()end,},
	{"Documentation",function()end,},
	{"Some button",function()end,}
}


local function RunCode()
	--TODO: add actual execution :D
end

local function main()
	local case={
		mouse_click=function(_,btn,x,y)
			--code
			if MenuState=="Editor" then
				if y==h and x>w-4 then --run button
					return RunCode()
				elseif y>(description and math.ceil(h/2)-1 or 3) and y<h and x>1 and x<w then --code placeholder
					buffer.setCursorPosRelative(x,y) --HUGE TODO: BUFFERING!!!!
					--TODO context menus?
				elseif x==w-1 and y==3 and description then --x button, close desc.
					description=false
					--force reprint
					term.setBackgroundColour(colours.grey)
					term.clear()
					return printgui()
				elseif x==w-2 and y==2 and not description then
					description=true
					--force reprint
					term.setBackgroundColour(colours.grey)
					term.clear()
					return printgui()
				elseif y==1 then --menu
					local distance = 0
					for k,v in pairs(menu) do
						distance=distance+#v[1]
						--print(distance)
					end
					distance=distance+#menu

					--print("final="..distance)

					local length=0
					local i=false
					for k,v in pairs(menu) do
						length=length+#v[1]
						--print(length)
						if length+w-distance>=x then i=k break
						elseif length+w-distance>w then break end
					end
					--print("key is "..tostring(i))
					if i and type(menu[i][2])=="function" then 
						if menu[i][1]=="Hints" then MenuState="Hint" end
						menu[i][2]()
					end
				end
			elseif MenuState=="Hint" then
				if y==1 then
					MenuState="Editor"
					printgui()
				elseif false then

				end
			end
		end,
	}
	while true do
		local ev={os.pullEvent()}
		--printgui()
		if case[ev[1]] then case[ev[1]](unpack(ev)) end
	end
end


printgui()

main()






os.pullEvent"char"
