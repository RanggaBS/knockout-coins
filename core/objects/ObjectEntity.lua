-- -------------------------------------------------------------------------- --
-- ObjectEntity class                                                         --
-- -------------------------------------------------------------------------- --

---@class ObjectEntity
---@field name string
---@field index integer
---@field pool integer
---@field pos ArrayOfNumbers3D
---@field area integer
---@field rotation number
local ObjectEntity = {}
ObjectEntity.__index = ObjectEntity

---Create a new persistent entity in the world.
---@param name string
---@param x? number
---@param y? number
---@param z? number
---@param area? integer
---@param rotation? number
function ObjectEntity.new(name, x, y, z, area, rotation)
  local self = setmetatable({}, ObjectEntity)

  self.name = name
  self.pos = { x or 0, y or 0, z or 0 }
  self.area = area or AreaGetVisible()
  self.rotation = rotation or 0

  self.index, self.pool = CreatePersistentEntity(
    name,
    self.pos[1],
    self.pos[2],
    self.pos[3],
    self.area,
    self.rotation
  )

  return self
end

---Internal helper to recreate the entity.
---@return ObjectEntity
function ObjectEntity:Recreate()
  -- Delete the old one
  if self.index and self.pool then
    DeletePersistentEntity(self.index, self.pool)
  end
  -- Recreate
  self.index, self.pool = CreatePersistentEntity(
    self.name,
    self.pos[1],
    self.pos[2],
    self.pos[3],
    self.rotation,
    self.area
  )
  return self
end

---Set a new rotation (in degrees)
---@param deg? number
---@return ObjectEntity
function ObjectEntity:SetRotation(deg)
  if self.rotation == deg then return self end
  self.rotation = deg or self.rotation
  return self:Recreate()
end

---Set a new position (x, y, z)
---@param x? number
---@param y? number
---@param z? number
---@return ObjectEntity
function ObjectEntity:SetPosition(x, y, z)
  if self.pos[1] == x and self.pos[2] == y and self.pos[3] == z then
    return self
  end
  self.pos[1] = x or self.pos[1]
  self.pos[2] = y or self.pos[2]
  self.pos[3] = z or self.pos[3]
  return self:Recreate()
end

---Destroy this entity from the world
---@return boolean success
function ObjectEntity:Destroy()
  if not self.index or not self.pool then return false end
  DeletePersistentEntity(self.index, self.pool)
  self.index, self.pool = nil, nil
  return true
end

---Check if this entity still exists in the world
---@return boolean
function ObjectEntity:IsExist()
  return self.index ~= nil and self.pool ~= nil
end

---@return string
function ObjectEntity:GetName()
  return self.name
end

---@return number x, number y, number z
function ObjectEntity:GetPosition()
  return self.pos[1], self.pos[2], self.pos[3]
end

---@return integer
function ObjectEntity:GetArea()
  return self.area
end

---@return number
function ObjectEntity:GetRotation()
  return self.rotation
end

---@return integer index, integer pool
function ObjectEntity:GetIndexAndPool()
  return self.index, self.pool
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.ObjectEntity = ObjectEntity
