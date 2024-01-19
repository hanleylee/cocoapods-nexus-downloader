require 'cocoapods-downloader'
require 'cocoapods-maven/maven-downloader'

module Pod
  module Downloader
    class <<self
      alias_method :real_downloader_class_by_key, :downloader_class_by_key
    end

    def self.downloader_class_by_key
      original = self.real_downloader_class_by_key
      original[:maven] = Maven
      original
    end

  end
end

