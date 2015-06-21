-- Generator parameters

--- Namegen-life parameters.
-- @type NgenLifeParams
NGenLifeParams = {}

function NGenLifeParams:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Naming rule for namegen-life.
-- @type LifeNamingRule
LifeNamingRule = {}

function LifeNamingRule:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Patters of characters, each with it's own probability.
-- Each entry of table is labeled with characters which it applies to (ex. "aa").
-- It contains <i>another</i> table which has again entries specified by
-- some characters. These entries contain probabilities for them to happen.
-- 
-- Example: patterns = {aa = {ab = 0.1, ac = 0.2, ad = 0.3}, ab = {...}, ac = {...}}
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