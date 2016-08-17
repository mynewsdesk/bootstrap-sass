require 'find'
require 'json'
require 'pathname'

namespace :bower do

  find_files = ->(path) {
    Find.find(Pathname.new(path).relative_path_from(Pathname.new Dir.pwd).to_s).map do |path|
      path if File.file?(path)
    end.compact
  }

  desc 'update main and version in bower.json'
  task :generate do
    require 'bootstrap-sass3'
    Dir.chdir Bootstrap3.gem_path do
      spec       = JSON.parse(File.read 'bower.json')
      js_paths   = File.read(File.join Bootstrap3.javascripts_path, 'bootstrap3.js').lines.map do |line|
        line.strip if line.sub!(%r(//\s*=\s*require\s*(.*)\s*), 'assets/javascripts/\1.js')
      end.compact


      spec['main'] =
          find_files.(File.join(Bootstrap3.stylesheets_path, '_bootstrap3.scss')) +
          find_files.(Bootstrap3.fonts_path) +
          %w(assets/javascripts/bootstrap.js)


      File.open('bower.json', 'w') do |f|
        f.puts JSON.pretty_generate(spec)
      end
    end
  end
end
