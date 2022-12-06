# frozen_string_literal: true

# typed: true

require 'scanf'
require 'set'

# AoC
class AoC
  def initialize(data1, data2)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data1 = data1
    @data2 = data2
  end

  def process(line, trail)
    puts("Processing #{line}")
    (trail..line.size).each do |i|
      four = line[i - trail..i].chars
      puts("four is #{four}")
      if four == four.uniq
        puts("found #{i} is #{four}")
        return i + 1
      end
    end
    raise '??'
  end

  EG1 = [7, 5, 6, 10, 11].freeze
  def one
    @data1.map do |line|
      process(line, 3)
    end
  end

  EG2 = [19, 23, 23, 29, 26].freeze
  def two
    @data2.map do |line|
      process(line, 13)
    end
  end
end

def test(_part)
  runner = AoC.new(File.read('example.txt').split("\n"), File.read('example2.txt').split("\n"))

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
  run_both = false

  n = ARGV.shift

  unless test(n)
    puts 'Tests failed :('
    return
  end

  runner = if ARGV.empty?
             AoC.new(File.read('input.txt').split("\n"), File.read('input.txt').split("\n"))
           else
             AoC.new ARGF.readlines.to_a
           end

  puts "\n\n--- Part #{n} solution" if n != ''
  puts "Result 1: #{runner.one}" if n == '1' || (run_both && n == '2')
  puts "Result 2: #{runner.two}" if n == '2'
end

main
