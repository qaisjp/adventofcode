# frozen_string_literal: true

require 'scanf'
require 'json'

# AoC
class AoC
  def initialize(data)
    @data = data
  end

  def mappings_from_data
    @data.each_with_object({}) do |x, mappings|
      parent_a, parent_b, children_str = x.scanf("%s %s bags contain %10000[^\n].")
      parent = "#{parent_a} #{parent_b}"
      children = children_str.gsub("no other bags", "").strip.tr(".", "").gsub(/ bags?/, "").split(", ")
      counts = children.each_with_object({}) do |str, hash|
        n, a, b = str.scanf("%d %s %s")
        color = "#{a} #{b}"
        hash[color] = n
      end

      # puts "X: #{parent} -> #{counts}"
      mappings[parent] = counts
    end
  end

  def eventually_contains_key(data, key, pin)
    return true if key == pin

    children = data[key]
    children.each do |color, _|
      return true if eventually_contains_key(data, color, pin)
    end
    false
  end

  def one
    mappings = mappings_from_data
    puts mappings.to_json

    pin = 'shiny gold'
    count = mappings.keys.count {|key| key != pin && eventually_contains_key(mappings, key, pin)}
    puts count
  end

  def count_children(data, color_ns)
    return 0 if color_ns.empty?

    color_ns.sum do |pair|
      color, n = pair
      n + n * count_children(data, data[color])
    end
  end

  def two
    mappings = mappings_from_data
    puts count_children(mappings, mappings["shiny gold"])
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    runner.one
  else
    runner.two
  end
end
main
