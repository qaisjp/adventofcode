# frozen_string_literal: true
# typed: true

require 'scanf'

# AoC
class AoC
  # extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data, T::Array[String])
    @data = data
  end

  def make_space(grid, x, y)
    (0..y).each do |y|
      grid[y] ||= []
      (0..x).each do |x|
        grid[y][x] ||= 0
      end
    end

    grid
  end

  def print_grid(grid)
    puts
    grid.each do |row|
      puts row.map {_1 == 0 ? "." : _1}.join("")
    end
    puts
  end

  def one
    @grid = []

    @actions = []
    maxX, maxY = 0, 0

    @data.each do |line|
      fromX, fromY, toX, toY = line.scanf("%d,%d -> %d,%d")

      if fromX > toX || fromY > toY
        toX, toY, fromX, fromY = fromX, fromY, toX, toY
      end

      if (n = [fromX, toX].max) > maxX
        maxX = n
      end

      if (n = [fromY, toY].max) > maxY
        maxY = n
      end

      @actions << [fromX, fromY, toX, toY]
    end

    make_space(@grid, maxX, maxY)

    @actions.each do |action|
      fromX, fromY, toX, toY = action

      # if fromX == toX
      #   puts "horizontal line from #{fromX},#{fromY} to #{toX},#{toY}"
      # elsif fromY == toY
      #   puts "vertical line from #{fromX},#{fromY} to #{toX},#{toY}"
      # end

      # make_space(grid, [fromX,toX].max, [fromY,toY].max)

      if fromX == toX || fromY == toY
        (fromX..toX).each do |x|
          (fromY..toY).each do |y|
            begin
              @grid[y][x] += 1
            rescue
              puts "Couldn't put anything in grid at #{x},#{y}"
              row = grid[y]
              puts "Row exist? #{row != nil}"
              puts "Columns in row #{row.size}"
              # print_grid(grid)
              raise
            end
          end
        end
      end
    end
    # print_grid(grid)

    @grid.map {_1.count {|n| n >= 2}}.inject(&:+)
  end

  def two
    @actions.each do |action|
      fromX, fromY, toX, toY = action
      next if fromX == toX || fromY == toY

      x = fromX
      y = fromY
      loop do
        @grid[y][x] += 1

        # hit the end
        if x == toX || y == toY
          # both should be hit
          raise "both not hit" if [x==toX,y==toY] != [true,true]
          break
        end

        if x < toX
          x += 1
        else
          x -= 1
        end

        if y < toY
          y += 1
        else
          y -= 1
        end
      end

    end

    # print_grid(@grid)

    @grid.map {_1.count {|n| n >= 2}}.inject(&:+)
  end
end

$examples = [
  5,
  12,
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
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
