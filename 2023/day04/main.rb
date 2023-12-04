# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
require 'pry'
# AoC
class AoC
  extend T::Sig
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data.first, String)
    @data = T.let(data, T::Array[String])
  end

  EG1 = 13
  def one
    @data.map do |line|
      haystack, needles = line.split(" | ")
      haystack = haystack.split(":")[1].strip.split.map(&:to_i)
      needles = needles.split.map(&:to_i)
      overlap = (haystack & needles)
      matches = overlap.size
      if matches > 0
        2 ** (matches-1)
      else
        0
      end
    end.sum
  end

  EG2 = 30
  def two
    max_card_num = @data.size
    
    cards_to_process = @data.dup
    card_index = 0
    max_size = cards_to_process.size
    matches_memo = {}

    while card_index < max_size do
      line = cards_to_process[card_index]

      haystack, needles = line.split(" | ")
      card, haystack = haystack.split(":")
      card, = card.scanf("Card %d")

      matches = matches_memo[card]
      if !matches
        haystack = haystack.strip.split.map(&:to_i)
        needles = needles.split.map(&:to_i)

        overlap = (haystack & needles)
        matches = overlap.size
        matches_memo[card] = matches
      end

      (card+1 .. (card+matches)).each do |card_num|
        cards_to_process << cards_to_process[card_num-1]
        max_size += 1
      end

      card_index += 1
    end

    cards_to_process.size
  end
end

#####
##### BOILERPLATE
#####

def test(_part)
  runner = AoC.new File.read('example.txt').split("\n")
  runner2 = AoC.new File.read('example2.txt').split("\n")

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
    two = runner2.two
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
