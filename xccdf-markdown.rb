#!/usr/bin/env ruby
##
# :markup: markdown
#
# # xccdf-markdown.rb
#
# A simple and dirty XCCDF to Markdown converter.
#  
# Copyright (c) 2014, Christopher J. Pilkington
# All rights reserved.
#  
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
#  
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
#  
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#   

require 'rubygems'
require 'xmlsimple'

# stolen from facets, thanks to dharple for the suggestion
def word_wrap(text, col_width=80)
    text.gsub!( /(\S{#{col_width}})(?=\S)/, '\1 ' )
    text.gsub!( /(.{1,#{col_width}})(?:\s+|$)/, "\\1\n" )
    text
end

xml = ARGF.read
data = XmlSimple.xml_in(xml, { 'KeyAttr' => 'id' , 'GroupTags' => { 'Group' => 'Rule' }})
# data = XmlSimple.xml_in('rhel6.xml', { 'KeyAttr' => 'id' , 'GroupTags' => { 'Group' => 'Rule' }})

print "# #{data['title'][0]}\n\n"

descr = word_wrap data['description'][0]
print "#{descr}\n\n"

data['Group'].each do |ok, ov|
    ov['Rule'].each do |ik, iv|
        print "## #{iv['title'][0]}\n"
        print "Severity: _#{iv['severity']}_\n\n"

        desc = iv['description'][0].gsub /<VulnDiscussion>(.*)<\/VulnDiscussion>.*/m, '\1'
        desc = word_wrap desc
        desc = desc.chomp.gsub /\n/m, "\n> "
        print "### Description\n> #{desc}\n\n"

        check = word_wrap iv['check'][0]['check-content'][0]
        check = check.chomp.gsub /\n/m, "\n    "
        print "### Check\n    #{check}\n\n"

        fix = word_wrap iv['fixtext'][0]['content']
        fix = fix.chomp.gsub /\n/m, "\n    "
        print "### Fix\n    #{fix}\n\n"

        print "\n\n"
    end
end
