# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class Array
  extend T::Sig

  def x; T.unsafe(self)[0]; end
  def x=(v); T.unsafe(self)[0] = v; end

  def y; T.unsafe(self)[1]; end
  def y=(v); T.unsafe(self)[1] = v; end

  def z; T.unsafe(self)[2]; end
  def z=(v); T.unsafe(self)[2] = v; end
end

module T::Array
  extend T::Sig

  def x; T.unsafe(self)[0]; end
  def x=(v); T.unsafe(self)[0] = v; end

  def y; T.unsafe(self)[1]; end
  def y=(v); T.unsafe(self)[1] = v; end

  def z; T.unsafe(self)[2]; end
  def z=(v); T.unsafe(self)[2] = v; end
end

Grid = T.type_alias {T::Hash[Integer, T::Hash[Integer, T::Hash[Integer, T::Boolean]]]}
Coord = T.type_alias {[Integer, Integer, Integer]}

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])

    @grid = T.let({}, Grid)

    @min_x = T.let(0, Integer)
    @min_y = T.let(0, Integer)
    @min_z = T.let(0, Integer)

    @max_x = T.let(0, Integer)
    @max_y = T.let(0, Integer)
    @max_z = T.let(0, Integer)

    @offsets = T.let([-1, 1, 0].repeated_permutation(3).reject {|ox, oy, oz| ox == 0 && oy == 0 && oz == 0}, T::Array[Coord])
  end

  sig {params(coord: Coord).returns(T::Array[[Integer, Integer, Integer]])}
  def neighbours(coord)
    @offsets.map {|off| [coord.x + off.x, coord.y + off.y, coord.z + off.z]}
  end

  sig {params(x: Integer, y: Integer, z: Integer).void}
  def resize(x, y, z)
    if x > @max_x
      @max_x = x
    elsif x < @min_x
      @min_x = x
    end
    if y > @max_y
      @max_y = y
    elsif x < @min_y
      @min_y = y
    end
    if z > @max_z
      @max_z = z
    elsif x < @min_z
      @min_z = z
    end
  end

  sig {params(x: Integer, y: Integer, z: Integer).returns(T::Boolean)}
  def get(x, y, z)
    resize(x, y, z)
    @grid[z] ||= {}
    @grid.fetch(z)[y] ||= {}
    @grid.fetch(z).fetch(y)[x] ||= false
    @grid.fetch(z).fetch(y).fetch(x)
  end

  sig {params(x: Integer, y: Integer, z: Integer, val: T::Boolean).void}
  def set(x, y, z, val)
    resize(x, y, z)
    @grid[z] ||= {}
    @grid.fetch(z)[y] ||= {}
    @grid.fetch(z).fetch(y)[x] = val
  end

  sig {params(data: T::Array[String], z: Integer).void}
  def read_2d_grid!(data, z)
    data.each_with_index do |xs, y|
      xs.chars.each_with_index do |char, x|
        # puts "#{x}, #{y}, #{z} is #{char}"
        set(x, y, z, char == '#')
      end
    end
  end

  sig {void}
  def print_2d_grid!
    (@min_z..@max_z).each do |z|
      puts "\nz=#{z}"
      (@min_y..@max_y).each do |y|
        line = (@min_x..@max_x).map do |x|
          get(x, y, z) ? '#' : '.'
        end
        puts line.join
      end
    end
  end

  # Each call to each_coord yields for the known range of values, and 1 layer around.
  # This has the side of effect for enlarging the grid every time by 1, every time this is called!
  sig {params(blk: T.proc.params(coord: Coord, val: T::Boolean).void).void}
  def each_coord(&blk)
    # Consider the bordering layer
    # We pre-calculate this, as intermediate get calls will clobber the instance variables to an inconsistent state
    # This state is safe at the end of each_coord
    min_x = @min_x - 1
    min_y = @min_y - 1
    min_z = @min_z - 1
    max_x = @max_x + 1
    max_y = @max_y + 1
    max_z = @max_z + 1

    (min_z..max_z).each do |z|
      (min_y..max_y).each do |y|
        (min_x..max_x).each do |x|
          yield [x, y, z], get(x, y, z)
        end
      end
    end
  end

  sig{params(changes: T::Hash[Coord, T::Boolean]).void}
  def apply_changes(changes)
    changes.each do |coord, val|
      set(coord.x, coord.y, coord.z, val)
    end
  end

  def one
    read_2d_grid!(@data, 0)

    puts "Before any cycles:\n"
    print_2d_grid!

    total_iters = 6
    iter = 1
    while iter <= total_iters
      changes = {}

      each_coord do |coord, val|
        # puts "Coord #{coord} is #{val}. Checking neighbours..."
        active_neighbours = neighbours(coord).count do |nbor|
          active = get(nbor.x, nbor.y, nbor.z)
          # puts "- Neighbour #{nbor} is #{active}"
          active
        end
        # puts "It has #{active_neighbours} neighbours."

        new_val = T.let(nil, T.nilable(T::Boolean))

        if val
          # If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
          new_val = (active_neighbours == 2) || (active_neighbours == 3)
        else
          # If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active. Otherwise, the cube remains inactive.
          new_val = (active_neighbours == 3)
        end

        if !new_val.nil?
          # puts "Setting to #{new_val}"
          changes[coord] = new_val
        end

        # puts 'Pausing until enter...'
        # gets
      end

      apply_changes(changes)

      puts "\nAfter #{iter} cycles"
      # print_2d_grid!

      iter += 1
    end


    count = 0
    each_coord do |_coord, val|
      count += 1 if val
    end
    count
  end

  def two

  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines(chomp: true).to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
