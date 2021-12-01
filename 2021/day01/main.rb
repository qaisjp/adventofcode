num = ARGV.shift
puts "q#{num}"
$stuff = ARGF.read.to_s.strip.split.map(&:to_i)

def stuff
    $stuff
end

def one
    count = 0
    stuff.each_with_index do |this, i|
        if i > 0
            if this > stuff[i-1]
                count += 1
            end
        end
    end
    puts count
end

def two
    sum = nil
    count = 0
    stuff.each_cons(3) do |window|
        this_sum = window.sum

        if !sum.nil?
            if this_sum > sum
                count += 1
            end
        end
        sum = this_sum
    end
    puts count
end

if num == "1"
    one
elsif num == "2"
    two
end
