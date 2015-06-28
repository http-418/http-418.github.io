#!/usr/bin/env ruby
require 'fileutils'

poole_path = '/home/ajones/src.dev/ruby/poole'
jekyll_path = File.dirname(__FILE__) + '/..'

relative_file_list =
  [
    "./styles.scss",
    "./atom.xml",
    "./index.html",
    "./_layouts/page.html",
    "./_layouts/post.html",
    "./_layouts/default.html",
    "./_sass/_syntax.scss",
    "./_sass/_code.scss",
    "./_sass/_pagination.scss",
    "./_sass/_masthead.scss",
    "./_sass/_type.scss",
    "./_sass/_message.scss",
    "./_sass/_layout.scss",
    "./_sass/_posts.scss",
    "./_sass/_base.scss",
    "./_includes/head.html",
    "./public/favicon.ico",
    "./public/apple-touch-icon-precomposed.png"
  ]

relative_file_list.each do |relative_path|
  puts "Updating #{relative_path}"
  FileUtils.cp( poole_path + "/" + relative_path,
                jekyll_path + "/" + relative_path )
end
