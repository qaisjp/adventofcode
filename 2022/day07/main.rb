# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'pathname'

# AoC
class AoC
  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  def recurse(paths, sum=0)
    if paths.size == 1
      return sum
    end
    paths = paths.group_by {|k,v| k.dirname}.transform_values {_1.sum{|k,v| v}}
    puts("PATHS WERE #{paths}")
    sum += paths.sum{_2}
    recurse(paths, sum)
  end

  EG1 = 95437
  WRITE_FS = true
  def one
    prefix = Pathname.new('/')
    if WRITE_FS
      `rm -rf aoc-fs`
      `mkdir aoc-fs`
    end

    active_cmd = nil
    files = {}
    max_bytes = 0
    @data.each do |line|
      puts("Line: #{line}")
      if line.start_with?('$ cd ')
        active_cmd = nil
        path = line.delete_prefix('$ cd ')
        if path == '/'
          prefix = Pathname.new(path) 
        else
          prefix = prefix.join(path)
        end
        puts("%%% path is now #{prefix}")
        next
      elsif line.start_with?("$ ls")
        active_cmd = "ls"
        puts("%%% active command is #{active_cmd}")
        next
      end

      if active_cmd == "ls"
        if line.start_with?("dir ")
        else
          size, path = line.scanf("%d %s")
          puts("- Updating files[#{prefix.join(path)}]=#{size}")
          if WRITE_FS
            fsp = Pathname.new("aoc-fs").join(Pathname.new(prefix.join(path).to_s.delete_prefix("/")))
            `mkdir -p "#{fsp.dirname}"`
            puts("fsp is #{fsp}")
            fsp.write("a" * size)
          end
          if files[prefix.join(path)]
            raise("it exists #{path}")
          end
          max_bytes += size
          files[prefix.join(path)] = size
        end
      else
        raise "??? #{line}"
      end
    end

    puts("MAX BYTES #{max_bytes}")

    counts = Hash.new(0)
    files.each do |f, c|
      f.ascend.to_a[1..].each do |dir|
        counts[dir] += c
      end
    end
    @files = files

    puts("ORIG FILES #{files}")
    puts("COUNTS #{counts}")
    ans = counts.map{_2}.sum do |c|
      if c <= 100000
      c
      else
      0
      end
    end
    @counts = counts
    ans
  end

  EG2 = 24933642
  def two
    size_free = 70000000 - @counts[Pathname.new("/")]
    puts("space remaining: #{size_free}")
    want = 40000000
    answers = []
    @counts.each do |p, c|
      actual = size_free + c
      if actual >= want
        puts("p -> #{p} #{c}")
        answers << c
      end
    end
    answers.min
  end
end

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

  unless test(n)
    puts 'Tests failed :('
    return
  end

  runner = if ARGV.empty?
             AoC.new File.read('input.txt').split("\n")
           else
             AoC.new ARGF.readlines.to_a
           end

  puts "\n\n--- Part #{n} solution" if n != ''
  puts "Result 1: #{runner.one}" if n == '1' || (run_both && n == '2')
  puts "Result 2: #{runner.two}" if n == '2'
end

main
