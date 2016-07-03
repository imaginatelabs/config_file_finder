require 'config_file_finder/version'

class ConfigFileFinder
  attr_accessor :root_patterns

  SYSTEM_ROOT = '/'.freeze
  DEFAULT_ROOT_PATTERNS = %w(.git/ .hg/ .svn/ lib/ bin/ src/ test/ README.md README.txt README.markdown README).freeze

  def initialize(config_file_name, options = {})
    @config_file_name = config_file_name
    @options = options
    @root_patterns = [] + DEFAULT_ROOT_PATTERNS
  end

  def default_root_patterns
    @root_patterns
  end

  def add_root_patterns(root_patterns = [])
    @root_patterns = (@root_patterns << root_patterns).flatten.uniq
  end

  def find
    dir = Dir.pwd
    loop do
      file = File.expand_path(@config_file_name, dir)
      return { result: :success, files: [{ config_type(dir) => file }] } if File.exist? file
      break if stop_searching? dir
      dir = File.expand_path('..', dir)
    end
    failure_results(dir)
  end

  def project_root?(dir)
    detect_project_root_files(dir).any?
  end

  def detect_project_root_files(dir)
    matches = []
    @root_patterns.each do |root_pattern|
      file = File.expand_path(root_pattern, dir)
      matches << file if File.exist? file
    end
    matches
  end

  private

  def failure_results(dir)
    dir_type = dir_type(dir)
    message = "Couldn't find config file #{@config_file_name}, "\
              "stopping search at #{dir_type.to_s.tr('_', ' ')} directory"
    { result: :failed, files: [dir_type => dir], message: message }
  end

  def stop_searching?(dir)
    project_root?(dir) || dir == Dir.home || dir == SYSTEM_ROOT
  end

  def config_type(dir)
    :"#{dir_type(dir)}_config"
  end

  def dir_type(dir)
    return :project_root if project_root?(dir)
    case dir
    when SYSTEM_ROOT then return :system_root
    when Dir.home then return :user_root
    else return :unknown
    end
  end
end
