# cocoapods-nexus-downloader

Enable cocoapods to download iOS framework file from nexus in maven type.

## Installation

Install the plugin by adding to your Gemfile

```ruby
gem 'cocoapods-nexus-downloader'
```

Alternatively, install directly with the command `gem install cocoapods-nexus-downloader`.

## Usage

Add to your Podfile

```ruby
plugin 'cocoapods-nexus-downloader'
```

If you want to referencing a pod in Nexus, you can direct use `:nexus` in your Podfile:

```ruby
pod 'xxx', :nexus => {{SERVER_URL}}, :repo => {{REPO_NAME}}, :group => {{GROUP_ID}}, :artifact => {{ARTIFACT_ID}}, :type => {{TYPE}}, :version => {{VERSION}}
```

Or Use podspecs with `:nexus` type on source. Example:

```ruby
s.source = { :nexus => {{SERVER_URL}}, :repo => {{REPO_NAME}}, :group => {{GROUP_ID}}, :artifact => {{ARTIFACT_ID}}, :type => {{TYPE}}, :version => {{VERSION}}  }
```

- `SERVER_URL`: The server URL where the Nexus service has been depoyed, e.g. `http://192.168.6.1:8081`
- `REPO_NAME`: Repository name, e.g. `ios-framework`
- `GROUP_ID`: Maven groupId, e.g. `com.xxx.ios`
- `ARTIFACT_ID`: Maven artifactId, e.g. `App`
- `TYPE`: Maven extension of component's asset, e.g. `zip`
- `VERSION`: Maven base version, e.g. `0.0.1`

The structure of zip file hosted in Nexus like:

```txt
.
├── App.podspec
└── App.xcframework
```

## Build

```sh
git clone git://github.com/hanleylee/cocoapods-nexus-downloader.git
cd cocoapods-nexus-downloader
gem build cocoapods-nexus-downloader
gem install cocoapods-nexus-downloader-x.x.x.gem
```
