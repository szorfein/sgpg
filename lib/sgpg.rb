# frozen_string_literal: true

require_relative 'sgpg/version'
require_relative 'sgpg/option'
require_relative 'sgpg/yaml_config'
require_relative 'sgpg/helper'
require_relative 'sgpg/cryptsetup'
require_relative 'sgpg/mount'
require_relative 'sgpg/gpg'
require_relative 'sgpg/archive'
require_relative 'sgpg/incremental'

# Manage your gpg key
module Sgpg
  def self.open(disk, is_crypted = nil)
    return if Dir.glob("#{Sgpg::MOUNTPOINT}/*").length >= 1

    puts "Open device #{disk}..."
    if is_crypted
      Cryptsetup.new(disk).open
      Mount.new('/dev/mapper/sgpg').open
    else
      Mount.new(disk).open
    end
  end

  def self.close(disk, is_crypted = nil)
    if is_crypted
      Mount.new('/dev/mapper/sgpg').close
      Cryptsetup.new(disk).close
    else
      Mount.new(disk).close
    end
  end

  # https://www.rubyguides.com/2017/07/ruby-sort/
  def self.list_keys(keyname)
    dest = Helper.search_dest
    dest += "/#{keyname}"
    keys = Dir.glob("#{dest}/*.tar")

    puts "Listing keys for #{keyname}..."
    puts keys
  end

  # argument 'suffix' = master or lesser
  def self.last_key(opts, suffix = 'master')
    Sgpg.open(opts[:disk], opts[:crypted])

    dest = Helper.search_dest
    dest += "/#{opts[:keyname]}"
    keys = Dir.glob("#{dest}/#{opts[:keyname]}*#{suffix}*.tar").sort

    raise 'No keys found' unless keys.length >= 1

    keys.last
  end

  def self.clear_keys
    return unless Dir.glob("#{Sgpg::WORKDIR}/*.key").length >= 1

    puts "Clearing #{Sgpg::WORKDIR}..."
    system("shred -u #{Sgpg::WORKDIR}/*.key")
  end

  # Main logic here
  module Main
    # import and edit a gpg key from an archive (opts[:keypath])
    def self.edit_key(opts)
      Sgpg.open(opts[:disk], opts[:crypted])
      archive = Archive.new(opts[:keypath], opts[:keyname])
      archive.extract
      archive.import
      Sgpg.clear_keys
    end

    # Export your real keys and create an archive (tar)
    def self.export_secret(opts)
      archive = Archive.new(opts[:keypath], opts[:keyname])
      archive.create_master_tar
      archive.move_to_disk
      Sgpg.clear_keys
    end

    # Create an unprivileged GnuPG key (no change can be made)
    def self.lesser_keys(opts)
      archive = Archive.new(opts[:keypath], opts[:keyname])
      archive.create_lesser_tar
      archive.move_to_disk
      Sgpg.clear_keys
    end

    # Replace 'path/to/source' and 'path/to/destination' with actual paths on your machine. Run the script:
    # pass store password at ~/.password-store by default
    def self.incremental_export(keyname)
      raise ArgumentError, 'incremental_export: No keyname' unless keyname

      src = "#{ENV['HOME']}/.password-store"
      dest = Helper.search_dest
      dest += "/#{keyname}/.password-store"
      puts "Exporting passwords from #{src} to #{dest}..."
      backup = Incremental.new(src, dest)
      backup.perform_backup
    end

    def self.incremental_import(keyname)
      raise ArgumentError, 'incremental_export: No keyname' unless keyname

      dest = "#{ENV['HOME']}/.password-store"
      src = Helper.search_dest
      src += "/#{keyname}/.password-store"
      puts "Importing passwords from #{src} to #{dest}..."
      backup = Incremental.new(src, dest)
      backup.perform_backup
    end
  end
end
