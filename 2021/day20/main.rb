# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'

module CoordSystem
  def x; self[0]; end
  def x=(other); self[0] = other; end
  def y; self[1]; end
  def y=(other); self[1] = other; end
  def z; self[2]; end
  def z=(other); self[2] = other; end
end

class Array; include CoordSystem; end

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @algo = data.shift.chars.map {_1 == "#"}
    data.shift
    @grid = Hash.new(false)
    data.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        @grid[[x, y]] = char == '#'
      end
    end
  end

  # . . .
  # . . .  <<- coordinate to affect (x-1, y-1)
  # . . .
  #     ^ (x=2, y=2)

  def adjacents(coord)
    [
      [coord.x - 1, coord.y - 1], # Top left
      [coord.x, coord.y - 1], # Top middle
      [coord.x + 1, coord.y - 1], # Top right

      [coord.x - 1, coord.y], # Middle left
      [coord.x, coord.y], # Middle middle
      [coord.x + 1, coord.y], # Middle right

      [coord.x - 1, coord.y + 1], # Bottom left
      [coord.x, coord.y + 1], # Bottom middle
      [coord.x + 1, coord.y + 1], # Bottom right
    ]
  end

  def transform(grid, default=false)
    new_grid = Hash.new(default)
    puts "Next grid default is #{default}"
    coords = grid.keys

    coords.flat_map {adjacents(_1)}.uniq.each do |coord|
      x, y = coord
      coords = adjacents(coord)
      index = coords.map {grid[_1] ? 1 : 0}.join("").to_i(2)
      new_grid[[x, y]] = @algo.fetch(index)
    end
    new_grid
  end

  def one(test=false)
    transform(transform(@grid, !test)).values.count {_1}
  end

  def two(test=false)
    grid = @grid
    next_is_on = false
    50.times do
      next_is_on = !next_is_on unless test
      grid = transform(grid, next_is_on)
    end
    grid.values.count {_1}
  end
end

def test(part)
  examples = [
    35,
    3351,
  ]

  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one(true)
  this = examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two(true)
    this = examples.last
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
