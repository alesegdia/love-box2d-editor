--
--
--  Created by Tilmann Hars
--  Copyright (c) 2014 Headchant. All rights reserved.
--

-- Set Library Folders
LIBRARYPATH = "libs"
LIBRARYPATH = LIBRARYPATH .. "."


-- Get the libs manually
local strict    = require( LIBRARYPATH.."strict"            )
local slam      = require( LIBRARYPATH.."slam"              )
local Gamestate = require( LIBRARYPATH.."hump.gamestate"    )

-- Handle some global variables that strict.lua may (incorrectly, ofcourse) complain about:
class_commons = nil
common = nil
no_game_code = nil
NO_WIDGET   = nil
TILED_LOADER_PATH = nil

SCALE = 2
TILEWIDTH = 32
TILEHEIGHT = 32

-- Creates a proxy via rawset.
-- Credit goes to vrld: https://github.com/vrld/Princess/blob/master/main.lua
-- easier, faster access and caching of resources like images and sound
-- or on demand resource loading
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

-- some standard proxies
Image   = Proxy(function(k) return love.graphics.newImage('img/' .. k .. '.png') end)
Sfx     = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.ogg', 'static') end)
Music   = Proxy(function(k) return love.audio.newSource('music/' .. k .. '.ogg', 'stream') end)

--[[ usage:
    love.graphics.draw(Image.background)
-- or    
    Sfx.explosion:play()
--]]
    
-- require all files in a folder and its subfolders, this way we do not have to require every new file
local function recursiveRequire(folder, tree)
    local tree = tree or {}
    for i,file in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local filename = folder.."/"..file
        if love.filesystem.isDirectory(filename) then
            recursiveRequire(filename)
        elseif file ~= ".DS_Store" then
            require(filename:gsub(".lua",""))
        end
    end
    return tree
end


local function extractFileName(str)
	return string.match(str, "(.-)([^\\/]-%.?([^%.\\/]*))$")
end

-- Initialization
function love.load(arg)
	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest")
	-- love.mouse.setVisible(false)
    -- print "Require Sources:"
	recursiveRequire("src")
	Gamestate.registerEvents()
	Gamestate.switch(Menu)
end

-- Logic
function love.update( dt )
	
end

-- Rendering
function love.draw()

end

-- Input
function love.keypressed()
	
end

function love.keyreleased()
	
end

function love.mousepressed()
	
end

function love.mousereleased()
	
end

function love.joystickpressed()
	
end

function love.joystickreleased()
	
end

io.stdout:setvbuf("no")
