require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'

# We sometimes refer to non-nebula puppet fileserver paths.
PuppetLint.configuration.send('disable_puppet_url_without_modules')

desc "run librarian-puppet to confirm dependencies are resolvable"
task librarian: [:librarian_standalone, :librarian_clean]

desc "don't clean after librarian"
task :librarian_standalone do |t|
  system('librarian-puppet install --verbose') or abort
end

desc "rm Puppetfile.lock"
task :librarian_clean do |t|
  FileUtils.rm_f('Puppetfile.lock')
end
