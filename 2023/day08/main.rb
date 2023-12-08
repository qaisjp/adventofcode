# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
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

  Node = T.type_alias {T.any(ValNode, PairNode)}

  class ValNode < T::Struct
    prop :val, String
  end

  class PairNode < T::Struct
    extend T::Sig
    prop :val, String
    prop :left, String
    prop :right, String

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
      puts("Parsing #{line}")
      f, l, r = line.tr("=(,)", "").split
      if nodes[T.must(f)]
        raise("Node #{f} already exists")
      end

      n = if l == r
        # FYI there are multiple terminals
        ValNode.new(val: T.must(f))
      else
        PairNode.new(val: T.must(f), left: T.must(l), right: T.must(r))
      end

      if f == "AAA"
        root_node = T.cast(n, PairNode)
      end
      nodes[T.must(f)] = n
    end

    nodes
  end

  EG1 = 0
  def one
    puts("Parsing nodes…")
    nodes = parse_nodes

    curr_node = T.let(T.must(nodes["AAA"]), Node)
    steps = 0
    @instructions.each do |direction|
      if curr_node.is_a?(ValNode)
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

    if curr_node.is_a?(ValNode)
      puts("Found #{curr_node.val} after #{steps} steps")
    else
      puts("Did not find ValNode after #{steps} steps")
    end
    
    puts("Done.")
    



    0
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
