# require 'addressable'
require 'cocoapods-downloader'
require 'uri'
require 'net/http'
require 'json'

module Pod
  module Downloader

    class Maven < Base
      def self.options
        [:repo, :group, :artifact, :version, :type, :md5, :sha1,]
      end

      USER_AGENT_HEADER = 'User-Agent'.freeze

      class UnsupportedFileTypeError < StandardError; end

      private

      executable :curl
      executable :mvn
      executable :unzip
      executable :tar
      executable :hdiutil
      # @return [String] the url of the remote source.
      #
      attr_accessor :filename, :download_path

      def self.preprocess_options(options)

        debug_puts "preprocess_options: #{options}"
        artifact_item = self.request_artifact(options[:maven], options)
        debug_puts artifact_item
        md5Val = artifact_item.checksum.md5

        if options.key?(:md5)
          raise "md5 value is not matched with remote file" unless options[:md5] == md5Val
        else
          options[:md5] = md5Val
        end


        # TODO: also check sha1
        options
      end

      def self.request_artifact(url, options)

        # https://stackoverflow.com/a/70596332/11884593
        # http://192.168.138.192:8081/#admin/system/api
        uri = URI("#{url}/service/rest/v1/search/assets")
        params = {
          'sort' => 'version',
          'repository' => options[:repo],
          'maven.groupId' => options[:group],
          'maven.artifactId' => options[:artifact],
          # maven don't allow '/' in version, so we replace it with '_' automatically
          'maven.baseVersion' => options[:version].gsub('/', '_'),
          'maven.extension' => options[:type],
          'prerelease' => false
        }
        uri.query = URI.encode_www_form(params)

        debug_puts("uri: #{uri}")
        res = Net::HTTP.get_response(uri)
        raise DownloaderError, 'Search failed!' if res.is_a?(Net::HTTPError) || res.body.to_s.empty?
        debug_puts "res.body: #{res.body.to_s}"

        parsed_model = JSON.parse(res.body, object_class: OpenStruct)
        raise DownloaderError, "Can't find matched artifact!" if parsed_model.items.empty?
        debug_puts "aaa3: #{parsed_model.items.first}"
        parsed_model.items.to_a.first

      end

      def download!
        @filename = filename_with_type(type)
        @download_path = target_path + @filename
        download_file(@download_path)
        verify_checksum(@download_path)
        extract_with_type(@download_path, type)
      end

      def type
        if options[:type]
          options[:type].to_sym
        else
          type_with_url(url)
        end
      end

      def headers
        options[:headers]
      end

      # @note   The archive is flattened if it contains only one folder and its
      #         extension is either `tgz`, `tar`, `tbz` or the options specify
      #         it.
      #
      # @return [Bool] Whether the archive should be flattened if it contains
      #         only one folder.
      #
      def should_flatten?
        if options.key?(:flatten)
          options[:flatten]
        elsif %i[tgz tar tbz txz].include?(type)
          true # those archives flatten by default
        else
          false # all others (actually only .zip) default not to flatten
        end
      end

      def type_with_url(url)
        case URI.parse(url).path
        when /\.zip$/
          :zip
        when /\.(tgz|tar\.gz)$/
          :tgz
        when /\.tar$/
          :tar
        when /\.(tbz|tar\.bz2)$/
          :tbz
        when /\.(txz|tar\.xz)$/
          :txz
        when /\.dmg$/
          :dmg
        end
      end

      def filename_with_type(type = :zip)
        case type
        when :zip, :tgz, :tar, :tbz, :txz, :dmg
          "file.#{type}"
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{type}"
        end
      end

      def extract_with_type(full_filename, type = :zip)
        unpack_from = full_filename
        unpack_to = @target_path

        case type
        when :zip
          unzip! unpack_from, '-d', unpack_to
        when :tar, :tgz, :tbz, :txz
          tar! 'xf', unpack_from, '-C', unpack_to
        when :dmg
          extract_dmg(unpack_from, unpack_to)
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{type}"
        end

        # If the archive is a tarball and it only contained a folder, move its
        # contents to the target (#727)
        #
        if should_flatten?
          contents = target_path.children
          contents.delete(target_path + @filename)
          entry = contents.first
          if contents.count == 1 && entry.directory?
            tmp_entry = entry.sub_ext("#{entry.extname}.tmp")
            begin
              FileUtils.move(entry, tmp_entry)
              FileUtils.move(tmp_entry.children, target_path)
            ensure
              FileUtils.remove_entry(tmp_entry)
            end
          end
        end

        FileUtils.rm(unpack_from) if File.exist?(unpack_from)
      end

      def extract_dmg(unpack_from, unpack_to)
        require 'rexml/document'
        plist_s = hdiutil! 'attach', '-plist', '-nobrowse', unpack_from, '-mountrandom', unpack_to
        plist = REXML::Document.new plist_s
        xpath = '//key[.="mount-point"]/following-sibling::string'
        mount_point = REXML::XPath.first(plist, xpath).text
        FileUtils.cp_r(Dir.glob(mount_point + '/*'), unpack_to)
        hdiutil! 'detach', mount_point
      end

      def compare_hash(filename, hasher, hash)
        incremental_hash = hasher.new

        File.open(filename, 'rb') do |file|
          buf = ''
          incremental_hash << buf while file.read(1024, buf)
        end

        computed_hash = incremental_hash.hexdigest

        return unless computed_hash != hash

        raise DownloaderError, 'Verification checksum was incorrect, ' \
          "expected #{hash}, got #{computed_hash}"
      end

      # Verify that the downloaded file matches a sha1 hash
      #
      def verify_sha1_hash(filename, hash)
        require 'digest/sha1'
        compare_hash(filename, Digest::SHA1, hash)
      end

      # Verify that the downloaded file matches a sha256 hash
      #
      def verify_sha256_hash(filename, hash)
        require 'digest/sha2'
        compare_hash(filename, Digest::SHA2, hash)
      end

      # Verify that the downloaded file matches the hash if set
      #
      def verify_checksum(filename)
        if options[:sha256]
          verify_sha256_hash(filename, options[:sha256])
        elsif options[:sha1]
          verify_sha1_hash(filename, options[:sha1])
        end
      end

      def download_file(download_path)
        debug_puts "hl: download_file: #{download_path}"
        artifact_item = Maven.request_artifact(url, options)
        source_url = artifact_item.downloadUrl
        parameters = ['-f', '-L', '-o', download_path, source_url, '--create-dirs', '--netrc-optional', '--retry', '2']
        parameters << user_agent_argument if headers.nil? ||
                                             headers.none? { |header| header.casecmp(USER_AGENT_HEADER).zero? }

        unless headers.nil?
          headers.each do |h|
            parameters << '-H'
            parameters << h
          end
        end

        debug_puts "curl parameters: #{parameters}"
        curl! parameters
      end

      # Returns a cURL command flag to add the CocoaPods User-Agent.
      #
      # @return [String] cURL command -A flag and User-Agent.
      #
      def user_agent_argument
        debug_puts "1"
        "-A '#{Http.user_agent_string}'"
      end

    end
  end
end
