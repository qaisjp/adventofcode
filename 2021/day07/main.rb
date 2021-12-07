# frozen_string_literal: true
# typed: true

# AoC
class AoC

  def initialize(data)
    @data = data.first.split(",").map(&:to_i)
  end

  def one
    (0..@data.uniq.max).map do |align_to|
      @data.sum do |x|
        (align_to - x).abs
      end
   end.min
  end

  def two
    (0..@data.uniq.max).map do |align_to|
      @data.sum do |x|
        n = (align_to - x).abs
        ((n**2)+n) / 2
      end
   end.min
  end
end

$examples = [
  37,
  168,
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
