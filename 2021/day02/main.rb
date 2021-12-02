# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])
  end

  def one
    x = 0
    y = 0
    @data.each do |line|
      action, num = line.split
      num = Integer(num)

      if action == "up"
        y -= num
      elsif action == "down"
        y += num
      elsif action == "forward"
        x += num
      else
        raise "unknown action #{action}"
      end
    end

    x * y
  end

  def two
    x = 0
    y = 0
    aim = 0

    @data.each do |line|
      action, num = line.split
      num = Integer(num)

      if action == "up"
        aim -= num
      elsif action == "down"
        aim += num
      elsif action == "forward"
        x += num
        y += aim * num
      else
        raise "unknown action #{action}"
      end
    end

    x * y
  end
end

$examples = [
  150,
  900,
]

def test(part)
  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = $examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
  end

  if part == "2"
    two = runner.two
    this = $examples[1]
    if two != this
      puts "Example part 2 was #{two}, expected #{this}"
    else
      puts "Example part 2 passes (#{this})"
    end
  end
end

def main
  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  test(n)

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end

main
