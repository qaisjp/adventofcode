# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'term/ansicolor'

module Kernel
  alias_method :print_orig, :print
  alias_method :puts_orig, :puts

  attr_accessor :shush
  @shush = false

  # def print(s=nil)
  #   return if shush
  #   print_orig(s)
  # end
  # def puts(s=nil)
  #   return if shush
  #   puts_orig(s)
  # end
end

# AoC
class AoC
  include Term::ANSIColor

  def initialize(data)
    @size = data.size
    y = -1
    @rows = data.map do |line|
      x = -1
      y += 1
      line.chars.map do |c|
        x += 1
        [c.to_i, [y, x]]
      end
    end

    @grids = [@rows]
    3.times do
      @grids << rotate_anticlockwise(@grids.last)
    end
  end

  def printg(g, bold: nil)
    # return if Kernel.shush
    puts(g.each_with_index.map do |cells, y|
      cells.each_with_index.map do |pair, x|
        if bold == [y, x]
          bold(red(pair.first.to_s))
        else
          pair[0]
        end
      end.join
    end.join("\n"))
  end

  def rotate_anticlockwise(g)
    g.transpose.reverse
  end
  def move_coordinate_anticlockwise(y, x)
    [@size - 1 - x, y]
  end

  # part 1
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
    degrees = [0, 90, 180, 270]
    @grids.each_with_index do |g, deg|
      puts
      puts("== Rotated #{degrees[deg]} degrees")
      puts
      printg(g)
      puts
      result.merge!(find_points(g))
    end
    
    result.size
  end

  # part 2
  def score(y, start_x)
    degrees = [0, 90, 180, 270]
    src_coord = [y, start_x]
    score = 1
    puts
    puts
    puts("-----------------------------------------")
    puts("For src_coord #{src_coord}")
    @grids.each_with_index do |g, deg|
      puts
      print("== Rotated #{degrees[deg]} degrees")

      pointcount = 0
      this_height, orig_coord = g[y][start_x]
      raise "??? coord mismatch" unless orig_coord == src_coord
      puts(": #{this_height} at #{[y, start_x]}")
      max_seen = -1

      # printg is too expensive
      # printg(g, bold: [y, start_x])

      print("Looking at ")
      startn = (start_x+1)
      if @size == startn
        print(italic{"<hit end>"})
      end
      (startn...@size).each do |x|
        v, coords = g[y][x]
        pointcount += 1
        if v >= this_height
          print(bright_red {v})
          break
        else
          print(bright_green {v})
        end
      end
      y, start_x = move_coordinate_anticlockwise(y, start_x)
      puts(reset)
      puts("Points seen: #{pointcount}")

      score *= pointcount
    end
    puts
    puts("Score: #{score}")
    score
  end

  EG2 = 8
  def two
    points = []
    @size.times do |y|
      @size.times do |x|
        points << score(y, x)
      end
    end
    points.max
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
  with_shush = true

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

  puts "\n\n--- Part #{n} solution" if n != nil
  if n == '1' || (run_both && n == '2')
    Kernel.shush = with_shush
    v = runner.one
    Kernel.shush = false
    puts "Result 1: #{v}"
  end
  if n == '2'
    Kernel.shush = with_shush
    v = runner.two
    Kernel.shush = false
    puts "Result 2: #{v}"
  end
end

main
