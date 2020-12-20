lpeg = require 'lpeg'
puzzle = require(arg[1]:gsub(".lua", ""):gsub("/", "."))

grammar = puzzle.grammar
input = puzzle.input

grammar[1] = "A0"
local grammar = lpeg.P(grammar)

local count = 0
for _, str in ipairs(input) do
    local matches = grammar:match(str) == (#str+1)
    if matches then
        count = count + 1
    end
end

print(count)
