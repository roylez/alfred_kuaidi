obj = "kuaidi.alfredworkflow"

desc "pack all in #{obj}"
task :build do
  FileUtils.rm_f obj
  puts "Packing all files in #{obj}:"
  exec "zip -r #{obj} *"
end

task :default => :build
