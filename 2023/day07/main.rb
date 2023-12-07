# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
require 'pry'
require 'json'

class Array
  include Comparable
  def <=>(other)
    self.zip(other).each do |a, b|
      if !(a.is_a?(Integer) && b.is_a?(Integer))
        raise ArgumentError.new("Expected integers in Array#<=>")
      end
      cmp = a <=> b
      if cmp != 0
        return cmp
      end
    end
    # raise ArgumentError.new("They are equal!")
    0
  end
end

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data.first, String)
    @data = T.let(data, T::Array[String])
  end

  ATOI = {
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "T" => 10,
    "J" => 11,
    "Q" => 12,
    "K" => 13,
    "A" => 14
  }

  sig{params(str: String).returns(T::Array[Integer])}
  def str_to_numarray(str)
    str.chars.map { |c| ATOI.fetch(c) }
  end

  class Kind < T::Enum
    extend T::Sig
    enums do
      # Five of a kind, where all five cards have the same label: AAAAA
      FiveOfAKind = new
      # Four of a kind, where four cards have the same label: AAAAB
      FourOfAKind = new
      # Full house, where three cards have the same label, and the remaining two
      # cards share a different label: 23332
      FullHouse = new
      # Three of a kind, where three cards have the same label, and the
      # remaining two cards are each different from any other card in the hand:
      # TTT98
      ThreeOfAKind = new
      # Two pair, where two cards share one label, two other cards share a
      # second label, and the remaining card has a third label: 23432
      TwoPair = new
      # One pair, where two cards share one label, and the other three cards
      # have a different label from the pair and each other: A23A4
      OnePair = new
      # High card, where all cards' labels are distinct: 23456
      HighCard = new
    end

    sig {returns(Integer)}
    def ord
      case self
      when FiveOfAKind
        7
      when FourOfAKind
        6
      when FullHouse
        5
      when ThreeOfAKind
        4
      when TwoPair
        3
      when OnePair
        2
      when HighCard
        1
      end
    end

    sig {params(str: String).returns(T.nilable(Kind))}
    def self.for_str(str)
      cs = str.chars
      cs_uniq = cs.uniq
      tally = cs.tally

      if cs_uniq.size == 5
        return Kind::HighCard
      end
      
      three_of_a_kind = T.let(nil, T.nilable(String))
      two_of_a_kind = T::Array[String].new
      tally.each do |k, count|
        if count == 5
          return Kind::FiveOfAKind
        elsif count == 4
          return Kind::FourOfAKind
        elsif count == 3
          three_of_a_kind = k
        elsif count == 2
          two_of_a_kind << k
        end
      end

      if three_of_a_kind && two_of_a_kind.empty?
        return Kind::ThreeOfAKind
      elsif three_of_a_kind
        return Kind::FullHouse
      end

      count_to_keys = tally.group_by{_2}.transform_values {|v| v.map{_1[0]}}
      if two_of_a_kind.size == 2
        return Kind::TwoPair
      end

      if two_of_a_kind.size == 1 && (cs_uniq - [two_of_a_kind.fetch(0)]).size == 3
        return Kind::OnePair
      end

      return nil
    end
  end

  def test
    expected = {
      "AAAAA" => Kind::FiveOfAKind,
      "AA8AA" => Kind::FourOfAKind,
      "23332" => Kind::FullHouse,
      "TTT98" => Kind::ThreeOfAKind,
      "23432" => Kind::TwoPair,
      "A23A4" => Kind::OnePair,
      "23456" => Kind::HighCard,
    }
    actual = expected.keys.map { |k| [k, Kind.for_str(k)] }.to_h
    if expected != actual
      puts("Got #{JSON.pretty_generate(actual)}")
      exit(1)
    end
  end

  EG1 = 6440
  def one
    test

    bids = T::Hash[String, Integer].new

    @data.each do |line|
      hand, bid = line.scanf("%s %d")
      bids[hand] = bid
    end

    ordered_bids = bids.keys.sort do |a, b|
      kind_a = Kind.for_str(a)&.ord || 0
      kind_b = Kind.for_str(b)&.ord || 0
      cmp = kind_a <=> kind_b
      if cmp != 0
        next cmp
      end
      str_to_numarray(a) <=> str_to_numarray(b)
    end

    winnings = ordered_bids.each_with_index.map do |key, rank|
      bids[key] * (rank + 1)
    end.inject(&:+)
  end

  EG2 = 0
  def two
    0
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
