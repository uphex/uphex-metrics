#!/usr/bin/env ruby

# Create a dummy Makefile to prevent 'gem install' from borking out.
File.open("Makefile", "w") do |f|
  f << "all:\n"
  f << "\ttrue\n"
  f << "install:\n"
  f << "\ttrue\n"
end

puts "Installing python dependencies..."

unless `which apt-get`.empty?
  `sudo apt-get install python-numpy python-scipy python-statsmodels -Y`
end

unless `which pacman`.empty?
  `sudo pacman -S python2 python2-numpy python2-scipy python2-statsmodels --noconfirm`
end

if `python2 --version 2>&1` =~ /Python 2\.\d+\.\d+\n/
  puts "Python dependencies installed."
else
  raise "Couldn't install Python dependencies."
end
