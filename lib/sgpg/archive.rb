# frozen_string_literal: true

require 'fileutils'

module Sgpg
  # Interact with program tar from unix
  class Archive
    # Code here
    def initialize(key, name = ENV['USER'])
      @key = key || ''
      @name = name
      @date = Time.now.strftime('%Y-%m-%d')
      puts "create key #{@name}-#{@date}-master.tar"
      FileUtils.mkdir_p Sgpg::WORKDIR
      @gpg = Gpg.new(@name)
      # make it compatabble with Tails Linux
    end

    def create_master_tar
      Dir.chdir(Sgpg::WORKDIR)
      @gpg.export_secret_keys(Sgpg::WORKDIR)
      create_tar('master')
    end

    def create_lesser_tar
      Dir.chdir(Sgpg::WORKDIR)
      @gpg.export_subkey(Sgpg::WORKDIR)
      @gpg.delete_keys
      @gpg.import_lesser_keys
      @gpg.export_secret_keys(Sgpg::WORKDIR)
      create_tar('lesser')
    end

    def extract
      raise 'No key found, try with --path-key PATH.' unless File.exist?(@key)

      Dir.chdir(Sgpg::WORKDIR)
      puts "Unpacking archive #{@key}..."
      system('tar', 'xvf', @key)
    end

    def import
      @gpg.delete_keys
      puts 'Importing gpg keys...'
      keys = Dir.glob("#{Sgpg::WORKDIR}/*.key")
      import_secret(keys)
      import_public(keys)
      @gpg.edit_key
    end

    def move(pathdir)
      raise "Dir #{pathdir} no found." unless Dir.exist?(pathdir)

      tar = Dir.glob("#{Sgpg::WORKDIR}/*.tar")
      raise 'No archive found.' unless tar.length >= 1

      mv(tar, pathdir)
    end

    private

    def import_secret(keys)
      keys.each { |k| system('gpg', '-a', '--import', k) if k.match(/secret/) }
    end

    def import_public(keys)
      keys.each { |k| system('gpg', '-a', '--import', k) if k.match(/public/) }
    end

    # suffix should be 'master' or 'lesser' (keys without privilege)
    def create_tar(suffix = 'master')
      if suffix == 'master'
        system("tar -cf #{@name}-#{@date}-#{suffix}-keys.tar *.key revocation.cert")
      else
        system("tar -cf #{@name}-#{@date}-#{suffix}-keys.tar *.key")
      end
    end

    def mv(tar, pathdir)
      puts "Moving archive at #{pathdir}..."
      case Helper.auth?
      when :root
        tar.each { |f| FileUtils.mv(f, "#{pathdir}/#{f}") }
      when :sudo
        tar.each { |f| system('sudo', 'mv', f, "#{pathdir}/") }
      when :doas
        tar.each { |f| system('doas', 'mv', f, "#{pathdir}/") }
      end
    end
  end
end
