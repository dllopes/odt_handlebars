require "odt_handlebars/version"

module OdtHandlebars
  class Error < StandardError; end

  def self.replace(in_file,out_file, placeholders)
    OdtFill.new(in_file,out_file, placeholders).replace
  end
end
