#!/usr/bin/ruby

Dir.entries(".").each do | name |
  next unless name =~ /^[\w-]+\.png/
  cmd = "tiffutil -cathidpicheck #{name} #{name.gsub(/\./, "@2x.")} -out #{name.gsub(/png$/, "tiff")}"
  puts "+ #{cmd}"
  `#{cmd}`
end
