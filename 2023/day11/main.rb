# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'

# add y,x support to Array
class Array
  def y
    self[0]
  end

  def y=(other)
    self[0] = other
  end

  def x
    self[1]
  end

  def x=(other)
    self[1] = other
  end
end

# AoC
class AoC
  extend T::Sig
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data.first, String)
    @grid = T.let(data.map(&:chars), T::Array[T::Array[String]])
  end

  EG1 = 374
  def one
    row_size = T.must(@grid.first&.size)

    # Add extra blank rows
    @grid = @grid.flat_map do |row|
      if row.all? {_1 == "."}
        [row, row.dup]
      else
        [row]
      end
    end

    @grid = @grid.transpose

    # Add extra blank rows (again)
    @grid = @grid.flat_map do |row|
      if row.all? {_1 == "."}
        [row, row.dup]
      else
        [row]
      end
    end

    @grid = @grid.transpose


    galaxy_positions = T::Set[[Integer, Integer]].new
    @grid.each_with_index do |row, y|
      row.each_with_index do |val, x|
        if val != "."
          galaxy_positions << [y, x]
        end
      end
    end

    puts("galaxy_positions: #{galaxy_positions}")

    result = galaxy_positions.to_a.combination(2).map do |(y1, x1), (y2, x2)|
      # Distance
      # puts("Seen #{y1},#{x1} and #{y2},#{x2}")
      (y1 - y2).abs + (x1 - x2).abs
    end.sum

    # print_grid(@grid, [])

    result
  end

  def print_grid(grid, highlighted_coords)
    map = {
      "L" => "┗",
      "J" => "┛",
      "F" => "┏",
      "7" => "┓",
      "|" => "┃",
      "-" => "━",
      # "." => ".",
      # "S" => "S",
      # "?" => "?",
    }
    puts("Printing grid")
    grid.each_with_index do |xs, y|
      xs.each_with_index do |val, x|
        hilite = highlighted_coords.include?([y, x])
        print("\e[0;36m") if hilite
        print(map[val] || val)
        print("\e[0m") if hilite
      end
      print("\n")
    end
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
  run_both = T.let(false, T::Boolean)

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
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
