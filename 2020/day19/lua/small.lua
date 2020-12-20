local lpeg = require 'lpeg'
-- grammar
grammar = {A0 = (lpeg.V("A1") * lpeg.V("A2")), 
A1 = lpeg.P("a"), 
A2 = ((lpeg.V("A1") * lpeg.V("A3")) + (lpeg.V("A3") * lpeg.V("A1"))), 
A3 = lpeg.P("b")}

input = {
"aab", 
"aba", 
"baa"
}
return {grammar = grammar, input = input}
