# frozen_string_literal: true
# typed: true

require 'scanf'



5 + 6 + 60 + 600 + 70 + 2000 + 500 + (3000 + (9000))

# Part 1:
# too low - 15231
# correct answer - 15237
# too high - 15241

# AoC
class AoC
  Score = {
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000,
  }

  def initialize(data)
    str  = "D2 A5 A6 B5 C6 C5 D3 B3 B4 D9 A3 A3"

    puts(str.split.map do |word|
      Score[word[0]] * (word[1..].to_i)
    end.sum)


    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  def try(row, rooms, energy)
    if energy.nil?
      energy = {"A" => 0, "B" => 0, "C" => 0, "D" => 0}
    end


  end

  def one(test=false)
    if test
    else
    end
    @data.each do |line|
      puts "X: #{line}"
    end

    0
  end

  def two

    0
  end
end

def test(part)
  examples = [
    0,
    0,
  ]

  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = examples.first(true)
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
