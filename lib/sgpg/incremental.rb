# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'time'

# Exemple: https://peerdh.com/blogs/programming-insights/creating-a-ruby-gem-for-incremental-backup-strategies
module Sgpg
  # Incremental save
  class Incremental
    attr_accessor :source, :destination, :last_backup_time

    def initialize(source, destination)
      #raise ArgumentError, 'No dest, missed to mount stockage disk?' unless Dir.exist?(destination)

      @source = source
      @destination = destination
      @last_backup_time = read_last_backup_time
      @need_full_backup = check_time(@last_backup_time)
    end

    def check_time(time)
      return false unless time

      t = time
      t.is_a?(Time)
    end

    def perform_backup
      files = @last_backup_time ? files_to_backup : full_backup
      puts "Incremental backup #{@need_full_backup}"

      copy_directory_structure(files)
      copy_files(files)
      write_backup_time
    end

    private

    def write_backup_time
      return unless @destination.match?(/sgpg/)

      pn = Pathname.new(@destination)
      dest = "#{pn.dirname}/last-backup"
      File.write(dest, Time.now)

      @last_backup_time = Time.now
      puts "last backup #{@last_backup_time}"
    end

    def read_last_backup_time
      return unless @destination.match?(/sgpg/)

      pn = Pathname.new(@destination)
      dest = "#{pn.dirname}/last-backup"
      File.exist?(dest) ? Time.parse(File.read(dest)) : nil
    end

    def full_backup
      Dir.glob(File.join(@source, '**', '*')).select do |file|
        File.file?(file)
      end
    end

    def files_to_backup
      Dir.glob(File.join(@source, '**', '*')).select do |file|
        File.file?(file) && File.mtime(file) > @last_backup_time
      end
    end

    # Skip files, only copy directories
    def copy_directory_structure(files)
      files.each do |file|
        new_dir = file.sub(@source, @destination)
        pn = Pathname.new(new_dir)
        puts "add dir #{pn.dirname}"
        FileUtils.mkdir_p(pn.dirname)
      end
    end

    def copy_files(files)
      files.each do |file|
        #destination_path = File.join(@destination, File.basename(file))
        destination_path = file.sub(@source, @destination)
        puts "cpy #{file} to dest #{destination_path}"
        FileUtils.cp(file, destination_path, preserve: true)
      end
    end
  end
end
