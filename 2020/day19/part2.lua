lpeg = require 'lpeg'
puzzle = require(arg[1]:gsub(".lua", ""):gsub("/", "."))
re = require 're'

grammar = puzzle.grammar
input = puzzle.input

grammar[1] = "A0"


-- consumes the expression if it's possible
-- otherwise without consuming, continues
function maybe(expression)
    -- (match_without_consume AND match_with_consume) or (true)
    return ((#expression) * expression) + ''
end

-- 8: 42 | 42 8
-- 42 8?
grammar.A8 = lpeg.V("A42") * maybe(lpeg.V "A8")

-- 42 11? 31
-- 11: 42 31 | 42 11 31
grammar.A11 = lpeg.V("A42") * maybe(lpeg.V("A11")) * lpeg.V("A31")

grammar = lpeg.P(grammar)

-- expected matches in huge.txt
local huge_expected = {
    ["bbabbbbaabaabba"] = true,
    ["babbbbaabbbbbabbbbbbaabaaabaaa"] = true,
    ["aaabbbbbbaaaabaababaabababbabaaabbababababaaa"] = true,
    ["bbbbbbbaaaabbbbaaabbabaaa"] = true,
    ["bbbababbbbaaaaaaaabbababaaababaabab"] = true,
    ["ababaaaaaabaaab"] = true,
    ["ababaaaaabbbaba"] = true,
    ["baabbaaaabbaaaababbaababb"] = true,
    ["abbbbabbbbaaaababbbbbbaaaababb"] = true,
    ["aaaaabbaabaaaaababaa"] = true,
    ["aaaabbaabbaaaaaaabbbabbbaaabbaabaaa"] = true,
    ["aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"] = true,
}

local count = 0
for _, str in ipairs(input) do
    local matches = grammar:match(str) == (#str+1)
    local expected_huge = huge_expected[str] == true
    if matches then
        count = count + 1
    end
    if expected_huge ~= matches then
        print(string.format("%s did not match. wanted %s got %s", str, expected_huge, matches))
    end
    -- print(grammar:match(str))
end


print(count)
