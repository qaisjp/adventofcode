# frozen_string_literal: true
# typed: true

require 'matrix'
require 'scanf'

module CoordSystem
  def x
    self[0]
  end
  def x=(other)
    self[0] = other
  end
  def y
    self[1]
  end
  def y=(other)
    self[1] = other
  end
end

class Vector
  include CoordSystem
end

# AoC
class AoC

  def initialize(data)
    xa, xb, ya, yb = data.first.scanf("target area: x=%d..%d, y=%d..%d")
    @target = Vector[xa..xb, ya..yb]
    puts "Target is #{@target}"
  end

  def step(pos, vel)
    velx = if vel.x > 0
      -1
    elsif vel.x < 0
      1
    else
      0
    end
    [
      pos += vel,
      vel += Vector[
        velx,
        -1,
      ]
    ]
  end

  def stepper(pos, vel)
    # puts "Testing vel: #{vel}"
    maxy = 0
    (1..).each do |index|
      pos, vel = step(pos, vel)

      overshot = (pos.x > @target.x.max) || (pos.y < @target.y.min)
      in_range = @target.x.include?(pos.x) && @target.y.include?(pos.y)
      maxy = [maxy, pos.y].max

      if overshot
        # puts "Overshot! Pos is #{pos} but target is #{@target}"
        return false, maxy
      elsif in_range
        return true, maxy
      end
    end
  end

  def one
    pos = Vector[0, 0]
    # vel = Vector[0, 0]
    bestvel = Vector[0, 0]
    maxy = 0
    @counts = 0

    (0..@target.x.max).each do |vx|
      (-100..100).each do |vy|
        vel = Vector[vx, vy]
        success, y = stepper(pos, vel)

        if success
          puts "in range using vel #{vel}"
          @counts += 1
          if y > maxy
            maxy = y
            bestvel = vel
          end
        end
      end
    end

    maxy
  end

  def two

    @counts
  end
end

def test(part)
  examples = [
    45,
    112,
  ]

  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = examples.last
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

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Result: #{runner.one}"
  end
  if n == '2'
    puts "Result: #{runner.two}"
  end
end

main
