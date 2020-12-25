# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(doorkey, cardkey)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @doorkey = doorkey
    puts "Door public key: #{@doorkey}"
    @cardkey = cardkey
    puts "Card public key: #{@cardkey}"
  end

  def bruteforce_7(pubkey)
    sn = 7
    v = 1
    loopsize = 0
    loop do
      loopsize += 1

      v *= sn
      v = v % 20201227

      break if v == pubkey
    end

    loopsize
  end

  def transform(sn, loops)
    v = 1
    loops.times do
      v *= sn
      v = v % 20201227
    end
    v
  end

  def one
    loopsizes = {
      door: bruteforce_7(@doorkey),
      card: bruteforce_7(@cardkey),
    }
    puts "loopsizes: #{loopsizes}"
    card = transform(@cardkey, loopsizes[:door])
    # door = transform(@doorkey, loopsizes[:card])
    # [card, door]
  end

  def two

  end
end

def main
  n = ARGV.shift
  runner = AoC.new(*ARGF.readlines(chomp: true).to_a.map(&:to_i))

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
