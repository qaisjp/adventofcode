# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class AoC
  extend T::Sig

  def initialize(data, preamble_size, previous_numbers)
    @numbers = data.map(&:to_i)
    @preamble_size = T.let(preamble_size.to_i, Integer)
    @previous_numbers = T.let(previous_numbers.to_i, Integer)
    puts "preamble: #{preamble_size}"
    puts "previous_numbers: #{previous_numbers}"
  end

  sig {params(range: T::Array[Integer], n: Integer).returns(T::Boolean)}
  def is_summable(range, n)
    range.each do |x|
      range.each do |y|
        if (x != y) && ((x + y) == n)
          return true
        end
      end
    end
    false
  end

  def one
    @numbers.each_with_index do |current_number, i|
      next if i < @preamble_size
      min = i - @previous_numbers
      max = i - 1
      if !is_summable(@numbers[min..max], current_number)
        return current_number
      end
    end
  end

  def two
    n = one
    @numbers.size.times.each do |j|
      @numbers.size.times.each do |k|
        next if k <= j

        set = @numbers[j..k]
        if set.sum == n
          puts "smallest: #{set.min}"
          puts "largest: #{set.max}"
          puts "sum: #{set.min + set.max}"
        end
      end
    end
  end
end

def main
  n = ARGV.shift
  preamble_size = ARGV.shift
  previous_numbers = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a, preamble_size, previous_numbers

  if n == '1'
    puts runner.one
  else
    runner.two
  end
end
main
