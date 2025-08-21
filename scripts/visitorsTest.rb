require "./scripts/support"
require "fileutils"

class MakeJavaVisitorTest
  attr_accessor :source, :pkg, :imports, :name, :rule, :b

  def initialize
    @source = []
    @imports = []
  end

  def build
    if pkg
      source << "package #{pkg};"
    end
    source << ""
    for i in imports
      source << "import #{i};"
    end
    low_name = name.downcase
    source << ""
    source << "public class #{name}Test {"
    source << ""
    source << "    @Test"
    source << "    void happy() {"
    source << "        for (int i = 0; i < 0x7F; i++) {"
    source << "            ByteStream bs = ByteStream.raw(new byte[]{(byte) i});"
    source << "            #{name} v = new #{name}(new Tokenizer(bs));"
    source << "            if (i == #{b}) assertTrue(v.allowed());"
    source << "            if (i != #{b}) assertTrue(v.denied());"
    source << "        }"
    source << "    }"
    source << "}"
  end

  def pretty_print
    build
    source.each do |line|
      puts line
    end
  end
end

origin = "org.x96.sys.foundation.cs.lexer.visitor.entry.terminals"
path = "./src/test/" + origin.gsub(".", "/")
FileUtils.mkdir_p(path) unless Dir.exist?(path)

for i in kinds.length.times
  pkg = origin + ".c#{i}"
  path = "./src/test/#{pkg.gsub(".", "/")}/"

  Dir.mkdir(path) unless Dir.exist?(path)

  kinds[i.to_s].each_with_index do |k, j|
    n = cml(k)
    m = MakeJavaVisitorTest.new
    m.pkg = pkg
    m.imports << "org.x96.sys.foundation.io.ByteStream"
    m.imports << "org.x96.sys.foundation.cs.lexer.tokenizer.Tokenizer"
    m.imports << "org.x96.sys.foundation.cs.lexer.visitor.Visitor"
    m.imports << "org.x96.sys.foundation.cs.lexer.token.Kind"
    m.imports << "static org.junit.jupiter.api.Assertions.*"
    m.imports << "org.junit.jupiter.api.Test"
    m.name = n
    m.b = "0x#{i.to_s(16)}#{j.to_s(16)}"
    m.build
    File.open("#{path}#{n}Test.java", "w") do |file|
      file.puts m.source
    end
  end
end
