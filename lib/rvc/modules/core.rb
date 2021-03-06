# Copyright (c) 2011 VMware, Inc.  All Rights Reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

opts :quit do
  summary "Exit RVC"
end

rvc_alias :quit
rvc_alias :quit, :exit
rvc_alias :quit, :q

def quit
  exit
end


opts :reload do
  summary "Reload RVC command modules and extensions"
  opt :verbose, "Display filenames loaded", :short => 'v', :default => false
end

rvc_alias :reload

def reload opts
  old_verbose = $VERBOSE
  $VERBOSE = nil unless opts[:verbose]

  RVC.reload_modules opts[:verbose]

  typenames = Set.new(VIM.loader.typenames.select { |x| VIM.const_defined? x })
  dirs = VIM.extension_dirs
  dirs.each do |path|
    Dir.open(path) do |dir|
      dir.each do |file|
        next unless file =~ /\.rb$/
        next unless typenames.member? $`
        file_path = File.join(dir, file)
        puts "loading #{$`} extensions from #{file_path}" if opts[:verbose]
        load file_path
      end
    end
  end

ensure
  $VERBOSE = old_verbose
end
