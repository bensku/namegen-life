-- Name generation tools
-- TODO Figure out if I want to move everything from here to namegen...

local function split(string,sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  string:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

local function parseRelationText(textArray) -- Parse partially text-form relation data to lua table
  -- Quick and dirty... Split to multiple functions?
  local rules = {}
  
  for line,options in textArray do
    local ruleOptions = {}
    local firstPlus = options:find("+")
    local firstMinus = options:find("-")
    local spacesAtStart -- Spaces at start of the line
    
    if firstPlus < firstMinus then -- Positive rule
      ruleOptions.isPositive = true
      spacesAtStart = firstPlus - 1
    else -- Negative rule
      ruleOptions.isPositive = false
      spacesAtStart = firstMinus - 1
    end
    
    options = options:sub(spacesAtStart)
    local stringTable = split(options," ")
    
    for k,v in stringTable do
      if k > 1 then
        table.insert(ruleOptions,v)
      end
    end
    
    local name = stringTabe[1]
    name = name:gsub("-","")
    name = name:gsub("+,","")
    rules[name] = ruleOptions
  end
  
  return rules
end

local function parseRelationTable(table) -- Parse relation table if needed
  
end

local function checkPossibleRules(allRules)
  for rule,options in allRules do -- Check rules with * +separate or +everything
    
  end
end

local function createNamePart(params,part) -- Create name part (first/last name)
  
end