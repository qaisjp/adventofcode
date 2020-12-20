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
    @tile_pos[pos] = tile
    @min_x = [@min_x, pos.x].min
    @min_y = [@min_y, pos.y].min
    @max_x = [@max_x, pos.x].max
    @max_y = [@max_y, pos.y].max
  end

  def one
    tile_count = @tile_rows.size
    edge_width = Math.sqrt(tile_count)
    puts "There are #{tile_count} tiles, edge_width is #{edge_width}"

    @tile_pos = {}
    # @tile_links = {}
    @tile_ops = {}
    @free_tiles = []
    @tile_edges = {}

    @tile_rows.each do |id, rows|
      top = rows[0]
      right = rows.map(&:last).join("")
      bottom = rows[-1]
      left = rows.map(&:first).join("")
      @tile_edges[id] = [top, right, bottom, left]

      if id == 1489
        puts "Edges of 1489 are #{@tile_edges[id]}"
      end

      # @tile_links[id] = [nil, nil, nil, nil]
      @tile_ops[id] = []
      @free_tiles << id
    end

    opposite_direction = [0, 1, 2, 3]
    direction_words = ["top___", "right_", "bottom", "left__"]

    pos = 0 + 0i
    set_tile_pos(@free_tiles.shift, pos)
    direction = 0

    # modified
    movement_directions = [0, 1, 2, 3]
    directions_lost = 0

    found = true
    while found do
      found = nil
      loopback_skip = false

      tile_id = @tile_pos[pos]
      our_edge = @tile_edges[tile_id][direction]
      our_word = direction_words[direction]

      their_direction = opposite_direction[direction]
      their_word = direction_words.rotate(2)[their_direction]
      next_pos = pos_direction(pos, direction)

      if (tile = @tile_pos[next_pos])
        puts "\nLoopback on #{next_pos} which is #{tile}, hopping"
        # loopback_skip = true
        pos = next_pos
        found = true
        next
      end

      puts "\n\n"
      puts "#{tile_id} is at #{pos}, trying to place at #{next_pos}"
      puts "Looking for tiles on #{direction_words[direction]} of #{tile_id}"
      puts "Findin tile whose #{their_word} matches our #{our_word} #{our_edge} () #{our_edge}"

      @free_tiles.each do |their_id|
        break if found
        4.times do |rotate_index|
          break if found
          ["none", "vert", "horz"].repeated_combination(2).each do |flip1, flip2|
            break if found

            other_edges = @tile_edges[their_id].rotate(rotate_index).flip_both(flip1, flip2)
            other_edges2 = @tile_edges[their_id].flip_both(flip1, flip2).rotate(rotate_index)

            if tile_id == 1427 && their_id == 1489
              puts "rot(#{rotate_index}), flip(#{flip1}, #{flip2}): #{their_word} of #{their_id} is #{other_edges[their_direction]} or #{other_edges2[their_direction]}"
            end
            # our top is their bottom
            # our right is their left
            # our bottom is their top
            # our left is their right
            if our_edge == other_edges[their_direction]
              puts "FOUND1: rot(#{rotate_index}, flip(#{flip1}, #{flip2})"
              puts "#{their_id} is placed next to #{tile_id}"
              # @tile_edges[their_id] = other_edges  # this should be here but it breaks things
              found = their_id
            elsif our_edge == other_edges2[their_direction]
              puts "FOUND2: flip(#{flip1}, #{flip2}), rot(#{rotate_index}"
              # @tile_edges[their_id] = other_edges2 # this should be here but it breaks things
              puts "#{their_id} is placed next to #{tile_id}"
              found = their_id
            end
            # apply the operation to that tile
            # check it fits
          end
        end
      end

      if found && !loopback_skip
        directions_lost = 0
        set_tile_pos(found, next_pos)
        pos = next_pos
        @free_tiles.delete(found)
      else
        break if directions_lost == 4
        movement_directions.rotate!
        old_direction = direction_words[direction]
        direction = movement_directions.first
        puts "\nCould not #{old_direction} facing tile. New direction is #{direction_words[direction]}"
        found = true
        directions_lost += 1
      end
    end


    [
      @tile_pos[@min_x + 1i*@min_y], # topleft
      @tile_pos[@max_x + 1i*@min_y], # topright
      @tile_pos[@max_x + 1i*@max_y], # bottomright
      @tile_pos[@min_x + 1i*@max_y], # bottomleft
    ]
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
