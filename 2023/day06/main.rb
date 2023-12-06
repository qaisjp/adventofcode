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

  EG1 = 288
  def one
    times, distances = @data
    times = times.delete_prefix("Time:").split.map(&:to_i)
    distances = distances.delete_prefix("Distance:").split.map(&:to_i)

    times.each_with_index.map do |time, i|
      (0...time).count do |charge_time|
        remaining_time = time - charge_time
        distance_travelled = remaining_time * charge_time
        distance_travelled > distances[i]
      end
    end.inject(&:*)
  end

  EG2 = 71503
  def two
    time, distance = @data
    time = time.delete_prefix("Time:").gsub(" ", "").to_i
    distance = distance.delete_prefix("Distance:").gsub(" ", "").to_i

    (0...time).count do |charge_time|
      remaining_time = time - charge_time
      distance_travelled = remaining_time * charge_time
      distance_travelled > distance
    end
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
