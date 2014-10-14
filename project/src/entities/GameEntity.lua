
local Class         = require (LIBRARYPATH.."hump.class"	)

require "src.entities.Entity"
require (LIBRARYPATH.."AnAL")

GameEntity = Class {
  init = function(self, stage, x, y, anim, phbody, controller)
  	self = Entity.init(self, stage, x, y)
  	self.controller = controller or nil
  	self.anim = anim
  	self.physicbody = phbody
  	return self
  end,
  update = function(self,dt)
	if self.anim ~= nil then self.anim:update(dt) end
	if self.controller ~= nil then self.controller(self) end
	self.pos.x = self.physicbody:getX()
	self.pos.y = self.physicbody:getY()
  end,
  draw = function(self)
	love.graphics.setColor({255,0,255,255})
	for k,fix in pairs(self.physicbody:getFixtureList()) do
	  if fix:getType() == "polygon" then
		love.graphics.polygon("line", self.physicbody:getWorldPoints(fix:getShape():getPoints()))
	  elseif fix:getType() == "edge" or fix:getType() == "chain" then
	  	local x1, y1, x2, y2
	  	x1,y1,x2,y2 = fix:getShape():getPoints()
	  	love.graphics.push()
	  	love.graphics.rotate(self.physicbody:getAngle())
		love.graphics.line(self.pos.x+x1,self.pos.y+y1,self.pos.x+x2,self.pos.y+y2)
		love.graphics.pop()
	  else
		love.graphics.circle("line", self.pos.x, self.pos.y, fix:getShape():getRadius(), 20)
	  end
	end
	if self.anim ~= nil then self.anim:draw(self.pos.x,self.pos.y) end
  end
}

GameEntity:include(Entity)
