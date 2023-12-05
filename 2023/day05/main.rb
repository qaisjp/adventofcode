# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
require 'pry'

# AoC
class AoC
  extend T::Sig
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @seeds = T.let(T.let(data.first, String).delete_prefix("seeds: ").split.map(&:to_i), T::Array[Integer])
    @maps = T.let(data[1..], T::Array[String])
  end

  EG1 = 35
  def one
    # puts(@seeds)

    category_map = T::Hash[String, T::Hash[Integer, Integer]].new do |h, k|
      h[k] = T::Hash[Integer, Integer].new { |h, k| k }
    end

    categories = %w[seed soil fertilizer water light temperature humidity location]
    
    @maps.each do |map|
      header, *rest = map.split("\n")
      src_cat, dst_cat = T.must(header).gsub("-to-", " ").scanf("%s %s")

      rest.each do |line|
        dst_rng_start, src_rng_end, rng_len = line.scanf("%d %d %d")

        rng_len.times do |n|
          src = src_rng_end + n
          dst = dst_rng_start + n
          category_map[src_cat][src] = dst
        end
      end
    end

    @seeds.map do |seed|
      curno = seed
      categories.each_with_index do |cat, cat_i|
        curno = category_map[cat][curno]
      end
      # puts("For seed #{seed} got #{curno}")
      curno
    end.min
  end

  EG2 = 0
  def two
    0
  end
end

#####
##### BOILERPLATE
#####

def test(_part)
  runner = AoC.new File.read('example.txt').split("\n\n")

  one = runner.one
  this = AoC::EG1
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = AoC::EG2
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
  run_both = T.let(false, T::Boolean)

  n = ARGV.shift

  if !test(n)
    puts "Tests failed :("
    return
  end

  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  puts "\n\n--- Part #{n} solution" if n != nil
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
