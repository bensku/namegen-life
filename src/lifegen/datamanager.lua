-- Data manager for reading/writing namegen data to files

--- Data manager for name generator.
-- Handles serialization, and saving all data needed by namegen-life.
-- @type DataManager
local DataManager = {}

function DataManager:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Abstract serializer.
-- @type Serializer
local Serializer = {}

function Serializer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- List of accepted data targets for this serializer.
-- Standard ones are "file", "string", "table" and "function".
-- Custom ones may be defined.
Serializer.acceptedTargets = {}

--- List of accepted data types for this serializer.
-- For example, "patterns", "names", "config" etc.
Serializer.acceptedTypes = {}

--- Serializes given data to target.
-- @param #string target: Target for data
-- @param #object data: Data to serialize
-- @return #boolean: True if serialization succeeded, false if not
-- @return #string: Error message in case of fail
function Serializer:serialize(target,data)
  
end

--- Deserializes data from given target.
-- @param #string target: Target of data
-- @param #object data: Where the serialized data should be injected (optional)
-- @return #object: Deserialized data, or false in case of fail
-- @return #string: Error message in case of fail
function Serializer:deserialize(target,data)
  
end

--- Serializers for patterns.
-- Patterns are needed to generate naming rules. These serializers
-- may be used to read them from strings and files.
DataManager.patternSerializers = {}

--- Default pattern serializer.
local PatternSerializer = Serializer:new()

PatternSerializer.acceptedTargets = {"string"}
PatternSerializer.acceptedTypes = {"patterns"}

function PatternSerializer:serialize()
  error("Serializing is not yet supported!")
end

function PatternSerializer:deserialize(target,string)
  assert(type(string) == "string", "Data must be string")
  
  local split = nil
  if type(lifegenUtils) ~= "table" or type(lifegenUtils.split) ~= "function" then
    split = splitFallback
  else
    split = lifegenUtils.split
  end
  
  local lines = split(string,"\n")
  
  local sections = {}
  local metadata = {}
  local currentSection = ""
  
  for line,text in ipairs(lines) do
    local parts = split(text, " ")
    
    if parts[1] == "!info" then
      currentSection = "metadata"
    elseif parts[1] == "!pattern" then
      currentSection = parts[2]
    else
      if currentSection == "metadata" then
        local options = split(text, "=")
        metadata[options[1]] = options[2]
      else
        assert(type(parts[2]) ~= "number", "Name pattern change has to be number")
        sections[currentSection][parts[1]] = tonumber(parts[2])
      end
    end
  end
  
  self.patterns = sections
  self.metadata = metadata
end