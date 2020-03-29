# coding: utf-8
require 'nokogiri'
require 'handlebars'
require 'zip'
require_relative 'odt_cleaner'

module OdtHandlebars
  class OdtFill
    def initialize(infile,outfile,fill)
      @infile=infile
      @outfile=outfile
      @fill=fill
    end

    def replace
      unpack
    end

    def unpack
      File.open(@outfile,"w") do |outfile|
        Zip::OutputStream.write_buffer(outfile) do |outzip|
          Zip::File.open(@infile) do |inzip|
            inzip.entries.each do |e|
              next if e.file_type_is?(:directory)
              if e.name == "content.xml"
                content = e.get_input_stream.read
                output=replace(content,@fill)
                outzip.put_next_entry(e.name)
                outzip.write output
              else
                outzip.put_next_entry(e.name)
                outzip.write e.get_input_stream.read
              end
            end
          end
        end
      end
      outfile
    end

    FIELD_MATCHER=Regexp.new("{{.+?}}",Regexp::MULTILINE)
    def replace(raw_content,placeholders)
      content=OdtCleaner.clean(raw_content)
      puts content
      doc=Nokogiri.parse(content)
      rows=doc.xpath("//table:table-row/*[starts-with(.,'{{/each')]")
      rows.each do |row| row.parent.replace(row.to_str) end
      rows=doc.xpath("//table:table-row/*[starts-with(.,'{{#each')]")
      rows.each do |row| row.parent.replace(row.to_str) end
      fields=doc.xpath("//text:p/*")
      handlebars = Handlebars::Context.new
      template = handlebars.compile(doc.to_s)
      out=template.call(placeholders)
      out
    end
  end
end
