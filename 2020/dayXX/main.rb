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
  end

  def two

  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
