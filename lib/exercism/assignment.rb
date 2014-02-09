class Assignment

  attr_reader :path, :language, :slug, :data_dir, :code, :filename
  def initialize(language, slug, path, code=nil, filename=nil)
    @language = language
    @slug = slug
    @data_dir = path
    @path = File.join(path, language, slug)
    @code = code
    @filename = filename
  end

  def filenames
    Dir.glob("#{path}/**/**").reject {|f| f[/example/i] || File.directory?(f)}.map {|f| f.gsub("#{path}/", '')}
  end

  def exercise
    @exercise ||= Exercise.new(language, slug)
  end

  def tests
    @tests ||= read(test_file)
  end

  def test_file
    filenames.find {|f| f[/test/i] || f[/\.t$/]}
  end

  def files
    @files ||= Hash[construct_files]
  end

  def readme
    Readme.new(slug, data_dir, SetupHelp.new(language, data_dir)).text
  end

  private

  def read(file)
    File.read path_to(file)
  end

  def path_to(file)
    File.join(path, file)
  end

  def construct_files
    files_data = filenames.reduce({}) do |files, name|
      files.merge(name => read(name))
    end.merge("README.md" => readme)
    files_data.merge!(filename => code) if code && filename
    files_data.sort_by {|name, text| name.downcase}
  end
end

