def debug_puts(content)
  return unless CocoapodsNexusDownloader.debug

  puts content
end

module CocoapodsNexusDownloader
  class << self
    # @return [Bool] the url of the remote source.
    #
    attr_accessor :debug

    Pod::HooksManager.register('cocoapods-nexus-downloader', :pre_install) do |_context, options|
      CocoapodsNexusDownloader.pre_install(options)
    end

    def pre_install(options)
      debug_puts "pre_install hook: #{options}"
      # Now we can configure the downloader to use the Azure CLI for downloading pods from the given hosts
      @debug = options.fetch(:debug, false)
    end
  end
end
