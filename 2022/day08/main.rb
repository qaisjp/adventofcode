# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'

# AoC
class AoC
  def initialize(data)
    y = -1
    @rows = data.map do |line|
      x = -1
      y += 1
      line.chars.map do |c|
        x += 1
        [c.to_i, [y, x]]
      end
    end
  end

  def printg(g)
    puts
    puts g.map {|cells| cells.map(&:first).join}.join("\n")
    puts
  end

  def rotate_clockwise(g)
    g.transpose.reverse
  end

  def find_points(g)
    points = {}
    g.each do |cells|
      nowp = {}

      # left to right
      max = -1
      cells.each do |p|
        v, coords = p
        if v > max
          # we've hit this point
          nowp[coords] = true
        end
        max = [v, max].max
      end

      # right to left
      max = -1
      cells.reverse.each do |p|
        v, coords = p
        if v > max
          # we've hit this point
          nowp[coords] = true
          max = v
        end
      end

      points.merge!(nowp)

      puts("For line #{cells.map(&:first).join}, points are #{nowp}")
    end
    points
  end

  EG1 = 21
  def one
    result = {}
    g = @rows
    [0, 90, 180, 270].each do |deg|
      puts
      puts("== Rotated #{deg} degrees")
      printg(g)
      result.merge!(find_points(g))
      g = rotate_clockwise(g)
    end
    
    result.size
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
