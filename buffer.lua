local lib={}
local colourLookup={}

for k,v in pairs(colours) do
	colourLookup[v]=k
end

lib.New=function(posx,posy)
	local n={} --new instance
	local c={} --new instance's content

	local w,h=1,1 --width, height
	local x,y=1,1 --cursor position
	local bc,tc=1,2 --background and text colour
	local b,coloured=true,true --blink, advanced display
	local scroll=0 --scroll modifier

	--prepare the content table
	for _y=1,h do
		c[_y]={}
		for _x=1,w do
			c[_y][_x]={bc,tc," "}
		end
	end

	n.setCursorPos=function(a,b)
		if type(a)~="number" or type(b)~="number" then error("Expected number, number",2) end
		x,y=a,b
	end

	n.write=function(txt)
		if x<=w then
			txt=tostring(txt)
			for i=1,#txt do
				if c[y] then
					c[y][x+i-1]={bc,tc,txt:sub(i,i)}
					if x+i-1==w then break end
				end
			end
			x=x+#txt
		end
	end

	n.setBackgroundColour=function(c)
		c=tonumber(c)
		if not c or not colourLookup[c] then error("Invalid coulour!",2) end
		bc=c
	end

	n.setTextColour=function(c)--TODO join these
		c=tonumber(c)
		if not c or not colourLookup[c] then error("Invalid coulour!",2) end
		tc=c
	end

	n.clearLine=function()
		x=1
		return n.write(string.rep(" ",w))
	end

	n.clear=function()
		for i=1,h do
			y=i
			n.clearLine()
		end
	end

	n.setCursorBlink=function(x)
		if type(x)~="bool" then error("Expected boolean, got "..type(x),2) end
		b=x
	end

	n.scroll=function(n)
		if not tonumber(n) then error("Expected number, got "..type(n),2) end
		scroll=scroll+n
		for _y=1,h+scroll do
			c[_y]=c[_y] or {}
			for _x=1,w do
				c[_y][_x]=c[_y][_x] or {bc,tc," "}
				print("Pixel @ ".._y.."x".._x.." set.")
				--if _y>h-2 then sleep(0)end
			end
		end
		print(scroll)
		print"Scrolling complete"
		--sleep(1)
	end

	n.getSize=function()
		return w,h
	end

	n.getCursorPos=function()
		return x,y
	end

	n.isColour=function()
		return coloured
	end

	n.setCursorPosRelative=function(_x,_y)
		x=_x-posx+1
		y=_y-posy+1+scroll
	end

	n.Draw=function()
		--DEBUG
			local f=fs.open("/CleanCode/content","w")
			f.write(textutils.serialize(c))
			f.close()
		--/DEBUG
		--[[for _y,row in ipairs(c) do
			for _x,px in ipairs(row) do
				if _x<=w and _y-scroll<=h then
					term.setCursorPos(posx+_x-1,posy+_y-1)
					term.setBackgroundColour(px[1])
					term.setTextColour(px[2])
					term.write(px[3])
				end
			end
		end]]
		for _y=1,#c do
			for _x=1,(c[_y+scroll] and #c[_y+scroll] or 0) do
				if _x<=w and _y-scroll<=h then
					local px=c[_y+scroll][_x]
					term.setCursorPos(posx+_x-1,posy+_y-1)
					term.setBackgroundColour(px[1])
					term.setTextColour(px[2])
					term.write(px[3])
				end
			end
		end
	end

	n.Reposition=function(x,y)
		posx,posy=x,y
	end

	n.Resize=function(_w,_h)
		w,h=_w,_h
		for _y=1,h do
			c[_y]=c[_y] or {}
			for _x=1,w do
				c[_y][_x]=c[_y][_x] or {bc,tc," "}
				print("Pixel @ ".._y.."x".._x.." set.")
				--if _y>h-2 then sleep(0)end
			end
		end
		print"Resizing complete"
		--sleep(1)
	end

	--symlinks :P
	n.isColor=n.isColour
	n.setTextColor=n.setTextColour
	n.setBackgroundColor=n.setBackgroundColour

	return n
end

_G.Buffer=lib