-- Name generator

require "genparameters"

--- Life name generator, which utilizes markov chain.
-- @type NameGenLife
local NameGenLife = {}

function NameGenLife:new(params,o)
  params = params or nil
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.params = params
  return o
end

NameGenLife.params = NGenLifeParams:new()

--- Name generation library implementation.
-- Replace this if you want to change behavior of name generator. Only
-- remember that replacing may break compatibility.
NameGenLife.genLib = require "genlib"

function NameGenLife:createName(params)
  params = params or self.params -- Assign params from self if not provided or nil
  
  local rules = checkPossibleRules(params.namingRules)
end

function NameGenLife.split(string,sep)
  local function split(string1,sep1) -- TODO better default implementation
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    string:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
  end
  
  return split(string,sep)
end

return NameGenLife