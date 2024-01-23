require 'cocoapods-downloader'
require 'cocoapods-nexus-downloader/nexus-downloader'

module Pod
  module Downloader
    class <<self
      alias_method :real_downloader_class_by_key, :downloader_class_by_key
    end

    def self.downloader_class_by_key
      original = self.real_downloader_class_by_key
      original[:nexus] = NexusDownloader
      original
    end

  end
end

