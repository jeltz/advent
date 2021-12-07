File.open(ARGV[0]) do |f|
  numbers = f.read_line.split(/,/).map(&.to_i)
  boards = Array(Array(Array(Int32))).new
  while f.gets
    boards << (0...5).map { f.read_line.strip.split(/ +/).map(&.to_i) }
  end

  won = Set(Int32).new
  numbers.each do |n|
    boards.each_with_index do |b, k|
      next if won.includes?(k)

      (0...5).each do |i|
        (0...5).each do |j|
          b[i][j] = 0 if b[i][j] == n
        end
      end

      (0...5).each do |i|
        if b[i] == [0, 0, 0, 0, 0] || b.transpose[i] == [0, 0, 0, 0, 0]
          won << k
          if won.size == boards.size
            puts b.flatten.sum * n
            exit
          end
        end
      end
    end
  end
end
