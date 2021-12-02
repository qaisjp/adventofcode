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
    @data.each do |line|
      puts "X: #{line}"
    end

    0
  end

  def two

    1
  end
end

$examples = [
  0,
  0,
]

def test(part)
  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  if one != $examples.first
    puts "Example part 1 was #{one}, expected #{$examples.first}"
  else
    puts "Example part 1 passes"
  end

  if part == "2"
    two = runner.two
    if two != $examples.first
      puts "Example part 2 was #{two}, expected #{$examples[1]}"
    else
      puts "Example part 2 passes"
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
