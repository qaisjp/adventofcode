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
  end

  def build_regex(n)
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

  def build_regex_infinite(n, depth: 0)
    regex = @reggies[n]
    if regex
      return regex
    end
    depth += 1
    rule = @rules[n]

    if rule.start_with? '"'
      return rule[1..-2]
    end

    regex = rule.split(" | ").each_with_index.map do |pair, i|
      # settled on a depth of 13 by trial and error (count became stable)
      if depth > 14
        next nil if i == 1
      end
      adjacents = pair.split.map {|n| build_regex_infinite(Integer(n), depth: depth)}.join("")
      "(#{adjacents})"
    end.compact.join("|")

    regex = "(#{regex})"
    @reggies[n] = regex
    regex
  end

  def one
    regex = Regexp.new("^"+build_regex(0)+"$")
    @input.count {|l| l =~ regex}
  end

  def two
    # precompute safe regexes
    @rules.each_with_index do |_, i|
      if i == 0 || i == 8 || i == 11
        next
      end
      build_regex(i)
    end
    puts 'precompute done'
    regex = Regexp.new("^"+build_regex_infinite(0)+"$")
    @input.count {|l| l =~ regex}
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
