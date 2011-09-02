##
# Parse a RD format file.  The parsed RDoc::Markup::Document is attached as a
# file comment.

class RDoc::Parser::RD < RDoc::Parser

  include RDoc::Parser::Text

  parse_files_matching(/\.rd(?:\.[^.]+)?$/)

  def scan
    comment = RDoc::Comment.new @content, @top_level
    comment.format = RDoc::RD

    @top_level.comment = comment
  end

end

