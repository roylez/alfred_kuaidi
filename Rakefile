obj = "kuaidi.alfredworkflow"

desc "pack all in #{obj}"
task :build do
  FileUtils.rm_f obj
  puts "Packing all files in #{obj}:"
  exec "zip -r #{obj} *"

  files_to_zip = FileList["**"]

  Zip::File.open(obj, Zip::File::CREATE) do |zip|
    files_to_zip.each do |filename|
      zip.add(filename, filename)
    end
  end  
end

task :default => :build
