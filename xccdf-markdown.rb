#!/usr/bin/env ruby
##
# :markup: markdown
#
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
