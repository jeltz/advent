count = 0
File.each_line(ARGV[0]) do |l|
  count += l.split(/ \| /)[1].split(/ /).count { |d| [2, 3, 4, 7].includes?(d.size) }
end
puts count
