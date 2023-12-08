# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
require 'benchmark'
require 'pry'

# AoC
class AoC
  extend T::Sig
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data.first, String)
    ins, nod = T.let(data, T::Array[String])
    @instructions = T.let(T.must(ins).chars, T::Array[String])
    @nodes = T.let(T.must(nod).split("\n"), T::Array[String])
  end

  class Node < T::Struct
    extend T::Sig
    prop :val, String
    prop :left, String
    prop :right, String
    prop :end_with_a, T::Boolean
    prop :end_with_z, T::Boolean

    sig {params(nodes: T::Hash[String, Node]).returns(Node).checked(:never)}
    def left_node(nodes)
      nodes.fetch(left)
    end

    sig {params(nodes: T::Hash[String, Node]).returns(Node).checked(:never)}
    def right_node(nodes)
      nodes.fetch(right)
    end
  end

  sig {returns(T::Hash[String, Node])}
  def parse_nodes
    nodes = T::Hash[String, Node].new
    
    # Populate nodes and root_node
    @nodes.each do |line|
      f, l, r = line.tr("=(,)", "").split
      f = T.must(f)
      l = T.must(l)
      r = T.must(r)
      if nodes[f]
        raise("Node #{f} already exists")
      end

      nodes[f] = Node.new(
        val: f,
        left: l,
        right: r,
        end_with_a: f.end_with?("A"),
        end_with_z: f.end_with?("Z")
      )
    end

    nodes
  end

  EG1 = 2
  def one
    nodes = parse_nodes
    puts("Nodes parsed ✅")

    curr_node = T.let(T.must(nodes["AAA"]), Node)
    steps = 0

    while curr_node.val != "ZZZ"
      @instructions.each do |direction|
        if curr_node.val == "ZZZ"
          break
        end

        steps += 1

        if direction == "L"
          curr_node = curr_node.left_node(nodes)
        elsif direction == "R"
          curr_node = curr_node.right_node(nodes)
        else
          raise("Unknown direction #{direction}")
        end
      end
    end

    if curr_node.val == "ZZZ"
      puts("Found #{curr_node.val} after #{steps} steps")
    else
      puts("Did not find ZZZ, stopped at #{steps} steps")
    end
    
    puts("Done.")

    steps
  end

  sig {params(curr_nodes: T::Array[Node]).returns(T::Boolean).checked(:never)}
  def at_end(curr_nodes)
    curr_nodes.all?(&:end_with_z)
  end

  EG2 = EG1
  def two
    nodes = parse_nodes
    puts("Nodes parsed ✅")

    curr_nodes = nodes.values.filter(&:end_with_a)
    steps = 0

    Signal.trap("SIGINT") do
      puts("Steps is at #{steps}")
    end

    while !at_end(curr_nodes)
      @instructions.each do |direction|
        if at_end(curr_nodes)
          break
        end

        steps += 1

        if direction == "L"
          curr_nodes = curr_nodes.map{_1.left_node(nodes)}
        elsif direction == "R"
          curr_nodes = curr_nodes.map{_1.right_node(nodes)}
        else
          raise("Unknown direction #{direction}")
        end
      end
    end

    if at_end(curr_nodes)
      puts("Done after #{steps} steps")
    else
      puts("Did not finish, stopped at #{steps} steps")
    end
    
    puts("Done.")

    steps
  end
end

#####
##### BOILERPLATE
#####

def test(_part, f, expected)
  runner = AoC.new File.read(f).split("\n\n")

  if f != "example3.txt"
    puts("\n\n--- #{f} part 1")
    one = runner.one
    this = expected[0]
    if one != this
      puts "#{f} part 1 was #{one}, expected #{this}"
    else
      puts "#{f} part 1 passes (#{one})"
      passed = true
    end
  else
    passed = true
  end

  if passed
    puts "\n\n--- #{f} part 2"
    two = runner.two
    this = expected[1]
    if two != this
      puts "\n\n#{f} part 2 was #{two}, expected #{this}"
      passed = false
    else
      puts "\n\n#{f} part 2 passes (#{this})"
    end
  end

  passed
end

def main
  run_both = T.let(false, T::Boolean)

  n = ARGV.shift

  if !test(n, "example.txt", [AoC::EG1, AoC::EG2])
    puts "example.txt - Tests failed :("
    return
  end

  if !test(n, "example2.txt", [6,6])
    puts "example2.txt - Tests failed :("
    return
  end

  if !test(n, "example3.txt", [6,6])
    puts "example3.txt - Tests failed :("
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
