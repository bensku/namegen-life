-- Tests mainly for genlib

local function runTests(genlib)
  -- Test relation text parser
  local textArray = {}
  textArray["*"] = "+separate"
  local relationArray = genlib.parseRelationText(textArray)
end

local genlib = require "genlib"
runTests(genlib)