# frozen_string_literal: true

require 'fileutils'

module Sgpg
  # Interact with program tar from unix
  class Archive
    # Code here
    def initialize(key, name = nil)
      raise ArgumentError, "No #{name}..." unless name

      @key = key || ''
      @name = name
      @date = Time.now.strftime('%Y-%m-%d')
      puts "create key #{@name}-#{@date}-master.tar"
      FileUtils.mkdir_p Sgpg::WORKDIR
      @gpg = Gpg.new(@name)
      # Make it compatible with Tails Linux
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

    # Tail Linux create an encrypted partition with a directory named Persistent
    def move_to_disk
      dest = Helper.search_dest
      final_dest = "#{dest}/#{@name}" # we add the key name

      Helper.mkdir(final_dest)
      Helper.chmod('0755', final_dest)

      tar = Dir.glob("#{Sgpg::WORKDIR}/*.tar")
      raise 'No archive found.' unless tar.length >= 1

      mv(tar, final_dest)
    end

    private

    def import_secret(keys)
      keys.each do |k|
        puts "importing secret #{k}..."
        system('gpg', '-a', '--import', k) if k.match?(/secret/)
      end
    end

    def import_public(keys)
      keys.each do |k|
        puts "importing public #{k}..."
        system('gpg', '-a', '--import', k) if k.match?(/public/)
      end
    end

    # Suffix should be 'master' or 'lesser' (keys without privilege)
    def create_tar(suffix = 'master')
      if suffix == 'master'
        # In theory, you can create the certificate any time as you have the master key
        #system("tar -cf #{@name}-#{@date}-#{suffix}-keys.tar *.key *.cert")
        system("tar -cf #{@name}-#{@date}-#{suffix}-keys.tar *.key")
      else
        system("tar -cf #{@name}-#{@date}-#{suffix}-keys.tar *.key")
      end
    end

    def mv(tar, pathdir)
      puts "Moving archive at #{pathdir}..."
      tar.each do |f|
        file = File.basename(f)
        Helper.mv(f, pathdir)
        Helper.chmod('0644', "#{pathdir}/#{file}")
      end
    end
  end
end
