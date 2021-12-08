# frozen_string_literal: true
# typed: true

# AoC


class AoC

  @@count_to_digit = {
    3 => 7,
    4 => 4,
    2 => 1,
    7 => 8,
  }

  def initialize(data)
    # @data = data.map(&:to_i)
    @data = data.map do |line|
      input, output = line.split("|").map {_1.strip}
      [input.split, output.split]
    end
  end

  def one
    count = 0
    @data.each do |line|
      input, output = line
      # puts "output: #{output}"
      this_count = output.count do
        size = _1.size
        # puts "size of #{_1} is #{size}"
        @@count_to_digit[size] != nil
      end
      # puts "count: #{this_count}"
      count += this_count
    end

    count
  end

  def two

    1
  end
end

$examples = [
  26,
  0,
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
