# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'

# AoC
class AoC
  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
    @strengths = {}
    @crt = 240.times.map { '.' }
  end

  def process_cycle(cycle, x, line)
    if (cycle - 20) % 40 == 0
      @strengths[cycle] = cycle * x
    end

    crt_cycle = cycle - 1
    row = (crt_cycle / 40) # depending on integer division
    puts("During cycle #{cycle} (row #{row}, x is #{x})")
    x = x + (row * 40)
    if crt_cycle == x || crt_cycle == x - 1 || crt_cycle == x + 1
      @crt[crt_cycle] = '#'
      puts("CRT row now: #{@crt.each_slice(40).to_a[row].join}")
    else
      puts("CRT row now: #{@crt.each_slice(40).to_a[row].join}")
    end
  end

  EG1 = 13140
  def one
    cycle = 0
    x = 1

    @data.each_with_index do |line, li|
      op, val = line.split(" ")
      if op == "addx"
        val = val.to_i
        puts("Start cycle #{cycle + 1}: begin executing #{line}")
        2.times do |time|
          cycle += 1
          process_cycle(cycle, x, line)
        end
        x += val
        puts("Register X is now at #{x}")
      else op == "noop"
        cycle += 1
        process_cycle(cycle, x, line)
      end
    end

    @strengths.values.sum
  end

  EG2 = 0
  def two
    puts
    puts
    puts @crt.each_slice(40).map { |l| l.join }.join("\n")
    0
  end
end

#####
##### BOILERPLATE
#####

def test(_part)
  runner = AoC.new File.read('example.txt').split("\n")

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
  run_both = true

  n = ARGV.shift

  if !test(n)
    puts "Tests failed :("
    return
  end

  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
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
