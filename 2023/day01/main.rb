# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'

# AoC
class AoC
  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  EG1 = 142
  def one
    @data.sum do |line|
      nums = line.chars.filter {|c| c.match?(/[0-9]/) }.map(&:to_i)
      "#{nums[0]}#{nums[-1]}".to_i
    end
  end

  EG2 = 281
  def two
    @data.sum do |line|
      num_from_line(line)
    end
  end

  def num_from_line(line)
    words = ["_", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    first_regex = /[0-9]|one|two|three|four|five|six|seven|eight|nine/
    last_regex = Regexp.new("[0-9]|" + "one|two|three|four|five|six|seven|eight|nine".reverse)
    f = line[first_regex]
    if words.include?(f)
      f = words.index(f)
    else
      f.to_i
    end

    l = line.reverse[last_regex]
    puts("l is #{l.inspect}")
    puts("line is #{line.inspect}")

    if words.include?(l.reverse)
      l = words.index(l.reverse)
    else
      l.to_i
    end

    final = "#{f}#{l}".to_i
    puts("final for line #{line} is #{final}")
    final
  end
end

#####
##### BOILERPLATE
#####

def test(_part)
  runner = AoC.new File.read('example.txt').split("\n")

  one = runner.one
  this = AoC::EG1
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    runner = AoC.new File.read('example2.txt').split("\n")
    puts "\n\n--- Example part 2"
    two = runner.two
    this = AoC::EG2
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
  run_both = T.let(false, T::Boolean)

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

  puts "\n\n--- Part #{n} solution" if n != nil
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
