# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

Grid = T.type_alias {T::Hash[Integer, T::Hash[Integer, T::Hash[Integer, T::Hash[Integer, T::Boolean]]]]}
Coord = T.type_alias {[Integer, Integer, Integer, Integer]}

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
    @min_w = T.let(0, Integer)

    @max_x = T.let(0, Integer)
    @max_y = T.let(0, Integer)
    @max_z = T.let(0, Integer)
    @max_w = T.let(0, Integer)

    @offsets = T.let([-1, 1, 0].repeated_permutation(4).reject {|ox, oy, oz, ow| ox == 0 && oy == 0 && oz == 0 && ow == 0}, T::Array[Coord])
  end

  # sig {params(coord: Coord).returns(T::Array[Coord])}
  def neighbours(coord)
    @offsets.map {|off| [coord[0] + off[0], coord[1] + off[1], coord[2] + off[2], coord[3] + off[3]]}
  end

  # sig {params(x: Integer, y: Integer, z: Integer, w: Integer).void}
  def resize(x, y, z, w)
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
    if w > @max_w
      @max_w = w
    elsif x < @min_w
      @min_w = w
    end
  end

  # sig {params(x: Integer, y: Integer, z: Integer, w: Integer).returns(T::Boolean)}
  def get(x, y, z, w)
    resize(x, y, z, w)
    @grid[w] ||= {}
    @grid.fetch(w)[z] ||= {}
    @grid.fetch(w).fetch(z)[y] ||= {}
    @grid.fetch(w).fetch(z).fetch(y)[x] ||= false
    @grid.fetch(w).fetch(z).fetch(y).fetch(x)
  end

  # sig {params(x: Integer, y: Integer, z: Integer, w: Integer).returns(T::Boolean)}
  def get_raw(x, y, z, w)
    @grid[w] && @grid[w][z] && @grid[w][z][y] && @grid[w][z][y][x]
  end

  # sig {params(x: Integer, y: Integer, z: Integer, w: Integer, val: T::Boolean).void}
  def set(x, y, z, w, val)
    resize(x, y, z, w)
    @grid[w] ||= {}
    @grid.fetch(w)[z] ||= {}
    @grid.fetch(w).fetch(z)[y] ||= {}
    @grid.fetch(w).fetch(z).fetch(y)[x] = val
  end

  # sig {params(data: T::Array[String]).void}
  def read_2d_grid!(data)
    data.each_with_index do |xs, y|
      xs.chars.each_with_index do |char, x|
        # puts "#{x}, #{y}, #{z} is #{char}"
        set(x, y, 0, 0, char == '#')
      end
    end
  end

  # Todo
  # sig {void}
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
  # sig {params(blk: T.proc.params(coord: Coord, val: T::Boolean).void).void}
  def each_coord(&blk)
    # Consider the bordering layer
    # We pre-calculate this for reasons described in part 1, but those reasons don't apply in part 2 (because we added get_raw)
    min_x = @min_x - 1
    min_y = @min_y - 1
    min_z = @min_z - 1
    min_w = @min_w - 1
    max_x = @max_x + 1
    max_y = @max_y + 1
    max_z = @max_z + 1
    max_w = @max_w + 1

    (min_w..max_w).each do |w|
      (min_z..max_z).each do |z|
        (min_y..max_y).each do |y|
          (min_x..max_x).each do |x|
            yield [x, y, z, w], get_raw(x, y, z, w)
          end
        end
      end
    end
  end

  sig{params(changes: T::Hash[Coord, T::Boolean]).void}
  def apply_changes(changes)
    changes.each do |coord, val|
      set(coord[0], coord[1], coord[2], coord[3], val)
    end
  end

  def one
    read_2d_grid!(@data)

    puts "Before any cycles:\n"
    # print_2d_grid!

    total_iters = 6
    iter = 1
    while iter <= total_iters
      changes = {}

      each_coord do |coord, val|
        # puts "Coord #{coord} is #{val}. Checking neighbours..."
        active_neighbours = neighbours(coord).count do |nbor|
          active = get(nbor[0], nbor[1], nbor[2], nbor[3])
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
