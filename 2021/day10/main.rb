# frozen_string_literal: true
# typed: true

# AoC
class AoC

  Opener = ["(", "[", "{", "<"]
  Closer = [")", "]", "}", ">"]
  Points = {
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
  }
  AutoPoints = {
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4,
  }

  def initialize(data)
    @data = data
    @incomplete_lines = []
  end

  def one
    invalid_chars = []
    @data.each do |line|
      stack = []

      invalid = false
      line.chars.each_with_index do |c, i|
        if Opener.index(c)
          stack << c
          next
        end

        ci = Closer.index(c)
        raise "unknown char" unless ci

        top = stack.pop
        if (ti = Opener.index(top))
          if ti != ci
            # puts "Got closer #{c}, but top of stack was #{top}"
            invalid_chars << c
            invalid = true
            break
          end
          # closing the stack, nothing to do
        elsif (ti = Closer.index(top))
          invalid_chars << c
          invalid = true
          break
        end
      end

      @incomplete_lines << stack.join unless invalid
    end

    invalid_chars.map {Points[_1]}.sum
  end

  def two
    scores = []
    @incomplete_lines.each do |line|
      chars = line.chars

      score = 0
      while !chars.empty?
        top = chars.pop # top is always an opener
        closer = Closer[Opener.index(top)]

        score *= 5
        score += AutoPoints[closer]
      end

      scores << score
    end

    scores.sort[scores.size/2]
  end
end

$examples = [
  26397,
  288957,
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
  if n == '1' || n == '2'
    puts "Part 1 Result: #{runner.one}"
  end

  if n == '2'
    puts "Part 2 Result: #{runner.two}"
  end
end

main
