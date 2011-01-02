#!/usr/bin/ruby -w
#: Title		: t2l (Tree to Lines)
#: Date			: 2010-06-07
#: Author		: "Eugene Fokin" <ginfonic@gmail.com>
#: Version		: 1.0
#: Description	: Converts text file with hierarchical tree of
#: Description	: new line delimited archive/artist/album records:
#: Description	: ARCHIVE_NAME {Archive Name}
#: Description	: <TAB>ARTIST {Artist}
#: Description	: <TAB><TAB>YEAR ALBUM CODEC {Year, Album & Codec}
#: Description	: to lines with <TAB> delimited records:
#: Description	: ARCHIVE_NAME<TAB>ARTIST<TAB>YEAR<TAB>ALBUM<TAB>CODEC
#: Description	: Year and Codec records are optional.
#: Description	: They should be included in Album record
#: Description	: and delimited from Album with a space i.e:
#: Description	: 2009 Album Name LOSSY
#: Description	: Year record should be between 1900 and 2099.
#: Description	: Codec record should be from this list:
#: Description	: LOSSY, LOSSLESS
#: Arguments	: input_file
#Reads input file name from arguments and creates output file name.
if ARGV.length > 0
  in_file = ARGV[0]
  dot_i = in_file.rindex('.')
  out_file = in_file.slice(0, dot_i) + '-tab' + in_file.slice(dot_i, in_file.length - dot_i)
else
  puts 'Please, select an input text file!'
  exit
end
#Reads input file strings to array.
lines = []
File.foreach(in_file) do |line|
  lines << line.chomp
end
#Fills tree of records with data from input array.
Tree = Struct.new(:name, :items)
archives = []
for line in lines
  if line.slice(0, 1) != "\t"
    artists = [];
    archives << Tree.new(line, artists)
  elsif line.slice(1, 1) != "\t"
    albums = []
    artists << Tree.new(line.slice(1, line.length - 1), albums)
  else
    albums << line.slice(2, line.length - 2)
  end
end
#Splits Album to Year/Album/Codec.
def split_album(album)
  words = album.split
  codec = words.last == 'LOSSY' || words.last == 'LOSSLESS' ? words.pop : ''
  year = words.length > 1 && words.first =~ /(19|20)\d{2}/ ? words.shift : ''
  return year + "\t" + words.join(' ') + "\t" + codec
end
#Fills output array with records from the records tree.
lines = []
for archive in archives
  for artist in archive.items
    for album in artist.items
      lines << archive.name + "\t" + artist.name + "\t" + split_album(album)
    end
  end
end
#Writes strings from array to output file.
#puts lines
File.open(out_file, 'w') do |fp|
  fp.puts lines
end