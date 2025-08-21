require "./scripts/support"
require "fileutils"

class MakeJavaVisitor
  attr_accessor :source, :pkg, :imports, :name, :rule

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
    source << ""
    source << "public class #{name} extends Visitor {"
    source << "    public #{name}(Tokenizer tokenizer) {"
    source << "        super(tokenizer);"
    source << "    }"
    source << ""
    source << "    @Override"
    source << "    public boolean allowed() {"
    source << "        return #{rule};"
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
path = "./src/main/" + origin.gsub(".", "/")
FileUtils.mkdir_p(path) unless Dir.exist?(path)

m = MakeJavaVisitor.new
m.pkg = origin
m.imports << "org.x96.sys.foundation.cs.lexer.tokenizer.Tokenizer"
m.imports << "org.x96.sys.foundation.cs.lexer.visitor.Visitor"
m.name = "Terminal"
m.rule = "true"
m.build
File.open("#{path}/Terminal.java", "w") do |file|
  file.puts m.source
end

for i in kinds.length.times
  pkg = origin + ".c#{i}"
  path = "./src/main/#{pkg.gsub(".", "/")}/"

  Dir.mkdir(path) unless Dir.exist?(path)

  kinds[i.to_s].each_with_index do |k, j|
    n = cml(k)
    m = MakeJavaVisitor.new
    m.pkg = pkg
    m.imports << "org.x96.sys.foundation.cs.lexer.tokenizer.Tokenizer"
    m.imports << "org.x96.sys.foundation.cs.lexer.visitor.Visitor"
    m.imports << "org.x96.sys.foundation.cs.lexer.token.Kind"
    m.name = n
    m.rule = "Kind.is#{n}(look())"
    m.build
    File.open("#{path}#{n}.java", "w") do |file|
      file.puts m.source
    end
  end
end
