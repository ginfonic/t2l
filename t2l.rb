#!/usr/bin/ruby -w
if ARGV.length > 0
  in_file = ARGV[0]
  dot_i = in_file.rindex('.')
  out_file = in_file.slice(0, dot_i) + '-tab' + in_file.slice(dot_i, in_file.length - dot_i)
else
  puts 'Please, select an input text file!'
  exit
end
lines = []
File.foreach(in_file) do |line|
  lines << line.chomp
end
Item = Struct.new(:name, :items)
archives = []
for line in lines
  if line.slice(0, 1) != "\t"
    artists = [];
    archives << Item.new(line, artists)
  elsif line.slice(1, 1) != "\t"
    albums = []
    artists << Item.new(line.slice(1, line.length - 1), albums)
  else
    albums << line.slice(2, line.length - 2)
  end
end
def split_yac(album)
  words = album.split
  codec = words.last == 'LOSSY' ? words.pop : ''
  year = words.length > 1 && words.first =~ /[12][09]\d{2}/ ? words.shift : ''
  return year + "\t" + words.join(' ') + "\t" + codec
end
lines = []
for archive in archives
  for artist in archive.items
    for album in artist.items
      lines << archive.name + "\t" + artist.name + "\t" + split_yac(album)
    end
  end
end
#puts lines
File.open(out_file, 'w') do |fp|
  fp.puts lines
end