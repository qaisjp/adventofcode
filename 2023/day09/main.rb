# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
# AoC
class AoC
  extend T::Sig
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data.first, String)
    @data = T.let(data, T::Array[String])
  end

  def recursive_next(arr, mul=1)
    all_zero = T.let(true, T::Boolean)
    nums = arr.each_cons(2).map do |a, b|
      n = (b - a) * mul
      if n != 0
        all_zero = false
      end
      n
    end

    if all_zero
      return 0
    end
    if mul == 1
      return nums.last + recursive_next(nums, mul)
    else
      return nums.first + recursive_next(nums, mul)
    end
  end

  EG1 = 114
  def one
    @data.map do |line|
      nums = line.split.map(&:to_i)
      T.must(nums.last) + recursive_next(nums)
    end.sum
  end

  EG2 = 2
  def two
    @data.map do |line|
      nums = line.split.map(&:to_i)
      T.must(nums.first) + recursive_next(nums, -1)
    end.sum
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
