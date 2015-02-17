#!/usr/bin/env ruby

# Create a dummy Makefile to prevent 'gem install' from borking out.
File.open("Makefile", "w") do |f|
  f << "all:\n"
  f << "\ttrue\n"
  f << "install:\n"
  f << "\ttrue\n"
end

puts "Checking dependencies..."

raise "Python 2 is not installed." if `which python2`.empty?

numpy_version = `python2 -c "import numpy; print numpy.version.version"`.chomp
stats_version = `python2 -c "import statsmodels; print statsmodels.version.version"`.chomp

unless numpy_version =~ /1\.9\.\d/
  raise "Python package numpy 1.9.x is not installed.#{ " (Found: #{numpy_version})" unless numpy_version.empty? }"       
end

unless stats_version =~ /0\.6\.\d/
  raise "Python package statsmodels 0.6.x is not installed.#{ " (Found: #{stats_version})" unless stats_version.empty? }"       
end
