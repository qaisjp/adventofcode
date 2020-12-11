# frozen_string_literal: true

require 'sorbet-runtime'

# AoC
class AoC
  S_EMPTY = "L"
  S_FLOOR = "."
  S_OCCUPIED = "#"

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data.map(&:chars), T::Array[T::Array[String]])
  end

  def get_range(grid, y, x)
    line = nil

    ys = [y.respond_to?(:to_a) ? [y.begin, y.end] : y].flatten
    xs = [x.respond_to?(:to_a) ? [x.begin, x.end] : x].flatten
    return nil if ys.any? {|y| y < 0 || y >= grid.size}
    return nil if xs.any? {|x| x < 0 || x >= grid[0].size}

    reverse_y = false
    reverse_x = false
    if y.is_a?(Range) && y.begin > y.end
      y = (y.end)..(y.begin)
      reverse_y = true
    end
    if x.is_a?(Range) && x.begin > x.end
      x = (x.end)..(x.begin)
      reverse_x = true
    end

    if x.is_a?(Range) && y.is_a?(Range)
      y_size = y.size
      x_size = x.size
      offset = (y_size - x_size).abs
      if y_size > x_size
        if reverse_y
          y = (y.begin+offset)..y.end
        else
          y = y.begin..(y.end - offset)
        end
      elsif x_size > y_size
        if reverse_x
          x = (x.begin+offset)..x.end
        else
          x = x.begin..(x.end - offset)
        end
      end

      if x.size != y.size
        puts "x.size: #{x.size}; y.size: #{y.size}; x: #{x}. y: #{y}."
        raise
      end
      y = y.to_a
      y = y.reverse if reverse_y

      x = x.to_a
      x = x.reverse if reverse_x

      line = y.zip(x).map {|pair| grid[pair[0]][pair[1]]}
    elsif y.is_a? Range
      cols = grid[y]
      cols = cols.reverse if reverse_y
      line = cols.map {|sub| sub[x]}
    elsif x.is_a? Range
      line = grid[y][x]
      line = line.reverse if reverse_x
    else
      return grid[y][x]
    end

    line.join("")
  end

  def apply_grid_rules_1(grid)
    new_line = ""

    new_grid = []
    grid.size.times {|y| new_grid[y] = []}

    grid.each_with_index do |row, y|
      row.each_with_index do |c, x|
        c = grid[y][x]
        adjacent_indices = [
          [y, x-1],
          [y, x+1],
          [y-1, x],
          [y+1, x],

          [y-1, x-1],
          [y-1, x+1],
          [y+1, x-1],
          [y+1, x+1],


          # [y+1..y+4, x+1..x+4],
          # [y-4..y-1, x+1..x+4],
          # [y+1..y+4, x-4..x-1],
          # [y-4..y-1, x-4..x-1],

          # [y+1, x],
          # [y-1, x],
          # [y, x+1],
          # [y, x-1],

        ]
        adjacents = adjacent_indices.map {|pair| get_range(grid, pair[0], pair[1])}

        new_c = c
        if c == S_EMPTY && !adjacents.include?(S_OCCUPIED)
          new_c = S_OCCUPIED
        elsif c == S_OCCUPIED && adjacents.count(S_OCCUPIED) >= 4
          new_c = S_EMPTY
        end

        new_grid[y][x] = new_c
      end
    end

    new_grid
  end

  def apply_grid_rules_2(grid)
    new_line = ""

    new_grid = []
    grid.size.times {|y| new_grid[y] = []}

    max_y = grid.size - 1
    max_x = grid[0].size - 1

    grid.each_with_index do |row, y|
      row.each_with_index do |c, x|
        c = grid[y][x]
        adjacent_indices = [
          [y+1..max_y, x], # all down
          [y-1..0, x], # all up
          [y, x+1..max_x], # all right
          [y, x-1..0], # all left

          [y+1..max_y, x+1..max_x], ## all downright
          [y+1..max_y, x-1..0], # all downleft
          [y-1..0, x+1..max_x], ## all upright
          [y-1..0, x-1..0], ## all upleft

        ]
        adjacents = adjacent_indices.map do |y,x|
          raw_chars = get_range(grid, y, x)
          next nil if raw_chars.nil?
          first_visible = raw_chars.gsub(".", "")
          if first_visible == ""
            first_visible = "."
          end
          first_visible[0]
        end

        # puts "y: #{y}; x: #{x}; c: #{c}; #{adjacent_indices.zip(adjacents).to_h}" if c == "L"
        new_c = c
        if c == S_EMPTY && !adjacents.include?(S_OCCUPIED)
          new_c = S_OCCUPIED
        elsif c == S_OCCUPIED && adjacents.count(S_OCCUPIED) >= 5
          new_c = S_EMPTY
        end

        new_grid[y][x] = new_c
      end
    end

    new_grid
  end

  def print_grid
    @data.each do |x|
      puts "#{x.join("")}"
    end
  end

  def one(is_one)
    with_print = false
    puts "Initial" if with_print
    print_grid if with_print

    if is_one
      m = self.method("apply_grid_rules_1")
    else
      m = self.method("apply_grid_rules_2")
    end

    round = 0
    loop do
      previous = @data
      puts("\n\nRound #{round+1}") if with_print
      @data = m.call(@data)
      print_grid if with_print
      round += 1
      if previous == @data
        puts("\nYep, steady state!")
        break
      end
    end

    @data.flatten.join("").count(S_OCCUPIED)
  end

  def two

  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines(chomp:true).to_a

  if n == '1'
    puts "Result: #{runner.one(true)}"
  elsif n == '2'
    puts "Result: #{runner.one(false)}"
  end
end
main
