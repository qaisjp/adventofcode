# frozen_string_literal: true
# typed: true

require 'scanf'

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @pos = data.map {_1.split(": ")[1].to_i - 1} # position starting from 0
    @pos2 = @pos.dup
  end

  def roll
    @die += 1
    @die
  end

  def play(player)
    moves = roll + roll + roll
    @pos[player] = (@pos[player] + moves) % 10
    @score[player] += @pos[player] + 1
  end

  def one
    @score = [0,0]
    @die = 0

    player_one = true
    loop do
      play(player_one ? 0 : 1)
      player_one = !player_one
      if @score[0] >= 1000
        puts "Player 1 wins with #{@score[0]} and die #{@die} * #{@score[1]}"
        return @die * @score[1]
      elsif @score[1] >= 1000
        puts "Player 2 wins with #{@score[1]} and die #{@die} * #{@score[0]}"
        return @die * @score[0]
      end
    end
  end

  ThreeRolls = [1,2,3].repeated_permutation(3)
  ThreeRollSums = [1,2,3].repeated_permutation(3).map(&:sum).to_a

  def maybe_p
    if (time_elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @lastprint) > 2
      time_elapsed_minutes = (time_elapsed / 60).round(2)
      puts "universes_won: #{@universes_won} (#{time_elapsed.round(2)} seconds elapsed - #{time_elapsed_minutes} minutes)"
      @lastprint = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end

  def two
    @lastprint = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @universes_won = [0,0]

    universes = [
      [
        [@pos2[0], 0], # [position, score]
        [@pos2[1], 0], # [position, score]
        true, # player_one
      ]
    ]

    while !universes.empty?
      universes = universes.flat_map do |universe|
        maybe_p
        # puts "Processing universe #{universe}"

        player_index = universe[2] ? 0 : 1
        pos, score = universe[player_index]

        universe[2] = !universe[2]

        ThreeRollSums.filter_map do |moves|
          new_pos = (pos + moves) % 10
          new_score = score + new_pos + 1

          if new_score >= 21
           @universes_won[player_index] += 1
            next
          end

          new_universe = universe.dup
          new_universe[player_index] = [new_pos, new_score]
          new_universe
        end
      end
    end

    puts "universes_won: #{universes_won}"
    @universes_won.max
  end
end

def test(part)
  examples = [
    739785,
    0,
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
