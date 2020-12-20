local lpeg = require 'lpeg'
-- grammar
grammar = {A0 = (lpeg.V("A4") * lpeg.V("A1") * lpeg.V("A5")), 
A1 = ((lpeg.V("A2") * lpeg.V("A3")) + (lpeg.V("A3") * lpeg.V("A2"))), 
A2 = ((lpeg.V("A4") * lpeg.V("A4")) + (lpeg.V("A5") * lpeg.V("A5"))), 
A3 = ((lpeg.V("A4") * lpeg.V("A5")) + (lpeg.V("A5") * lpeg.V("A4"))), 
A4 = lpeg.P("a"), 
A5 = lpeg.P("b")}

input = {
"ababbb", 
"bababa", 
"abbbab", 
"aaabbb", 
"aaaabbb"
}
return {grammar = grammar, input = input}
