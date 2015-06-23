-- Name generator

require "genparameters"

--- Life name generator, which utilizes markov chain.
-- @type NameGenLife
NameGenLife = {}

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