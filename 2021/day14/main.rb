# frozen_string_literal: true
# typed: true
require 'scanf'

class Array
  def most_common
    self.group_by(&:itself).values.max_by(&:size).first
  end
  def least_common
    self.group_by(&:itself).values.min_by(&:size).first
  end
end

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    @template = data.first
    @rules = data.last.split("\n").map {_1.scanf("%s -> %s")}.to_h
  end

  def str_to_adj(str)
    str.chars.each_cons(2).each_with_object(Hash.new(0)) do |(a, b), h|
      h[a+b] += 1
    end
  end

  def apply(adj, counts)
    adj.each_with_object(Hash.new(0)) do |(pair, count), h|
      a, b = pair.chars
      if (middle = @rules["#{a}#{b}"])
        counts[middle] += count
        h[a + middle] += count
        h[middle + b] += count
      else
        h[pair] += count
      end
    end
  end

  def doit(n)
    adj = str_to_adj(@template)

    counts = Hash.new(0).merge(@template.chars.tally)
    n.times do |i|
      adj = apply(adj, counts)
    end

    counts.values.max - counts.values.min
  end

  def one
    doit(10)
  end

  def two
    doit(40)
  end
end

def test(part)
  examples = [
    1588,
    2188189693529,
  ]

  runner = AoC.new File.read("example.txt").split("\n\n")

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
  run_both = true

  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  if !test(n)
    puts "Tests failed :("
    return
  end

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Result: #{runner.one}"
  end
  if n == '2'
    puts "Result: #{runner.two}"
  end
end

main
