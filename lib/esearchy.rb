#EXTERNAL REQUIRES
require 'rubygems'
require 'net/http'
require 'cgi'
require 'json'
require 'digest/sha2'
require 'zip/zip'
require 'uri'
require 'zip/zipfilesystem'
require 'pdf/reader'
if RUBY_PLATFORM =~ /mingw|mswin/
 require 'win32ole'
end
#require 'ldap' # gem install ruby-ldap

#ESEARCHY REQUIRES
require 'esearchy/genericengine'
require 'esearchy/searchengines'
require 'esearchy/otherengines'
require 'esearchy/socialengines'
require 'esearchy/localengines'
require 'esearchy/bugmenot'
require 'esearchy/docs'
require 'esearchy/profiling'
require 'esearchy/useragent'
require 'esearchy/esearchy'
