# coding: utf-8

require 'strscan'

module OdtHandlebars
  class OdtCleaner
    def self.clean(content)
      new(content).clean
    end

    def initialize(content)
      @content=content
    end

    def clean
      out=""
      scanstart(StringScanner.new(@content),out)
    end

    private

    def scanstart(scanner,out)
      curlstart=0
      until scanner.eos?
        if res=scanner.scan(/<[^>]+>/)
#          puts "match: #{res}"
          out << res
        elsif res=scanner.scan(/[^{<]+/)
#          puts "match: #{res}"
          curlstart = 0
          out << res
        elsif res=scanner.scan(/{/)
#          puts "match: #{res}"
          curlstart += 1
          out << "{" # found one
          if curlstart == 2
 #           puts "looking for end"
            scanend(scanner,out)
            curlstart=0
          end
        end
      end
      out
    end

    def scanend(scanner,out)
      curlend=0
      until curlend == 2
        if res=scanner.scan(/<[^>]+>/)
#          puts "ignored: #{res}"
        #out << res
        elsif res=scanner.scan(/[^}<]+/)
#          puts "match: #{res}"
          out << res.gsub(/\n/,'')
        elsif res=scanner.scan(/}/)
#          puts "match: #{res}"
          out << "}"
          curlend += 1
        else
          warn("failed to scan handlebars end")
#          puts "else case"
        end
      end
#      puts "found end"
    end
  end
end



#  content=
#    '
#<text:section text:style-name="Sect1" text:name="Bereich1">
#        <text:p text:style-name="P12">Peter Schrammel; Langerhansstr 3; 80999 München</text:p>
#        <text:p text:style-name="Standard">
#          <text:span text:style-name="T8">{{</text:span>
#          <text:span text:style-name="T9">a</text:span>
#          <text:span text:style-name="T10">ddress.</text:span>
#          <text:span text:style-name="T12">line</text:span>
#          <text:span text:style-name="T13">1</text:span>
#          <text:span text:style-name="T11">}}</text:span>
#        </text:p>
#        <text:p text:style-name="P4">{{a<text:span text:style-name="T2">d</text:span>dress.<text:span text:style-name="T2">line</text:span>2}}</text:p>
#        <text:p text:style-name="P5">{{ad<text:span text:style-name="T2">d</text:span>ress.<text:span text:style-name="T2">line</text:span>3}}</text:p>
#        <text:p text:style-name="P19"/>
#        <text:p text:style-name="P13"/>
#        <text:p text:style-name="P7"/>
#      </text:section>
#
#'
end
