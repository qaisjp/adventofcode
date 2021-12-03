# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class Array
  def most_common
    self.group_by(&:itself).values.max_by(&:size).first
  end
  def least_common
    self.group_by(&:itself).values.min_by(&:size).first
  end
end

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])
  end

  def places(data)
    arr = Array.new(data.first.size) {[]}
    data.each do |line|
      line.split("").each_with_index do |n, i|
        arr[i].push(n)
      end
    end
    arr
  end

  def one
    nums = places(@data)

    # from https://stackoverflow.com/questions/2562256/find-most-common-string-in-an-array
    gamma = nums.map(&:most_common).join("")
    power = nums.map(&:least_common).join("")

    Integer("0b#{gamma}") * Integer("0b#{power}")
  end

  def opposite(m)
    if m == :most_common
      :least_common
    else
      :most_common
    end
  end

  def find_rating(m)
    data = @data.dup

    data.first.size.times do |bit_pos|
      bit_nums = places(data)[bit_pos]
      popular_bit_num = bit_nums.method(m).call
      unpopular_bit_num = bit_nums.method(opposite(m)).call

      # manually set the number if both are "0"
      if popular_bit_num == unpopular_bit_num
        if m == :most_common
          popular_bit_num = "1"
        else
          popular_bit_num = "0"
        end
      end

      # puts "bit place #{bit_pos}, most common #{popular_bit_num}"
      data.filter! do |s|
        s[bit_pos] == popular_bit_num
      end

      if data.empty?
        raise "Ran out of numbers — bit_pos #{bit_pos}"
      elsif data.size == 1
        return data.first
      else
        # puts data.inspect
      end
    end
  end

  def two
    oxygen = find_rating(:most_common)
    c02 = find_rating(:least_common)
    puts oxygen
    puts c02

    Integer("0b#{oxygen}") * Integer("0b#{c02}")
  end
end

$examples = [
  198,
  230,
]

def test(part)
  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = $examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = $examples[1]
    if two != this
      puts "\n\nExample part 2 was #{two}, expected #{this}"
    else
      puts "\n\nExample part 2 passes (#{this})"
    end
  end
end

def main
  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  test(n)

  puts "\n\n--- Part #{n} solution"
  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end

main
