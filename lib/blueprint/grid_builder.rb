module Blueprint
  class GridBuilder
    attr_reader :column_width, :gutter_width, :output_path, :able_to_generate

    # ==== Options
    # * <tt>options</tt>
    #   * <tt>:column_width</tt> -- Width (in pixels) of current grid column
    #   * <tt>:gutter_width</tt> -- Width (in pixels) of current grid gutter
    #   * <tt>:output_path</tt> -- Output path of grid.png file
    def initialize(options={})
      @able_to_generate = Magick::Long_version rescue false
      return unless @able_to_generate
      @column_width    = options[:column_width] || Blueprint::COLUMN_WIDTH
      @gutter_width    = options[:gutter_width] || Blueprint::GUTTER_WIDTH
      @output_path     = options[:output_path]  || Blueprint::SOURCE_PATH
      @baseline_height = (options[:font_size] || Blueprint::FONT_SIZE) * 1.5
    end

    # generates (overwriting if necessary) grid.png image to be tiled in background
    def generate!
      total_width = self.column_width + self.gutter_width
      height = @baseline_height
      RVG::dpi = 100

      width_in_inches = (total_width.to_f/RVG::dpi).in
      height_in_inches = (height.to_f/RVG::dpi).in
      rvg = RVG.new(width_in_inches, height_in_inches).viewbox(0, 0, total_width, height) do |canvas|
        canvas.background_fill = "white"

      white      = ChunkyPNG::Color.from_hex("ffffff")
      background = ChunkyPNG::Color.from_hex("e8effb")
      line       = ChunkyPNG::Color.from_hex("e9e9e9")

      png = ChunkyPNG::Image.new(total_width, height, white)
      png.rect(0, 0, column_width - 1, height, background, background)
      png.rect(0, height - 1, total_width, height - 1, line, line)

      FileUtils.mkdir(self.output_path) unless File.exists?(self.output_path)
      png.save(File.join(self.output_path, "grid.png"))
    end
  end
end
