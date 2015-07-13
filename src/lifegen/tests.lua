-- Tests mainly for genlib

os.execute("cd")

package.path = package.path .. ";src\\?;src\\?.lua"

local function runTests(genlib)
  -- Test relation text parser
  local textArray = {}
  textArray["*"] = "+separate"
  local relationArray = genlib.parseRelationText(textArray)
  
  for k,v in pairs(relationArray) do
    print("relationArray key: "..k)
    for k2,v2 in pairs(v) do
      print("value "..k2)
    end
  end
  
  
end

local genlib = require "lifegen.genlib"
runTests(genlib)

local NGenLifeParams, LifeNamingRule = unpack(require "lifegen.genparameters")
print(type(NGenLifeParams))
print(type(LifeNamingRule))