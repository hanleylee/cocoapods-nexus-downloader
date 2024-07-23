module CocoapodsNexusDownloader
  class << self
    attr_accessor :debug

    Pod::HooksManager.register('cocoapods-nexus-downloader', :pre_install) do |_context, options|
      CocoapodsNexusDownloader.pre_install(options)
    end

    def debug_puts(content)
      return unless CocoapodsNexusDownloader.debug

      puts content
    end

    def pre_install(options)
      @debug = options.fetch(:debug, false)
      CocoapodsNexusDownloader.debug_puts "pre_install hook: #{options}"
    end
  end
end
