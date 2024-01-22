# cocoapods-maven

Enable cocoapods to download iOS framework file from maven.

## Installation

Install the plugin by adding to your Gemfile

```ruby
gem 'cocoapods-maven'
```

Alternatively, install directly with the command `gem install cocoapods-maven`.

## Usage

Add to your Podfile

```ruby
plugin 'cocoapods-maven'
```

If you want to referencing a pod in Maven, you can direct use `:maven` in your Podfile:

```ruby
pod 'xxx', :maven => {{SERVER_URL}}, :repo => {{REPO_NAME}}, :group => {{GROUP_ID}}, :artifact => {{ARTIFACT_ID}}, :type => {{TYPE}}, :version => {{VERSION}}
```

Or Use podspecs with `:maven` type on source. Example:

```ruby
s.source = { :maven => {{SERVER_URL}}, :repo => {{REPO_NAME}}, :group => {{GROUP_ID}}, :artifact => {{ARTIFACT_ID}}, :type => {{TYPE}}, :version => {{VERSION}}  }
```

- `SERVER_URL`: The server URL where the Maven service has been depoyed, e.g. `http://192.168.6.1:8081`
- `REPO_NAME`: Repository name, e.g. `ios-framework`
- `GROUP_ID`: Maven groupId, e.g. `com.xxx.ios`
- `ARTIFACT_ID`: Maven artifactId, e.g. `App`
- `TYPE`: Maven extension of component's asset, e.g. `zip`
- `VERSION`: Maven base version, e.g. `0.0.1`

The structure of zip file hosted in Maven like:

```txt
.
├── App.podspec
└── App.xcframework
```

## Build

```sh
git clone git://github.com/hanleylee/cocoapods-maven.git
cd cocoapods-maven
gem build cocoapods-maven
gem install cocoapods-maven-x.x.x.gem
```
