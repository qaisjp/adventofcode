# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'ostruct'
require 'set'

# AoC
class AoC
  extend T::Sig

  def initialize(lines)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data, T::Array[String])
    @food = lines.map do |line|
      food = OpenStruct.new

      left, right = line[0..-3].tr(",", "").split("(contains ")
      food.ingredients = left.split
      food.allergens = right.split

      food
    end
  end

  def one
    # Count how many times an ingredient appears in the puzzle input
    ingredients = []
    @food.each do |food|
      ingredients += food.ingredients
    end

    # And all the known potential ingredients for each allergen together
    a_to_ings = {}
    @food.each do |food|
      food.allergens.each do |allergen|
        if a_to_ings[allergen]
          a_to_ings[allergen] = a_to_ings[allergen] & food.ingredients.to_set
        else
          a_to_ings[allergen] = food.ingredients.to_set
        end
      end
    end

    known_a_to_i = {}
    deleted = true
    while deleted
      deleted = false
      a_to_ings.each do |allergen, ings|
        next if ings.size != 1
        ing = ings.first
        known_a_to_i[allergen] = ing

        # Also remove that ingredient from all mappings
        a_to_ings.each do |_, ings|
          ings.delete(ing)
          deleted = true
        end
      end
    end

    never = ingredients.to_set - known_a_to_i.values
    part1 = ingredients.count {|i| never.include? i}

    part2 = known_a_to_i
    part2 = part2.keys.sort.map {|k| known_a_to_i[k]}.join(",")

    [part1, part2]
  end

  def two
    one
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
