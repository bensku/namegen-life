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
-- there is multiple ones, the generator will check which has lowest change to
-- appear and <b>chooses it</b>. If there is multiple patterns with that low
-- change, others will rejected and the generator will randomly choose one of
-- them.
-- 
-- There is also special case, if one wants to manually assign changes.
-- If the change is not between 0-1, it will be treated differently when
-- discarding patterns by that probability value. The bigger the number is, the
-- higher priority the number has: 0.1 discards 0.2, but is discarded by 1.2.
-- The 1.2 is discarded by 1.1 and 1.1 by 2.2 etc...
LifeNamingRule.patterns = {}

--- Priority of the naming rule.
-- Default is 0. Values lower than that are more important, higher less.
-- Used naming rule is randomized, and higher priority means higher change
-- to get used. Rule with lowest priority has always change to appear unless
-- NGenLifeParams.maxPriorityDifference is 1.
LifeNamingRule.priority = 0

--- List of naming rules.
NGenLifeParams.namingRules = {}

--- Max priority difference between lowest and highest priority.
NGenLifeParams.maxPriorityDifference = 0.9

function NGenLifeParams:addRule(rule)
  table.insert(self.namingRules, rule)
end