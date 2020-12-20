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
      top = rows[0]
      right = rows.map(&:last).join("")
      bottom = rows[-1]
      left = rows.map(&:first).join("")
      [id, [top, right, bottom, left]]
    end.to_h
  end

  def does_tile_fit(our_id:, our_edge:, their_id:, their_direction:)
    # Try all rotations
    4.times do |rotate_index|
      # Try all pairs of mirroring
      ["none", "vert", "horz"].repeated_combination(2).each do |flip1, flip2|

        other_edges = @tile_edges[their_id].rotate(rotate_index).flip_both(flip1, flip2)
        other_edges2 = @tile_edges[their_id].flip_both(flip1, flip2).rotate(rotate_index)

        # if tile_id == 1427 && their_id == 1489
        #   puts "rot(#{rotate_index}), flip(#{flip1}, #{flip2}): #{their_word} of #{their_id} is #{other_edges[their_direction]} or #{other_edges2[their_direction]}"
        # end

        # our top is their bottom
        # our right is their left
        # our bottom is their top
        # our left is their right
        if our_edge == other_edges[their_direction]
          puts "FOUND1: rot(#{rotate_index}), flip(#{flip1}, #{flip2})"
          puts "#{their_id} is placed #{dir_word(their_direction, opp: true)} to #{our_id}"
          @tile_edges[their_id] = other_edges
          return true
        elsif our_edge == other_edges2[their_direction]
          puts "FOUND2: flip(#{flip1}, #{flip2}), rot(#{rotate_index})"
          @tile_edges[their_id] = other_edges2
          puts "#{their_id} is placed #{dir_word(their_direction, opp: true)} to #{our_id}"
          return true
        end
      end
    end

    return false
  end

  def bruteforce_find(our_id:, direction:)
    puts "\n## Looking #{dir_word(direction)} of #{our_id}\n\n"
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
    edge_width = Math.sqrt(tile_count)
    puts "There are #{tile_count} tiles, edge_width is #{edge_width}"

    @tile_ops = {}
    @tiles_to_search = []
    build_tile_edges!
    @tile_rows.map do |id, _|
      @tiles_to_search << id
      @tile_ops[id] = []
    end

    pos = 0 + 0i
    set_tile_pos(@tiles_to_search.shift, pos)

    iters = 0
    @positions_to_process = [0 + 0i]
    while !@positions_to_process.empty?
      # break if iters == 2
      iters += 1

      pos = @positions_to_process.shift
      tile_id = @pos_to_tile[pos]
      puts "\n############################\n# Currently #{tile_id} is at #{pos}\n############################"

      # Look in each direction
      @directions.each do |direction|
        try_pos = pos_direction(pos, direction)
        # Don't look again if we already found something there
        if (tile = @pos_to_tile[try_pos])
          puts "- Not looking #{dir_word direction} because tile #{tile} is there."
          next
        end
        found_tile = bruteforce_find(our_id: tile_id, direction: direction)
        if found_tile
          set_tile_pos(found_tile, try_pos)
          @tiles_to_search.delete(found_tile)
          puts "\n- Placing #{found_tile} at #{try_pos}"
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

  def two

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
