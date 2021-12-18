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

  def leftmost
    if v
      self
    else
      l.leftmost
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

  def birth(left, right)
    @l = new_tree(left, self)
    @r = new_tree(right, self)
    @v = nil
  end

  def inspect; to_s; end

  def basic_add_to(other)
    new_node = Node.new(self, other, nil)
    self.parent = new_node
    other.parent = new_node
    new_node
  end

  def magnitude
    if v
      v
    else
      3*l.magnitude + 2*r.magnitude
    end
  end
end

def new_tree(arr, parent=nil)
  if arr.class == Array
    new_parent = Node.new(nil, nil, nil)
    new_parent.parent = parent
    new_parent.l = new_tree(arr.first, new_parent)
    new_parent.r = new_tree(arr.last, new_parent)
    new_parent
  else
    yee = Node.new(nil, nil, arr)
    yee.parent = parent
    yee
  end
end

def explode(node)
  # Exploding pairs will always consist of two regular numbers
  raise "node.l is not a leaf" unless node.l.v
  raise "node.r is not a leaf" unless node.r.v

  puts "Exploding #{node} whose parent is #{node.parent.inspect}"

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
  if depth >= 4 && !node.v
    # puts("Reached depth level #{depth} on node #{node} - EXPLOSION TIME yo")

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
      # puts "- Node only contains leaf nodes"
      explore(node.l, depth+1, &blk)
      explore(node.r, depth+1, &blk)
      nil
    end

    if leftmost_pair
      # Explode the leftmost_pair
      explode(leftmost_pair)
      yield
    end
  end

  if node.l
    explore(node.l, depth+1, &blk)
    explore(node.r, depth+1, &blk)
  elsif node.v >= 10
      # split
    puts "Node value #{node.v} needs splitting — parent is #{node.parent.inspect}"
    node.birth(
      node.v / 2,
      (node.v / 2.0).ceil,
    )
    yield
  end
end

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data.map {new_tree(eval(_1))}
  end

  def iteratively_explore(t)
    iterations_needed = 0
    (1..).each do |i|
      affected = false
      puts "\n\n\n==== Iteration #{i}\n|\n"
      explore(t) { affected = true; puts "|\n==== Node is now #{t.arr}"; break }
      return iterations_needed unless affected
      iterations_needed += 1
    end
    raise "???"
  end

  def test(i, out, iter: false, &blk)
    t = new_tree(i)
    if iter
      iteratively_explore(t)
    else
      if blk
        explore(t, &blk)
      else
        explore(t) {}
      end
    end
    actual = t.arr
    raise "\n\n# test failed:\n- wanted: #{out}\n- got:    #{actual}" unless out == actual
  end

  def sumup(tree_array, &blk)
    t = tree_array.inject do |a, b|
      a_arr = a.arr
      b_arr = b.arr
      puts "----------------------"
      puts "  #{a_arr}"
      puts "+ #{b_arr}"
      c = a.basic_add_to(b)
      iteratively_explore(c)
      puts "= #{c.arr}"
      yield(a_arr, b_arr, c) if blk
      # break
      c
    end
  end

  def sumup_test(i, out, each_sum: nil)
    raise "???" unless each_sum.nil? || (i.size - 1 == each_sum.size) # validate each_sum value

    i.map! {new_tree(_1)}

    t = if each_sum
      current = 0
      sumup(i) do |a_arr, b_arr, c|
        out = each_sum[current]
        actual = c.arr
        if out != actual
          raise "\n\n# test failed:\n- wanted: #{out}\n- got:    #{actual}\n\nfor:\n  #{a_arr}\n+ #{b_arr}"
        end
        current += 1
      end
    else
      sumup(i)
    end

    actual = t.arr
    raise "\n\n# test failed:\n- wanted: #{out}\n- got:    #{actual}" unless out == actual
    t
  end

  def test_mag(i, out)
    t = new_tree(i)
    actual = t.magnitude
    raise "\n\n# test magnitude failed:\n- wanted: #{out}\n- got:    #{actual}" unless out == actual
  end

  def needed_reducing(t)
    iteratively_explore(t) > 0
  end

  def basic_tests
    test([[[[[9,8],1],2],3],4] , [[[[0,9],2],3],4])
    test([7,[6,[5,[4,[3,2]]]]] , [7,[6,[5,[7,0]]]])
    test([[6,[5,[4,[3,2]]]],1] , [[6,[5,[7,0]]],3])
    test([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] , [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]) { break }
    test([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] , [[3,[2,[8,0]]],[9,[5,[7,0]]]])
    test([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] , [[3,[2,[8,0]]],[9,[5,[7,0]]]])
    test(10, [5,5])
    test(11, [5,6])
    test(12, [6,6])

    test([[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]], [[[[0,7],4],[[7,8],[6,0]]],[8,1]], iter: true)

    sumup_test([
      [1,1],
      [2,2],
      [3,3],
      [4,4],
    ], [[[[1,1],[2,2]],[3,3]],[4,4]])

    sumup_test([
      [1,1],
      [2,2],
      [3,3],
      [4,4],
      [5,5],
    ], [[[[3,0],[5,3]],[4,4]],[5,5]])

    sumup_test([
      [1,1],
      [2,2],
      [3,3],
      [4,4],
      [5,5],
      [6,6],
    ], [[[[5,0],[7,4]],[5,5]],[6,6]])

    test_mag([[1,2],[[3,4],5]] , 143)
    test_mag([[[[0,7],4],[[7,8],[6,0]]],[8,1]] , 1384)
    test_mag([[[[1,1],[2,2]],[3,3]],[4,4]] , 445)
    test_mag([[[[3,0],[5,3]],[4,4]],[5,5]] , 791)
    test_mag([[[[5,0],[7,4]],[5,5]],[6,6]] , 1137)
    test_mag([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]] , 3488)
  end

  def one
    t = new_tree(eval("[[[[[9,8],1],2],3],4]"))
    explore(t) {}

    basic_tests

    test([ [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]], [7,[[[3,7],[4,3]],[[6,3],[8,8]]]] ], [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]], iter: true)

    # does not pass.
    # sumup_test([
    #   [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]],
    #   [7,[[[3,7],[4,3]],[[6,3],[8,8]]]],
    #   [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]],
    #   [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]],
    #   [7,[5,[[3,8],[1,4]]]],
    #   [[2,[2,2]],[8,[8,1]]],
    #   [2,9],
    #   [1,[[[9,3],9],[[9,0],[0,7]]]],
    #   [[[5,[7,4]],7],1],
    #   [[[[4,2],2],6],[8,7]],
    # ], [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]], each_sum: [

    #   [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]],
    #   [[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]],
    #   [[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]],
    #   [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]],
    #   [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]],
    #   [[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]],
    #   [[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]],
    #   [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]],
    #   [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]],

    # ])

    @data.each do |line|
      raise "input is not safe" if needed_reducing(line)
    end

    # result = sumup_test(
    #   [
    #     [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]],
    #     [[[5,[2,8]],4],[5,[[9,9],0]]],
    #     [6,[[[6,2],[5,6]],[[7,6],[4,7]]]],
    #     [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]],
    #     [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]],
    #     [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]],
    #     [[[[5,4],[7,7]],8],[[8,3],8]],
    #     [[9,3],[[9,9],[6,[4,9]]]],
    #     [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]],
    #     [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]],
    #   ],

    #   [[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]],
    # )
    # puts
    # puts
    # puts result.arr.inspect
    # puts result.magnitude

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
