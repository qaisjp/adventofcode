# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])

    @offsets = {
      e: 1 + 0i,
      se: 0.5 - 0.5i,
      sw: -0.5 - 0.5i,
      w: -1 - 0i,
      nw: -0.5 + 0.5i,
      ne: 0.5 + 0.5i
    }

    @offsets_inclusive = @offsets.values + [0 + 0i]
  end

  def to_coord(route)
    coord = 0 + 0i
    route.each do |e|
      coord += @offsets.fetch(e)
    end
    coord
  end

  def load_grid!
    # 0 = white facing up, 1 = black
    @grid = {}

    @data.each do |line|
      route = line.split(/(se)|(sw)|(nw)|(ne)|(w)|(e)/).reject(&:empty?).map(&:to_sym)
      coord = to_coord(route)
      @grid[coord] ||= 0
      @grid[coord] += 1
    end
  end

  def one   
    load_grid!
    @grid.values.count {|x| x % 2 == 1}
  end

  def run_day
    new_grid = @grid.dup

    coords_to_check = @grid.keys.map do |base|
      @offsets_inclusive.map do |offset|
        base + offset
      end
    end.flatten.uniq


    # puts "keys: #{@grid.keys}"
    # puts "all: #{coords_to_check}"

    coords_to_check.each do |coord|
      val = @grid.fetch(coord, 0)
      
      # count adjacent blacks
      black_count = 0
      @offsets.each do |_, off|
        subcoord = coord + off
        black_count += @grid.fetch(subcoord, 0) % 2
        if black_count > 2
          break
        end
      end

      # if black
      if val % 2 == 1
        if black_count == 0 || black_count > 2
          new_grid[coord] = 0
        end
      else
        if black_count == 2
          new_grid[coord] = 1
        end
      end
    end

    # puts "old grid #{@grid}"
    @grid = new_grid
    # puts "new grid #{@grid}"
  end

  def two
    load_grid!

    100.times do
      run_day
    end

    @grid.values.count {|x| x % 2 == 1}
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
