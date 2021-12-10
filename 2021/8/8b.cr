D = [
  "abcefg",
  "cf",
  "acdeg",
  "acdfg",
  "bcdf",
  "abdfg",
  "abdefg",
  "acf",
  "abcdefg",
  "abcdfg",
]
sum = 0
File.each_line(ARGV[0]) do |l|
  a, b = l.split(/ \| /)
  all = a.split(/ /)
  output = b.split(/ /)
  "abcdefg".chars.each_permutation do |cs|
    d = all.map { |a| a.chars.map { |c| cs[c - 'a'] }.sort.join }
    if D.sort == d.sort
      sum += output.map { |a| D.index(a.chars.map { |c| cs[c - 'a'] }.sort.join).to_s }.join.to_i
    end
  end
end
puts sum
