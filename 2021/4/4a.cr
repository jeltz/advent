File.open(ARGV[0]) do |f|
  numbers = f.read_line.split(/,/).map(&.to_i)
  boards = Array(Array(Array(Int32))).new
  while f.gets
    boards << (0...5).map { f.read_line.strip.split(/ +/).map(&.to_i) }
  end

  numbers.each do |n|
    boards.each do |b|
      (0...5).each do |i|
        (0...5).each do |j|
          b[i][j] = 0 if b[i][j] == n
        end
      end

      (0...5).each do |i|
        if b[i] == [0, 0, 0, 0, 0] || b.transpose[i] == [0, 0, 0, 0, 0]
          puts b.flatten.sum * n
          exit
        end
      end
    end
  end
end
