module Part2
    def self.simplify(str)
        puts("\nprocessing #{str.inspect}")
        cs = str.chars
        tally = cs.tally
        jokers = tally.delete("J") || 0
        count_to_keys = tally.group_by{_2}.transform_values {|v| v.map{_1[0]}}
        puts(count_to_keys)
        puts("jokers: #{jokers}")
        result = ""
        letter = "a"
        count_to_keys.keys.sort.reverse.each do |count|
            keys = count_to_keys[count]
            keys.each do
                result += letter * count
                letter = letter.succ
            end
        end
        result + ("J" * jokers)
    end
    def self.que(str)
        puts("#{str} -> #{simplify(str)}")
    end
    def self.main
        que("32T3K")
        que("T55J5")
        que("KK677")
        que("KTJJT")
        que("QQQJA")
    end
end
Part2.main