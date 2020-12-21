# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'scanf'

class Complex
  def x
    self.real
  end
  def y
    self.imag
  end
end

class String
  def last
    self[-1]
  end

  def first
    self[0]
  end
end

class Array
  def top
    self[0]
  end
  def right
    self[1]
  end
  def bottom
    self[2]
  end
  def left
    self[3]
  end
  def top=(v)
    self[0] = v
  end
  def right=(v)
    self[1] = v
  end
  def bottom=(v)
    self[2] = v
  end
  def left=(v)
    self[3] = v
  end

  def flip_edges(op)
    if op == 'none'
      self.dup
    elsif op == 'vert'
      [self.bottom, self.right.reverse, self.top, self.left.reverse]
    elsif op == 'horz'
      [self.top.reverse, self.left, self.bottom.reverse, self.right]
    else
      raise "huh #{op}"
    end
  end

  def flip_both(op1, op2)
    self.flip_edges(op1).flip_edges(op2)
  end
end

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    @tile_rows = {}
    data.split("\n\n").each do |tiles|
      rows = tiles.split("\n")
      key = rows[0].scanf("Tile %d:")[0]
      @tile_rows[key] = rows[1..]
    end

    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data, T::Array[String])

    @min_x = 0
    @min_y = 0
    @max_x = 0
    @max_y = 0

    @pos_to_tile = {}
    @tiles_to_pos = {}

    @directions = 4.times.to_a
    @opp_directions = @directions.rotate(2)
    @direction_words = ["top   ", "right ", "bottom", "left  "]
    @opp_direction_words = @direction_words.rotate(2)
  end

  def dir_word(dir, opp: false, wide: false)
    word = (opp ? @opp_direction_words : @direction_words)[dir]
    word = word.strip unless wide
    word
  end

  def pos_direction(pos, direction)
    if direction == 0
      pos += 1i
    elsif direction == 1
      pos += 1
    elsif direction == 2
      pos -= 1i
    elsif direction == 3
      pos -= 1
    end
    pos
  end

  def set_tile_pos(tile, pos)
    @pos_to_tile[pos] = tile
    @tiles_to_pos[tile] = pos
    @min_x = [@min_x, pos.x].min
    @min_y = [@min_y, pos.y].min
    @max_x = [@max_x, pos.x].max
    @max_y = [@max_y, pos.y].max
  end

  def build_tile_edges!
    @tile_edges = @tile_rows.map do |id, rows|

      [id, get_tile_edges(rows)]
    end.to_h
  end

  def get_tile_edges(rows)
    top = rows[0]
    right = rows.map(&:last).join("")
    bottom = rows[-1]
    left = rows.map(&:first).join("")
    [top, right, bottom, left]
  end

  def does_tile_fit(our_id:, our_edge:, their_id:, their_direction:)
    # Try all rotations
    4.times do |rotate_index|
      # Try all pairs of mirroring
      ["none", "vert", "horz"].repeated_combination(2).each do |flip1, flip2|
        # puts "\n\nReal tile:\n\n"
        # puts @tile_rows[their_id].join("\n")

        other_edges = @tile_edges[their_id].rotate(rotate_index).flip_both(flip1, flip2)

        other_tile = flip_tile(flip_tile(rotate_tile(@tile_rows[their_id], rotate_index), flip1), flip2)
        real_other_edges = get_tile_edges(other_tile)
        # puts "#{rotate_index}, #{flip1}, #{flip2} - #{other_edges == real_other_edges} #{other_edges}, #{real_other_edges}"

        rotated_edges = @tile_edges[their_id].rotate(rotate_index)
        full_rotated_edges = get_tile_edges(rotate_tile(@tile_rows[their_id], rotate_index))
        puts "#{rotate_index}, #{flip1}, #{flip2} - #{rotated_edges == full_rotated_edges} - edges: #{rotated_edges}, full_rotated_edges: #{full_rotated_edges}"
        # puts "\n\nReal tile:\n\n"
        # puts @tile_edges[their_id].join("\n")
        # exit(1)


        if our_edge == other_edges[their_direction]
          # puts "FOUND1: rot(#{rotate_index}), flip(#{flip1}, #{flip2})"
          # puts "#{their_id} is placed #{dir_word(their_direction, opp: true)} to #{our_id}"
          @tile_edges[their_id] = other_edges
          @tile_ops[their_id] = [rotate_index, flip1, flip2]
          puts "ops for #{their_id} are #{rotate_index}, #{flip1}, #{flip2}"
          return true
        end
      end
    end

    return false
  end

  def bruteforce_find(our_id:, direction:)
    # puts "\n## Looking #{dir_word(direction)} of #{our_id}\n\n"
    our_edge = @tile_edges[our_id][direction]
    their_direction = @opp_directions[direction]

    @tiles_to_search.each do |their_id|
      fits = does_tile_fit(
        our_id: our_id,
        our_edge: our_edge,
        their_id: their_id,
        their_direction: their_direction
      )
      if fits
        return their_id
      end
    end
    return nil
  end

  def one
    tile_count = @tile_rows.size
    tiles_per_row = Math.sqrt(tile_count).to_i
    puts "There are #{tile_count} tiles, tiles_per_row is #{tiles_per_row}"

    @tile_ops = {}
    @tiles_to_search = []
    @op_tree = {}
    build_tile_edges!
    @tile_rows.map do |id, _|
      @tiles_to_search << id
      @tile_ops[id] = []

    end

    pos = 0 + 0i
    first_tile = @tiles_to_search.shift
    set_tile_pos(first_tile, pos)
    @tile_ops[first_tile] = [0, 'none', 'none']
    @op_tree[first_tile] = []

    iters = 0
    @positions_to_process = [0 + 0i]
    while !@positions_to_process.empty?
      # break if iters == 2
      iters += 1

      pos = @positions_to_process.shift
      tile_id = @pos_to_tile[pos]
      # puts "\n############################\n# Currently #{tile_id} is at #{pos}\n############################"

      # Look in each direction
      @directions.each do |direction|
        try_pos = pos_direction(pos, direction)
        # Don't look again if we already found something there
        if (tile = @pos_to_tile[try_pos])
          # puts "- Not looking #{dir_word direction} because tile #{tile} is there."
          next
        end

        found_tile = bruteforce_find(our_id: tile_id, direction: direction)
        if found_tile
          op_tree = @op_tree[tile_id].dup
          op_tree << @tile_ops[found_tile]
          @op_tree[found_tile] = op_tree

          set_tile_pos(found_tile, try_pos)
          @tiles_to_search.delete(found_tile)
          # puts "\n- Placing #{found_tile} at #{try_pos}"
          @positions_to_process << try_pos
        end
      end
    end


    corners = [
      @pos_to_tile[@min_x + 1i*@min_y], # topleft
      @pos_to_tile[@max_x + 1i*@min_y], # topright
      @pos_to_tile[@max_x + 1i*@max_y], # bottomright
      @pos_to_tile[@min_x + 1i*@max_y], # bottomleft
    ]
    [corners, corners.inject(:*)]
  end

  # trim outermost edge
  def trim_all_tiles!
    @tile_rows = @tile_rows.map do |id, rows|
      # cut top and bottom
      rows = rows[1..-2]

      # cut first and last
      rows = rows.map {|str| str[1..-2] }

      [id, rows]
    end.to_h
  end


  def flip_tile(rows, direction)
    if direction == "horz"
      return rows.map(&:reverse)
    elsif direction == "vert"
      return rows.reverse
    elsif direction == 'none'
      return rows.dup
    else
      raise direction
    end

    result = []
    size = rows.size
    size.times { |y|
      result[y] = []
      size.times { |x|
        result[y][x] = rows[y][size - 1 - x]
      }
    }

    result.map!(&:join)

    result
  end

  def rotate_tile(rows, amount)
    rows = rows.dup
    if amount == 0
      return rows
    end

    rows = rows.map(&:chars)
    amount.times do
      rows = rows.transpose.map(&:reverse)
    end
    rows.map! &:join
    rows
  end

  def apply_tile_ops!
    @tile_rows = @tile_rows.map do |id, rows|
      puts "op tree for #{id} are #{@op_tree[id]}"
      @op_tree[id].each do |ops|
        puts "applying ops for #{id} are #{ops}"
        rotate_amount, flip1, flip2 = ops
        rows = rotate_tile(rows, rotate_amount)
        rows = flip_tile(flip_tile(rows, flip1), flip2)
      end

      [id, rows]
    end.to_h
  end

  def print_tile(id)
    if id.is_a? Complex
      id = @pos_to_tile[id]
    elsif !id.is_a?(Integer)
      raise "print_tile got #{id.class}"
    end

    rows = @tile_rows[id]
    puts "[Tile #{id}]"
    puts rows.join("\n")
  end

  def two
    # Build everything from part 1
    one

    # unset some things from part1
    remove_instance_variable :@positions_to_process
    remove_instance_variable :@tiles_to_search

    # print layout
    (@min_y..@max_y).each do |y|
      (@min_x..@max_x).each do |x|
        tile_id = @pos_to_tile[Complex(x, y)]
        print "#{tile_id} "
      end
      puts
    end


    # make all tiles correct
    trim_all_tiles!
    print_tile(0+0i)
    apply_tile_ops!

    @tile_rows.each do |id, rows|
      print_tile(id)
    end

    # tile_id = @pos_to_tile[Complex(@min_x, @min_y)]
    # puts "topleft is #{tile_id}"
    # puts @tile_rows[tile_id].join("\n")

    # image = []
    # edge_width = @tile_rows.values.first.size
    # (@min_y..@max_y).each do |y|
    #   rows = edge_width.times.map {[]}

    #   (@min_x..@max_x).each do |x|
    #     tile_id = @pos_to_tile[Complex(x, y)]
    #     tile_rows = @tile_rows[tile_id]
    #     tile_rows.each_with_index {|row, i| rows[i] << row}
    #     # print "#{tile_id} "
    #   end
    #   puts
    #   # first = tiles_this_row.shift
    #   puts "#{rows}"
    #   # puts "row #{y} is\n#{row}"
    #   # image << first.zip(*tiles_this_row).join(" ")
    # end

    # puts "#{image.join("\n\n")}"
  end

  def test_tile_ops
    tile = ["abc", "def", "ghi"]
    puts "tile: \n#{tile.join("\n")}"

    puts "\nflip horz: \n#{flip_tile(tile, "horz").join("\n")}"
    puts "\nflip vert: \n#{flip_tile(tile, "vert").join("\n")}"

    puts "\nrotate_tile(tile, 0): \n#{rotate_tile(tile, 0).join("\n")}"
    puts "\nrotate_tile(tile, 1): \n#{rotate_tile(tile, 1).join("\n")}"
    puts "\nrotate_tile(tile, 2): \n#{rotate_tile(tile, 2).join("\n")}"
    puts "\nrotate_tile(tile, 3): \n#{rotate_tile(tile, 3).join("\n")}"

    tile = <<~EOF.strip.split("\n")
      #.#.#####.
      .#..######
      ..#.......
      ######....
      ####.#..#.
      .#...#.##.
      #.#####.##
      ..#.###...
      ..#.......
      ..#.###...
    EOF

    puts "\n\n\n\n\nOriginal:"
    puts tile
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.read

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
