$:.push File.expand_path('../lib, __FILE__')

Gem::Specification.new do |s|
  s.name        = 'git_auto_checkout'
  s.version     = '0.1.1'
  s.license     = 'BSD 3-Clause'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Saghm Rossi']
  s.email       = ['saghmrossi@gmail.com']
  s.homepage    = ''
  s.summary     = %q{Helper to checkout out old commits.}
  s.description = %q{
                      Gives a console-based prompt of all of the past commits,
                      and allows the user to select one to checkout.
                    }
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
                       File.basename(f)
                     end
  s.require_paths = ['lib']
end
