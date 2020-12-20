local lpeg = require 'lpeg'

-- grammar = lpeg.P {
--     "A0",
--     A0 = (lpeg.V("A1") * lpeg.V("A2")),
--     A1 = lpeg.P("a"),
--     A2 = ((lpeg.V("A1") * lpeg.V("A3")) + (lpeg.V("A3") * lpeg.V("A1"))),
--     A3 = lpeg.P("b"),
-- }

-- consumes the expression if it's possible
-- otherwise without consuming, continues
function maybe(expression)
    -- (match_without_consume AND match_with_consume) or (true)
    return ((#expression) * expression) + ''
end

function full(expression)
    -- (match_without_consume AND match_with_consume)
    return ((#expression) * expression)
end

function lazy_or(a, b)
    return full(a) + full(b)
end

grammar = lpeg.P("c") + lpeg.P("css")

function matches(str)
    local count = grammar:match(str)
    return (count == #str+1), count
end

print(matches("c"))
print(matches("css"))
-- print(matches("aa"))
