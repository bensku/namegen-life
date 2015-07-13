-- Name generator
package.path = package.path .. ";src\\?;src\\?.lua"

require "lifegen.genparameters"

--- Life name generator, which utilizes markov chain.
-- @type NameGenLife
local NameGenLife = {}

NameGenLife.isReady = false

--- Initializes namegen-life.
-- 
function NameGenLife:initialize()
  
end

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
-- Replace this if you want to change behavior of name generator. Just
-- remember that you must really <i>replace</i> it, changing some functions is
-- not enough since changes won't actually affect behavior of genLib;
-- internally all functions are locals in it and are them mapped to genLib to
-- maximize performance.
-- 
-- Generally using tweaks breaks less things.
NameGenLife.genLib = require "lifegen.genlib"

function NameGenLife:createName(params)
  params = params or self.params -- Assign params from self if not provided or nil
  
  local rules = checkPossibleRules(params.namingRules)
end

--- Returns tweak tools for this name generator.
-- Tweak tools may be used to alter behavior of name generator without
-- breaking compatibility. Each call to this function creates new
-- instance of tools, so don't call often.
-- 
-- Also remember that you <b>must</b> use register() function after using
-- the tools to make they do their work for names generated. Calling
-- unregister(), well, unregisters tools so they won't affect generation
-- anymore. Remember to save instance of tweak tools until you have done so,
-- otherwise you <b>can't</b> unregister tweaks at all.
-- 
-- If you want to make changes to tweaks you have made, remember
-- to unregister tools first. It is possible to simply change existing
-- tweak, but that may cause <i>fun</i> errors if name is generated when
-- you have only partially done your changes.
function NameGenLife:getTweakTools()
  local tweakTools = {}
  tweakTools.nameGen = self
  tweakTools.genLib = self.genLibs
  tweakTools.id = nil -- Not set yet...
  
  --- Pattern parsers.
  -- Pattern parsers are allowed to change name generation patterns just
  -- before they are used to generate name. They can also used to log patterns
  -- for debugging etc.
  -- 
  -- Use name of your function as key and put function itself as value.
  -- Function must accept patterns as first parameter and then return
  -- them even if <b>they are not changed</b>.
  tweakTools.patternParsers = {}
  
  function tweakTools:register()
    if self.id == nil then
      local rand = 0
      repeat
        rand = math.random(10000)
      until self.genLib.tweaks[rand] == nil
      self.id = rand
    end
    
    self.genLib.tweaks[self.id] = self
  end
  
  function tweakTools:unregister()
    self.genLib.tweaks[self.id] = nil
  end
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