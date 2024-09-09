# frozen_string_literal: true

require_relative 'lib/sgpg/version'

# https://guides.rubygems.org/specification-reference/
Gem::Specification.new do |s|
  s.name = 'sgpg'
  s.summary = 'Awesome Ruby Project !'
  s.version = Sgpg::VERSION
  s.platform = Gem::Platform::RUBY

  s.description = <<-DESCRIPTION
    sgpg is just an awesome gem !
  DESCRIPTION

  s.email = 'szorfein@protonmail.com'
  s.homepage = 'https://github.com/szorfein/sgpg'
  s.license = 'MIT'
  s.author = 'szorfein'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/szorfein/sgpg/issues',
    'changelog_uri' => 'https://github.com/szorfein/sgpg/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/szorfein/sgpg',
    'wiki_uri' => 'https://github.com/szorfein/sgpg/wiki',
    'funding_uri' => 'https://patreon.com/szorfein'
  }

  s.files = Dir.glob('{lib,bin}/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  s.files += %w[CHANGELOG.md LICENSE README.md]
  s.files += %w[sgpg.gemspec]

  s.bindir = 'bin'
  s.executables << 'sgpg'
  s.extra_rdoc_files = %w[README.md]

  s.cert_chain = %w[certs/szorfein.pem]
  s.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')

  s.required_ruby_version = '>=2.6'
  s.requirements << 'TODO change: libmagick, v6.0'
  s.requirements << 'TODO change: A good graphics card'
  s.add_runtime_dependency 'thor', '~> 1.0'
end
