desc "run librarian-puppet to confirm dependencies are resolvable"
task librarian: [:librarian_standalone, :librarian_clean]

desc "don't clean after librarian"
task :librarian_standalone do |t|
  system("librarian-puppet install --verbose") or abort
end

desc "rm -rf Puppetfile.lock modules"
task :librarian_clean do |t|
  FileUtils.rm_f("Puppetfile.lock")
  FileUtils.rm_rf("modules")
end
