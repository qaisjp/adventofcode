# frozen_string_literal: true
# typed: true

require 'scanf'

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  def prio(c)
    base = 1
    initial = if c.upcase == c
      base = 27
      "A"
    else
      "a"
    end
    base + c.codepoints.first - initial.codepoints.first
  end

  def one
    @data.map do |line|
      # puts "X: #{line}"
      c1, c2 = line[0...line.size/2], line[line.size/2...]
      common = c1.chars & c2.chars
      puts "For #{c1} & #{c2}, common #{common}, prio #{prio(common.first)}"
      prio(common.first)
    end.sum
  end

  def two
    @data.each_slice(3).map do |group|
      common = group.map(&:chars).inject(&:&).first
      puts "group: #{group}, common: #{common}"
      prio(common)
    end.sum
  end
end

def test(part)
  examples = [
    157,
    70,
  ]

  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = examples.last
    if two != this
      puts "\n\nExample part 2 was #{two}, expected #{this}"
      passed = false
    else
      puts "\n\nExample part 2 passes (#{this})"
    end
  end

  passed
end

def main
  run_both = false

  n = ARGV.shift

  if !test(n)
    puts "Tests failed :("
    return
  end

  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
