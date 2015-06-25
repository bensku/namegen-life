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
  if type(textArray[1]) == "string" then
    return textArray -- Array was in table-form already
  end
  
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
    
    local name = stringTable[1]
    name = name:gsub("-","")
    name = name:gsub("+,","")
    rules[name] = ruleOptions -- E.g. rules["everything] = {} (no parameters)
  end
  
  return rules
end

local function parseRelationTable(table) -- Parse relation table if needed
  local newTable = {}
  for k,v in table do
    for line,options in v.relations do
      v.relations[line] = parseRelationText(options)
    end
    newTable[k] = v
  end
  
  return newTable
end

local function sortByPriority(rules)
  for k,v in pairs(rules) do -- TODO sort by priority
    
  end
end

local function checkPossibleRules(rules)
  local allRules = sortByPriority(parseRelationTable(rules))
  
  local permissiveRules = {}
  local separateRules = {}
  
  for line,rule in ipairs(allRules) do
    for group,options in rule.relations do -- Check rules with * +separate or +everything
      local everythingOk = false -- TODO Remove and replace
      local separateOk = false
      if group == "*" then
        for option,params in options do
          if params.isPositive then
           if option == "everything" then
              everythingOk = true
            else if option == "separate" then
              separateOk = true
            end
          end
        end
        
        if everythingOk then table.insert(permissiveRules, rule) end
        if separateOk then table.insert(separateRules, rule) end
      end
    end
  end
end

local function createNamePart(params,part) -- Create name part (first/last name)
  
end