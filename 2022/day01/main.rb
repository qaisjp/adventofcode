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

  def one
    @groups = []
    this = []
    @data.each do |line|
      if line == ""
        @groups << this
        this = []
      else
        this << line.to_i
      end
    end
    @groups << this

    @groups.map(&:sum).max
  end

  def two
    puts "groups: #{@groups.inspect}"
    tops = @groups.map(&:sum).sort.reverse
    puts tops
    tops[0] + tops[1] + tops[2]
  end
end

def test(part)
  examples = [
    24000,
    45000,
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
  run_both = true

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
