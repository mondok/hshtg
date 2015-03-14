#!/usr/bin/env ruby

require_relative 'lib/hshtg'

# Check for .env file
if File.exist?('.env')
  File.open('.env', 'r').each_line do |line|
    a = line.chomp("\n").split('=', 2)
    a[1].gsub!(/^"|"$/, '') if ['\'', '"'].include?(a[1][0])
    eval "ENV['#{a[0]}']='#{a[1] || ''}'"
  end
end
