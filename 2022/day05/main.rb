# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'

# AoC
class AoC


  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  EG1 = "CMZ"
  EGSTACK = [
    %w[N Z],
    %w[D C M],
    %w[P]
  ]
  MAINSTACK = [
    %w[B S J Z V D G],
    %w[P V G M S Z],
    %w[F Q T W S B L C],
    %w[Q V R M W G J H],
    %w[D M F N S L C],
    %w[D C G R],
    %w[Q S D J R T G H],
    %w[V F P],
    %w[J T S R D]
  ]
  def one(example: false)
    moves_started = false
    stack = (if example then EGSTACK else MAINSTACK end).map(&:dup)
    @data.each do |line|
      if line == ""
        moves_started = true
      elsif moves_started
        # puts(line)
        count, from, to = line.scanf("move %d from %d to %d")
        from -= 1
        to -= 1
        
        # puts("Moving #{stack[from][...count]}")
        stack[to] = stack[from][...count].reverse + stack[to]
        stack[from] = stack[from][count..]
      end
    end
    stack.map(&:first).join
  end

  EG2 = "MCD"
  def two(example: false)
    moves_started = false
    stack = (if example then EGSTACK else MAINSTACK end).map(&:dup)
    @data.each do |line|
      if line == ""
        moves_started = true
      elsif moves_started
        # puts(line)
        count, from, to = line.scanf("move %d from %d to %d")
        from -= 1
        to -= 1
        
        # puts("Moving #{stack[from][...count]}")
        stack[to] = stack[from][...count] + stack[to]
        stack[from] = stack[from][count..]
      end
    end
    stack.map(&:first).join
  end
end

def test(part)
  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one(example: true)
  this = AoC::EG1
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two(example: true)
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
  run_both = false

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

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
