# frozen_string_literal: true
# typed: true

require 'scanf'

class Node
  attr_accessor :l
  attr_accessor :v
  attr_accessor :r
  attr_accessor :parent

  def initialize(l, r, v)
    @l = l
    @r = r
    @v = v
    @parent = nil
  end

  def rightmost
    if v
      self
    else
      r.rightmost
    end
  end
  def rightmost=(other)
    if v
      @v = other
    else
      r.rightmost = other
    end
  end

  def leftmost
    if v
      self
    else
      l.leftmost
    end
  end
  def leftmost=(other)
    if v
      @v = other
    else
      r.leftmost = other
    end
  end

  def left_of(node)
    if v
      self
    elsif node == r
      # [7,[6,[5,[4,[3,2]]]]]
      #          s  rnode
      l.rightmost
    elsif node == l
      # [7,[6,[5,[ [3,2], 4]]]]
      #          s lnode
      parent&.left_of(self)
    end
  end

  def right_of(node)
    if v
      self
    elsif node == r
      # [[ [ 2, [0,9] ],3],4]
      #    s    rnode
      parent&.right_of(self)
    elsif node == l
      # [[ [ [0,9] ,2],3],4]
      #    s lnode
      r.leftmost
    end
  end

  def to_s
    if v
      "Node(#{v})"
    else
      "Node(#{l}, #{r})"
    end
  end

  def arr
    if v
      v
    else
      [l.arr, r.arr]
    end
  end

  def convert_to_leaf(value)
    @l = nil
    @r = nil
    @v = value
  end

  def convert_from_leaf(left, right)
    @l = left
    @r = right
    @v = nil
  end

  def inspect; to_s; end
end

def new_tree(arr, parent=nil)
  if arr.class == Array
    new_parent = Node.new(nil, nil, nil)
    new_parent.parent = parent
    new_parent.l = new_tree(arr.first, new_parent)
    new_parent.r = new_tree(arr.last, new_parent)
    new_parent
  else
    Node.new(nil, nil, arr)
  end
end

def explode(node)
  # Exploding pairs will always consist of two regular numbers
  raise "node.l is not a leaf" unless node.l.v
  raise "node.r is not a leaf" unless node.r.v

  puts "Exploding #{node}"

  # the pair's left value is added to the first regular number to the left of the exploding pair (if any)
  pairs_left_value = node.l.v
  if node_left_of_pair = node.parent.left_of(node)
    node_left_of_pair.v += pairs_left_value
  end


  # the pair's right value is added to the first regular number to the right of the exploding pair (if any)
  pairs_right_value = node.r.v
  if node_right_of_pair = node.parent.right_of(node)
    node_right_of_pair.v += pairs_right_value
  end

  # Then, the entire exploding pair is replaced with the regular number 0.
  node.convert_to_leaf(0)
end

def explore(node, depth=1, &blk)
  if depth < 4
    if node.l
      explore(node.l, depth+1, &blk)
      explore(node.r, depth+1, &blk)
    end
  elsif depth == 4 && !node.v
    puts("Reached depth level #{depth} on node #{node} - EXPLOSION TIME yo")

    # if node.v
    #   puts "- Node is a leaf node."
    #   return
    # end

    # Check if this node contains another node on the left or the right
    left = node.l
    right = node.r
    leftmost_pair = if !left.v
      puts "- Leftmost pair is #{left} (left)"
      left
    elsif !right.v
      puts "- Leftmost pair is #{right} (right)"
      right
    else
      # Node only contains leaf nodes
      puts "- Node only contains leaf nodes"
      nil
    end

    return unless leftmost_pair

    # Explode the leftmost_pair
    explode(leftmost_pair)
    yield
  end

  # split
  if node.v&.>= 10
    node.convert_from_leaf(
      new_tree(node.v / 2, node),
      new_tree((node.v / 2.0).ceil, node),
    )
  end
end

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data.map {new_tree(eval(_1))}
  end


  def test(i, out, &blk)
    t = new_tree(i)
    if blk
      explore(t, &blk)
    else
      explore(t) {}
    end
    actual = t.arr
    raise "test failed #{out} != #{actual}" unless out == actual
  end

  def one
    t = new_tree(eval("[[[[[9,8],1],2],3],4]"))
    explore(t) {}

    test([[[[[9,8],1],2],3],4] , [[[[0,9],2],3],4])
    test([7,[6,[5,[4,[3,2]]]]] , [7,[6,[5,[7,0]]]])
    test([[6,[5,[4,[3,2]]]],1] , [[6,[5,[7,0]]],3])
    test([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] , [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]) { break }
    test([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] , [[3,[2,[8,0]]],[9,[5,[7,0]]]])
    test([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] , [[3,[2,[8,0]]],[9,[5,[7,0]]]])
    test(10, [5,5])
    test(11, [5,6])
    test(12, [6,6])

    0
  end

  def two

    0
  end
end

def test(part)
  examples = [
    0,
    0,
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
  run_both = false

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
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
