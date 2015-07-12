-- Name generation tools
-- TODO Figure out if I want to move everything from here to namegen...
package.path = package.path .. ";src\\?;src\\?.lua"


--require "lifegen.genparameters"
--require "lifegen.namegen"

local genLib = {}

genLib.tweaks = {}

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
  
  for line,options in pairs(textArray) do
    local ruleOptions = {}
    local firstPlus = options:find("+")
    local firstMinus = options:find("-")
    local spacesAtStart -- Spaces at start of the line
    
    if not firstMinus or firstPlus < firstMinus then -- Positive rule
      ruleOptions.isPositive = true
      spacesAtStart = firstPlus - 1
    else -- Negative rule
      ruleOptions.isPositive = false
      spacesAtStart = firstMinus - 1
    end
    
    options = options:sub(spacesAtStart)
    local stringTable = split(options," ")
    
    for k,v in pairs(stringTable) do
      if k > 1 then
        table.insert(ruleOptions,v)
      end
    end
    
    local name = stringTable[1]
    name = name:gsub("-", "")
    name = name:gsub("+", "")
    rules[name] = ruleOptions -- E.g. rules["everything] = {} (no parameters)
  end
  
  return rules
end
genLib.parseRelationText = parseRelationText

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
genLib.untextifyRelations = untextifyRelations

local function checkPriorityTable(priorityTable)
  for rule,priority in pairs(priorityTable) do
    assert(type(rule) == "string", "Rule name is not string!")
    if type(priority) ~= "number" then
      assert(false, "Rule priority is not number, fixing...")
      priorityTable[rule] = 0
    end
  end
end
genLib.checkPriorityTable = checkPriorityTable

local function checkPossibleRules(relationTable,priorityTable,context) -- Feed it with tables and context
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
  
  return blockedRules -- Yes, returns rule names that are NOT possible
end
genLib.checkPossibleRules = checkPossibleRules

local function getRelationTables(rules)
  local relationTable = {}
  local priorityTable = {}
  
  for line,rule in pairs(rules) do
    relationTable[rule.name] = rule.relations
    priorityTable[rule.name] = rule.priority
  end
  
  return relationTable, priorityTable
end
genLib.getRelationTables = getRelationTables

local function removeBlockedRules(rules,blockedRules)
  local newRules = {}
  for line,rule in pairs(rules) do
    if blockedRules[rule.name] == false then
      table.insert(newRules,rules)
    end
  end
  
  return newRules
end
genLib.removeBlockedRules = removeBlockedRules

local function parsePatterns(patterns)
  for id,tweak in pairs(genLib.tweaks) do
    local patternParsers = tweak.patternParsers
    if patternParsers ~= {} then
      for name,parser in pairs(patternParsers) do
        patterns = parser(patterns) -- Hope that the parser didn't return nil
      end
    end
  end
end
genLib.parsePatters = parsePatterns

local function loopForNextPattern(available,random)
  local accepted = {}
  local rejected = {}
  
  for pattern,change in pairs(available) do
    local rand = random() -- Random number between 0 and 1
    
    if rand <= change then
      accepted[pattern] = change
    else
      rejected[pattern] = change
    end
  end
  
  return accepted,rejected
end

local function makeName(patterns,random,nameLenght)
  local previous = "_start" -- previous pattern; at start, it is _start
  local name = {}
  
  repeat
    local available = {}
    local ready = false
    repeat
      local accepted, rejected = loopForNextPattern(available,random)
     
      local counter = 0
      local last = nil
      for k,v in pairs(accepted) do
        counter = counter + 1
        last = k -- Key is the pattern, value is useless change for that
      end
      
      if counter == 1 then
        ready = true
        name = table.insert(name,last)
      end
      
      available = {}
      for k,v in pairs(accepted) do
        available[k] = v
      end
    until ready == true
  until #name >= nameLenght -- Fallback to stop generation if nameLenght is exceeded... Just in case
  
  return table.concat(name)
end

local function createNamePart(params,part) -- Create name part (first/last name)
  local relationTable, priorityTable = getRelationTables(params.namingRules)
  local blockedRules = checkPossibleRules(relationTable, priorityTable, "same") -- Names of blocked
  
  local rules = removeBlockedRules(params.namingRules,blockedRules)
  local patterns = {}
  
  if rules[2] == nil then -- There is only one rule left... GOOD!
    patterns = rules[1].patterns
  else
    error("Rule combining is not supported yet!") -- TODO rule combinations
  end
  
  patterns = parsePatterns(patterns) -- Call for tweaks
  
  
end
genLib.createNamePart = createNamePart

return genLib