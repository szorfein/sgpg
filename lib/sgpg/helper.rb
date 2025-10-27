# frozen_string_literal: true

# lib/helper.rb

module Sgpg
  # Reusable functions for the program
  module Helper
    def self.auth?
      return :root if Process.uid == '0'
      return :doas if File.exist?('/bin/doas') || File.exist?('/sbin/doas')
      return :sudo if File.exist?('/bin/sudo') || File.exist?('/sbin/sudo')
    end

    def self.mv(src, dest)
      case auth?
      when :root then FileUtils.mv(src, dest)
      when :sudo then system('sudo', 'mv', src, dest)
      when :doas then system('doas', 'mv', src, dest)
      end
    end

    def self.mkdir(path_dir)
      case auth?
      when :root then FileUtils.mkdir(path_dir)
      when :sudo then system('sudo', 'mkdir', '-p', path_dir)
      when :doas then system('doas', 'mkdir', '-p', path_dir)
      end
    end

    def self.search_dest
      Dir.exist?("#{Sgpg::KEYDIR}/Persistent") ? "#{Sgpg::KEYDIR}/Persistent" : Sgpg::KEYDIR
    end

    def self.chmod(perm, file_path)
      case auth?
      when :root then FileUtils.chmod perm, file_path, verbose: true
      when :sudo then system('sudo', 'chmod', perm, file_path)
      when :doas then system('doas', 'chmod', perm, file_path)
      end
    end
  end
end
