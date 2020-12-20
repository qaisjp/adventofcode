# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'scanf'

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
  end

  def one
    tile_count = @tile_rows.size
    edge_width = Math.sqrt(tile_count)
    puts "There are #{tile_count} tiles, edge_width is #{edge_width}"

    @tile_links = {}
    @tile_ops = {}
    @tile_edges = @tile_rows.map do |id, rows|
      top = rows[0]
      right = rows.map(&:last).join("")
      bottom = rows[1]
      left = rows.map(&:first).join("")

      @tile_links[id] = [nil, nil, nil, nil]
      @tile_ops[id] = []

      [id, [top, right, bottom, left]]
    end.to_h
    # puts "#{@tile_edges}"

    # map[id][[top_id, right_id, bottom_id, left_id]]

    @tile_edges.each do |tile_id, edge_strs|
      links = @tile_links[tile_id]
      next if links.compact == 4

      t, r, b, l = edge_strs

      @tile_edges.each do |other_id, other_strs|
        next if other_id == tile_id

        other_links = @tile_links[other_id]
        next if other_links.compact == 4

        to, ro, bo, lo = other_strs

        postop = nil

        # our top is their bottom
        # our right is their left
        # our bottom is their top
        # our left is their right
        if t == bo
          links.top = other_id
          other_links.bottom = tile_id
        elsif r == lo
          links.right = other_id
          other_links.left = tile_id
        elsif b == to
          links.bottom = other_id
          other_links.top = tile_id
        elsif l == ro
          links.left = other_id
          other_links.right = tile_id

        # when you flip this one vertically,
        # - your top matches with another top
        # - your right.reverse matches with another left
        # - your bottom matches with another bottom
        # - your left.reverse matches with another right
        elsif t == to
          postop = 'vertical'
          links.top = other_id
          other_links.top = tile_id
        elsif r.reverse == lo
          postop = 'vertical'
          links.right = other_id
          other_links.left = tile_id
        elsif b == bo
          postop = 'vertical'
          links.bottom = other_id
          other_links.bottom = tile_id
        elsif l.reverse == ro
          postop = 'vertical'
          links.left = other_id
          other_links.right = tile_id

        # when you flip horizontally,
        # - your top.reverse matches with another bottom
        # - your right matches with another right
        # - your bottom.reverse matches with another top
        # - your left matches with another left
        elsif t.reverse == bo
          postop = 'horizontal'
          links.top = other_id
          other_links.bottom = tile_id
        elsif r == ro
          postop = 'horizontal'
          links.right = other_id
          other_links.right = tile_id
        elsif b.reverse == to
          postop = 'horizontal'
          links.bottom = other_id
          other_links.top = tile_id
        elsif l == lo
          postop = 'horizontal'
          links.left = other_id
          other_links.left = tile_id
        end

        if postop
          @tile_ops[tile_id] << postop
        end
      end
    end

    [@tile_links, @tile_ops]
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
