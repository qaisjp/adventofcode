# frozen_string_literal: true

require 'sorbet-runtime'

# AoC
class AoC
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @seed = T.let(data, T::Array[Integer])
    @spoken_history = {}

    puts "\n\nInput: #{@seed}"
  end

  def one(nth: 2020)
    turn = 0
    last_spoken = nil
    @seed.each do |n|
      turn += 1
      @spoken_history[n] = [turn, nil]
      last_spoken = n
    end

    while turn < nth
      prevs = @spoken_history[last_spoken]
      if prevs[1].nil?
        next_speak = 0
      else
        next_speak = prevs[0] - prevs[1]
      end

      turn += 1

      x = @spoken_history[next_speak]
      if x.nil?
        @spoken_history[next_speak] = [turn, nil]
      else
        x[0], x[1] = turn, x[0]
      end

      last_spoken = next_speak
    end
    last_spoken
  end

  def two

  end
end

def musteq(real, expected)
  if real != expected
    raise "Expected #{expected}, got #{real}"
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines(chomp: true).first.split(",").map(&:to_i)

  if n == '1'
    musteq(AoC.new([1,3,2]).one, 1)
    musteq(AoC.new([2,1,3]).one, 10)
    musteq(AoC.new([1,2,3]).one, 27)
    musteq(AoC.new([2,3,1]).one, 78)
    musteq(AoC.new([3,2,1]).one, 438)
    musteq(AoC.new([3,1,2]).one, 1836)

    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.one(nth: 30000000)}"
  end
end
main
