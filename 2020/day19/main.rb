# frozen_string_literal: true

require 'sorbet-runtime'

# AoC
class AoC
  def initialize(puzzle)
    rules, input = puzzle.split("\n\n")
    @input = input.split

    @rules = []
    @reggies = []
    rules.split("\n").each do |line|
      line = line.strip
      key, right = line.split(": ")
      @rules[key.to_i] = right
    end

    puts "#{@rules}"
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data, T::Array[String])
  end

  def build_regex(b)
    regex = @reggies[n]
    if regex
      return regex
    end
    rule = @rules[n]

    if rule.start_with? '"'
      return rule[1..-2]
    end

    regex = rule.split(" | ").map do |pair|
      adjacents = pair.split.map {|n| build_regex(Integer(n))}.join("")
      "(#{adjacents})"
    end.join("|")

    regex = "(#{regex})"
    @reggies[n] = regex
    regex
  end

  def one
    regex = Regexp.new("^"+build_regex(0)+"$")
    @input.count {|l| l =~ regex}
  end

  def two

  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.read

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
