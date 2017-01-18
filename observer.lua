-- Observer design pattern.
local inspect = require("inspect")

local observer = {}
local observerContainer = {}

-- Register
-- Adds functions or methods to the Signal filter
-- Usage:
--   s:register("update", nil, foobar)
--   s:register("update", o, o.m)
function observer.register(subject, signal, observer, method)
  local main_table = observerContainer[subject] or {}
  local t = main_table[signal] or {}

  local entry = { observer = observer, method = method }
  table.insert(t, entry)

  main_table[signal] = t
  observerContainer[subject] = main_table
end

-- Deregister
-- Removes any observations in the Signal filter, either matching
-- the Observer and Method, or the whole filter if both are nil.
-- Usage:
--   s:deregister("update")
--   s:deregister("update", o)
--   s:deregister("update", o, o.m)
--   observer.deregister()
function observer.deregister(subject, signal, observer, method)
  local main_table = observerContainer[subject]
  if not main_table then return end

  local t = main_table[signal]
  if not t then return end

  -- clear the observer list
  if not subject then
    observerContainer = nil

  -- remove a complete subject
  elseif not signal then
    main_table = nil

    -- remove signal completely
  elseif not observer and not method then
    t = nil
  else

    -- remove all signals for an object or a single signal-method match
    for i, v in ipairs(t) do
      if (v.observer == observer and not method)
        or (v.observer == observer and v.method == method) then
        table.remove(t, i)
      end
    end

  end

  if next(t) == nil then
    t = nil
  end

  observerContainer[subject][signal] = t

  if next(main_table) == nil then
    main_table = nil
  end

  observerContainer[subject] = main_table
end

-- Notify
-- Uses the Signal Filter to notify all observations via their
-- registered handlers.
-- Usage:
--   subject:notify("update", arg1, arg2)
function observer.notify(subject, signal, ...)
  t = observerContainer[subject][signal]
  if not t then return end

  for k, v in pairs(t) do
    -- for functions
    if not v.observer then
      v.method(subject, ...)
    -- for methods
    else
      v.method(v.observer, subject, ...)
    end
  end
end

return setmetatable(observer, {
  __index = function(t, k)
    if k == "container" then
      return observerContainer
    end
  end
})
