require 'fileutils'

task :clean do
  rm_rf "ribbons"
  rm_rf "ribbons.tar.gz"
end

task :build do
  FileUtils.mkdir_p("ribbons")
  ruby "ribbon.rb"
end

# Requores svgo, unstall using 'npm install svgo'
task :optimize => :build do
  sh "svgo --multipass --disable=convertStyleToAttrs -f ribbons"
end

task :package => :build do
  sh "tar czf ribbons.tar.gz ribbons/"
end
