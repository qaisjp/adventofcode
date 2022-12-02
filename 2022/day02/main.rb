# frozen_string_literal: true
# typed: true

require 'scanf'

# AoC
class AoC
  SHAPE_SCORES = {
    "A" => 1, # Rock
    "X" => 1, # Rock
    "B" => 2, # Paper
    "Y" => 2, # Paper
    "C" => 3, # Scissors
    "Z" => 3, # Scissors
  }
  NORMALIZE = {
    "X" => "A",
    "Y" => "B",
    "Z" => "C",
  }
  LOSS_SCORE = 0
  DRAW_SCORE = 3
  WIN_SCORE = 6
  WIN_SCORES = {
    false => 0,
    "X" => 0,

    nil => 3,
    "Y" => 3,

    true => 6,
    "Z" => 6,
  }
  WIN_RESPONSES = {
    "A" => "Y",
    "B" => "Z",
    "C" => "X"
  }
  DRAW_RESPONSES = {
    "A" => "X",
    "B" => "Y",
    "C" => "Z"
  }
  LOSS_RESPONSES = {
    "A" => "Z",
    "B" => "X",
    "C" => "Y"
  }

  def check_win(me, them)
    if NORMALIZE[me] == them
      nil
    elsif me == WIN_RESPONSES[them]
      true
    else
      false
    end
  end

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  def one
    score = 0
    @data.each do |line|
      them, me = line.split(" ")
      # puts("me #{me.inspect} them #{them.inspect}")

      win_state = check_win(me, them)
      # puts("Adding #{SHAPE_SCORES[me]} and #{WIN_SCORES[win_state]}")
      score += SHAPE_SCORES[me] + WIN_SCORES[win_state]
    end

    score
  end

  def two
    score = 0
    @data.each do |line|
      them, wanted_state = line.split(" ")
      my_response = if wanted_state == "Z"
        WIN_RESPONSES[them]
      elsif wanted_state == "X"
        LOSS_RESPONSES[them]
      else
        DRAW_RESPONSES[them]
      end
      # puts("THey picked #{wanted_state}, I respond with #{my_response}")

      # puts("Adding #{SHAPE_SCORES[me]} and #{WIN_SCORES[win_state]}")
      score += SHAPE_SCORES[my_response] + WIN_SCORES[wanted_state]
    end

    score
  end
end

def test(part)
  examples = [
    15,
    12,
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
