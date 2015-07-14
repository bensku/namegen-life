-- Generator parameters
package.path = package.path .. ";src\\?;src\\?.lua"

-- TODO Windows Eclipse crashes if I override imports... ?
-- require "lifegen.namegen"

--- Namegen-life parameters.
-- @type NgenLifeParams
local NGenLifeParams = {}

function NGenLifeParams:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Naming rule for namegen-life.
-- @type LifeNamingRule
local LifeNamingRule = {}

function LifeNamingRule:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Name of the rule. Should be same always.
LifeNamingRule.name = "default"

--- Patters of characters, each with it's own probability.
-- Each entry of table is labeled with characters which it applies to (ex. "aa").
-- It contains <i>another</i> table which has again entries specified by
-- some characters. These entries contain probabilities for them to happen.
-- 
-- Example: patterns = aa = {ab = 0.1, ac = 0.2, ad = 0.3}, ab = {...}, ac = {...}}
-- 
-- The name generator iterates through the table, and generates random number
-- with range of 0-1 for each entry. If the number is smaller than probability,
-- the pattern is marked as possible, if not it is immediately rejected.
-- 
-- If there is only one pattern left, it will be used as next for the name. If
-- there is multiple ones, the NGenLifeParams.chooseMethod defines the behavior.
LifeNamingRule.patterns = {}

--- Priority of the naming rule.
-- Default is 0. Values lower than that are more important, higher less.
-- If every rule works together, priority is ignored... But if it does not,
-- rule with highest priority (=lowest value) is used with every other rule
-- possible.
LifeNamingRule.priority = 0

--- Relations with other rules.
-- The key is name of rule to apply modifiers. It supports wildcards * and ? as
-- in general regular expressions.
-- 
-- The value is table of string keys that specify how this rule is compatible
-- with rule(s) specified in keys. Each key is started with plus (+) or
-- minus (-), and that character defines whether to disable or enable rule.
-- Some rules may take parameters, which are separated from the main rule
-- using space.
-- 
-- Possible rules:
-- <ul>
-- <li>everything: Rules may used together in <b>every</b> case. Be careful 
-- when using this, updates may change behavior in weird ways
-- (unless minus, which is perfectly ok, but useless usually)
-- <li>separate: Rules may used in different parts of same name 
-- (e.g. first name and surname).
-- <li>same <firstname/lastname>: Rules may used in same parts of name.
-- </ul>
LifeNamingRule.relations = {}
LifeNamingRule.relations["*"] = {"+separate"}

--- Metadata for this rule.
-- Metadata consists set of keys with string values. No keys are necessary, but
-- few are recommended:
-- <ul>
-- <li>authors: authors of data (not necessarily source of it). Use , to separate
-- multiple authors.
-- <li>name: name of data
-- <li>desc: description of datas
-- <li>version: version of data (should be valid number)
-- <li>program: program used to grab data from name list to patterns ("hand-made" if none is used)
-- <li>source: source of name data
-- <li>website: website url related to the file
-- </ul>
LifeNamingRule.metadata = {}

function LifeNamingRule:read(string)
  local split = NameGenLife.split
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

--- List of naming rules.
NGenLifeParams.namingRules = {}

--- Method used for choosing pattern.
-- <b>buffRare:</b> (TODO needs implementation)
-- 
-- The generator will check which has lowest change to
-- appear and <b>chooses it</b>. If there is multiple patterns with that low
-- change, others will rejected and the generator will randomly choose one of
-- them.
-- 
-- There is also special case, if one wants to manually assign changes.
-- If the change is not between 0-1, it will be treated differently when
-- discarding patterns by that probability value. The bigger the number is, the
-- higher priority the number has: 0.1 discards 0.2, but is discarded by 1.2.
-- The 1.2 is discarded by 1.1 and 1.1 by 2.2 etc...
-- 
-- <b>preciseMatch:</b>
-- The generator will loop through possible patterns until there is
-- only one left. It may have impact on performance.
NGenLifeParams.chooseMethod = "preciseMatch"

function NGenLifeParams:addRule(rule)
  table.insert(self.namingRules, rule)
end

return {NGenLifeParams, LifeNamingRule}