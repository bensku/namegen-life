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

local function untextifyRelations(table) -- Parse relation table if needed
  local newTable = {}
  for k,v in pairs(table) do
    for line,options in pairs(v) do
      v[line] = parseRelationText(options)
    end
    newTable[k] = v
  end
  
  return newTable
end

local function checkPriorityTable(priorityTable)
  for rule,priority in pairs(priorityTable) do
    assert(type(rule) == "string", "Rule name is not string!")
    if type(priority) ~= "number" then
      assert(false, "Rule priority is not number, fixing...")
      priorityTable[rule] = 0
    end
  end
end

local function checkPossibleRules(relationTable,priorityTable,context) -- Feed it with table (key=rule name,value=relations) and name part
  local relations = untextifyRelations(relationTable) -- TODO This is WAY too messy; separate when ready
  
  local blockedRules = {} -- Blocked rules
  
  for name,rules in pairs(relations) do
    local priority = priorityTable[name] -- Number, right?
    local whitelist = {}
    local localBlocked = {} -- Local blocked rules, copied to global ones after passing whitelist check
    for group,options in pairs(rules) do
      local otherPriority = priorityTable[group] -- TODO support * and ?
      for option,params in pairs(options) do
        if option == "everything" then
          if params.isPositive then
            whitelist[group] = true
          end
          
          if params.isPositive == false and priority < otherPriority then
            if whitelist[group] ~= true then localBlocked[group] = true end
          end
        elseif option == "separate" and context == "same" then
          if params.isPositive == false and priority < otherPriority then
            if whitelist[group] ~= true then localBlocked[group] = true end
          end
        end
      end
    end
    
    for group,value in pairs(whitelist) do
      if value then localBlocked[group] = false end
    end
    
    for group,value in pairs(localBlocked) do
      if value then blockedRules[group][name] = true end
    end
  end
  
  for group,values in pairs(blockedRules) do -- Remove irrelevant blocks
    local isValid = false -- Is block still valid
    for value,bool in pairs(values) do
      if group[value] ~= false then isValid = true end
    end
    
    if isValid == false then blockedRules[group] = nil end -- Assign nil because may use less memory than false
  end
  
  return blockedRules
end

local function getRelationTables(rules)
  local relationTable = {}
  local priorityTable = {}
  
  for line,rule in pairs(rules) do
    relationTable[rule.name] = rule.relations
    priorityTable[rule.name] = rule.priority
  end
  
  return relationTable, priorityTable
end

local function createNamePart(params,part) -- Create name part (first/last name)
  
end