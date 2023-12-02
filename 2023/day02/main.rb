# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'scanf'
require 'set'

# AoC
class AoC
  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = T.let(data, T::Array[String])
    @powers = T.let(0, Integer)
  end

  EG1 = 8
  def one
    allowed_maxes = {"red"=>12, "green"=>13, "blue"=>14}

    game_ids_valid = 0
    @data.each do |game|
      game_bit, pulls = game.split(":")
      game_id = game_bit.scanf("Game %d")[0]

      max_for_color = T::Hash[String, Integer].new { 0 }

      pulls.strip.split(";").map(&:strip).each do |pull|
        pull = T.let(pull, String)
        pull.split(",").map(&:strip).each do |claim|
          num, color = claim.scanf("%d %s")
          max_for_color[color] = [max_for_color[color], num].max
        end
      end

      valid = max_for_color.all? do |color, max|
        max <= allowed_maxes[color] 
      end

      # returned in part 2
      @powers += max_for_color.values.inject(&:*)

      if valid
        game_ids_valid += game_id
      end
    end

    game_ids_valid
  end

  EG2 = 2286
  def two
    @powers
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
  run_both = T.let(true, T::Boolean)

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
