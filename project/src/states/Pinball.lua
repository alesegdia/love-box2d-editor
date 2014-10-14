--
--  Game
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local timer = require (LIBRARYPATH.."hump.timer")
local tween         = timer.tween

require "src.entities.Stage"
require "src.entities.GameEntity"
require "src.entities.PhysicWorld"

Editor = Gamestate.new()

local center = {
  x = love.graphics.getWidth() / 2,
  y = love.graphics.getHeight() / 2
}

local bigFont   =   love.graphics.newFont(32)
local smallFont =   love.graphics.newFont(16)
local m2pix = 		32
local world =		PhysicWorld( 0, 200, m2pix )
local stage = 		Stage(world)

local beginContact = function(a,b,coll) end
local endContact = function(a,b,coll) end
local preSolve = function(a,b,coll) end
local postSolve = function(a,b,coll,normalimpulse1,tangentimpulse1,normalimpulse2,tangentimpulse2) end

world.w:setCallbacks( beginContact, endContact, preSolve, postSolve )

local MakeBall = function(x,y)
  GameEntity( stage, x, y, nil, world:createSphereBody(x,y,10/32,10) )
  --GameEntity( stage, world, x, y, anim, world:createRectangleBody(x,y,5/32,5/32,10) )
end


local MakeCube = function(x,y)
  local phb = world:createBody(x,y,0,"kinematic")
  world:addRectFixture( phb, 0, 130, 600, 10, 0 )
  world:addRectFixture( phb, -300, 0, 10, 300, 0 )
  world:addRectFixture( phb, 300, 0, 10, 300, 0 )
  local controller = function(self)
  end
  local ent = GameEntity( stage, x, y, nil, phb, controller )
end


local insertmode = false;
local click = false

local plain_reset = function(self)
  for k in pairs (self.points) do
	self.points [k] = nil
  end
end

local lines_plotter = function(fixfun)
  -- rx9: just so you know, another option would be to pass the name of the method as a string like this: `lines_plotter('method')`, and then call `world[fixfun](world, phb, self.points)` in the lines_plotter function
  return function(self, x, y)
	local phb = world:createBody(x,y,0,"static")
	phb:setFixedRotation(false)
	fixfun( world, phb, self.points )
	local ent = GameEntity( stage, x, y, nil, phb ) --world:createCube(x,y))
	ent.controller = function(self)
	end
  end
end

local toolbox = {
  edgeplotter = {
  	sensitivity = 0.01,
  	points = {},
	plot = lines_plotter(world.addEdgeFixture),
	reset = plain_reset,
	insert = function ( self, x, y )
	  table.insert(self.points, { x = x, y = y })
	end,
	render = function(self)
	  for k,v in pairs(self.points) do
		love.graphics.point(v.x,v.y)
	  end
	end
  },
  polyplotter = {
  	sensitivity = 0.25,
  	points = {},
	plot = lines_plotter(world.addPolygonFixture),
	reset = plain_reset,
	insert = function ( self, x, y )
	  if #self.points < 8*2 then
		table.insert(self.points, x)
		table.insert(self.points, y)
	  end
	end,
	render = function(self)
	  for i=1,#self.points,2 do
		love.graphics.point(self.points[i],self.points[i+1])
	  end
	end
  },

  rectPlot = {

  },
  selection = {
  	sensitivity = 0.25,
  	points = {},
	plot = function (self, x, y)
	end,
	reset = plain_reset,
	insert = function ( self, x, y )
	  for k,gameobj in pairs(stage.objects) do
	  	for k2,fix in pairs(gameobj.physicbody:getFixtureList()) do
		  if fix:testPoint(x,y) then
		  	print("yeah")
		  	table.insert(self.points,gameobj)
		  	break
		  end
		end
	  end
	end,
	render = function(self)
	end
  }
}

local PlotEdge = function(x,y)
  --local phb = world:createBody(x,y,0,"kinematic")
end

local current_tool = toolbox.selection

function Editor:enter()
  for k,v in pairs(stage.objects) do
	v.dead = true
  end
  for i=1,300 do
  	MakeBall(300+i*1,250)
  end
  MakeCube(400,400)
end


function Editor:keypressed(key)
  if key == " " then
	insertmode = not insertmode
	if not insertmode then
	  current_tool:plot( 0, 0 )
	  current_tool:reset()
	end
  end
end

local plot_timer = 0

local mousepress = false
local mousepos = {}

function Editor:mousepressed(x,y,button)
  mousepress = true
  mousepos.x = x
  mousepos.y = y
end

function Editor:mousereleased(x,y,button)
  mousepress = false
  plot_timer = 0
end


function Editor:keyreleased(key)

end

function Editor:update( dt )

  if mousepress == true and insertmode == true  and plot_timer < love.timer.getTime() then
	plot_timer = love.timer.getTime() + current_tool.sensitivity
  	local obj = { };
  	mousepos.x = love.mouse.getX()
  	mousepos.y = love.mouse.getY()
  	obj.x = mousepos.x; obj.y = mousepos.y;
  	print ("objx"..obj.x..",objy"..obj.y)
  	current_tool:insert( obj.x, obj.y )
  end

  click = false
  timer.update(dt)
  stage:update(dt)
  if gui.Button{text = "Go back", pos = {5,5}} then
	timer.clear()
	Gamestate.switch(Menu)
  end
  if gui.Button{text = "Edge plotter", pos={5,80}} then
  	current_tool = toolbox.edgeplotter
  elseif gui.Button{text = "Poly plotter", pos={5,120}} then
  	current_tool = toolbox.polyplotter
  elseif gui.Button{text = "Selection", pos={5,160}} then
  	current_tool = toolbox.selection
  end
end

function Editor:draw()
  stage:draw()
  gui.core.draw()
  love.graphics.setColor({255,0,0,255})
  love.graphics.setFont(smallFont)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 50)
  love.graphics.setColor({0,255,0,255})
  love.graphics.setPointSize(10)
  current_tool:render()
end
