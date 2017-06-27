Gem::Specification.new do |s|
  s.name = 'mdc'
  s.summary = 'Creates presentation slides as PDF (using LaTeX) or HTML from Markdown sources.'
  s.description = File.read(File.join(File.dirname(__FILE__), 'readme.md'))
  s.requirements = [ 'GNU Make for building the presentations', 'LaTeX in case you want to generate PDF slides', 'rsync' ]
  s.version = '1.0.1'
  s.author = 'Thomas Smits'
  s.email = 'thomsmits@gmai.com'
  s.homepage = 'https://smits-net.de'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.0'
  s.files = Dir[ 'lib/**', 'bin/**' ]
  s.executables = [ 'main.rb' ]
  s.test_files = Dir[ 'test/*.rb' ]
  s.licenses = 'MIT'
  s.has_rdoc = false
end