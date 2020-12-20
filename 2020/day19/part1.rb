require 'scanf'

class String
    alias_method :old_inspect, :inspect
    def raw!
        @real = true
        self
    end

    def inspect
        @real ? self : self.old_inspect
    end
end

puts "#{['hi']} and #{['lpeg.V(ok)'.raw!]}"

out_filename = ARGV[0].gsub('.txt', '.lua').gsub("examples", "lua")

lines = ARGF.read
raw_grammar, input = lines.split("\n\n")

grammar_lua = <<-EOF
local lpeg = require 'lpeg'
-- grammar
EOF

suffix_lua = <<-EOF

return {grammar = grammar, input = input}
EOF

grammar = {}
raw_grammar.split("\n").each do |line|
    key, lineRest = line.split(": ")

    # determinant?
    if lineRest.start_with? '"'
        char = lineRest[1..-2]
        grammar[key] = "lpeg.P(#{char.inspect})".raw!
    else
        items = lineRest.split(" | ").map do |oneof|
            # lua is indexed from 1 so increment all by 1
            s = "(" + oneof.split(" ").map {|x| "lpeg.V(#{('A'+x).inspect})".raw!}.join(" * ") + ")"
            s.raw!
        end
        # grammar[key] = items
        if items.size == 1
            grammar[key] = items[0]
        else
            # puts "is: #{items[0].inspect}"
            grammar[key] = ("("+items.join(" + ")+")").raw!
        end
    end
end

def to_lua_table(arr)
    arr.inspect.gsub("[", "{\n").gsub("]", "\n}").gsub(/"(\d+)"=>/, 'A\1 = ').gsub(', ', ", \n")
end

grammar_lua += "grammar = " + to_lua_table(grammar)
input_lua = "\n\ninput = " + to_lua_table(input.split("\n"))

File.write(out_filename, grammar_lua + input_lua + suffix_lua)

# puts `lua part1.lua #{out_filename}`
