class Guesser
  class TvShow

    # More formats available at https://github.com/midgetspy/Sick-Beard/blob/development/sickbeard/name_parser/regexes.py
    FORMATS = {
      standard_repeat: /([\w\-\.\_\(\) !]*)S(\d+)(?:\D*)E(\d+)(?:.*)S(\d+)(?:\D*)E(\d+)/i,
      standard: /([\w\-\.\_\(\) !]*)S(\d+)(?:\D*)E(\d+)/i,
      fov_repeat: /([\w\-\.\(\) !]*)\D+?(\d+)(?:[x._])(\d+)/i
    }.freeze

    def self.guess_from_filepath(filepath)
      filename = Guesser.filename_without_extension(filepath)
      filename = Guesser.strip_scene_stuff(filename)
      filefolder = Guesser.containing_folder(filepath)

      results_from_filename = guess(filename).delete_if {|k,v| v.blank? }
      results_from_foldername = guess(filefolder).delete_if {|k,v| v.blank? }

      results = results_from_foldername.merge(results_from_filename)

      results[:title] = Guesser.pretty_title(filename) if results[:title].blank?
      results[:quality] = Guesser.guess_quality(filepath)

      results
    end

    def self.guess_from_string(from)
      results = guess(from).delete_if {|k,v| v.blank? }
      results[:title] = Guesser.pretty_title(from) if results[:title].blank?

      results
    end

    private
    def self.guess(from)
      results = {}

      TvShow::FORMATS.each do |name, regex|
        matches = regex.match(from)
        if matches.present? && matches.length == 4
          results = {
            title: Guesser.pretty_title(matches[1]),
            season: matches[2].to_i,
            episode: matches[3].to_i,
            quality: Guesser.guess_quality(from)
          }
          break
        end
        if matches.present? && matches.length == 6
          results = {
            title: Guesser.pretty_title(matches[1]),
            season: matches[2].to_i,
            episode: matches[3].to_i,
            season2: matches[4].to_i,
            episode2: matches[5].to_i,
            quality: Guesser.guess_quality(from)
          }
          break
        end
      end

      results[:quality] = Guesser.guess_quality(from)

      results
    end

  end

  class Movie

    FORMATS = {
      name_and_year: %r{
        ([\w\-\.\_\s]*)
        [\(\ \_\.\[]{1}([\d]{4})[\)\ \_\.\[]?
        }xi
    }.freeze

    def self.guess_from_filepath(filepath)
      quality = Guesser.guess_quality(filepath)
      filename = Guesser.filename_without_extension(filepath)
      filename = Guesser.strip_scene_stuff(filename)
      filefolder = Guesser.containing_folder(filepath)

      results_from_filename = guess(filename).delete_if {|k,v| v.blank? }
      results_from_foldername = guess(filefolder).delete_if {|k,v| v.blank? }

      results = results_from_foldername.merge(results_from_filename)

      results[:title] = Guesser.pretty_title(filename) if results[:title].blank?
      results[:quality] = Guesser.guess_quality(filepath)

      results
    end

    private
    def self.guess(from)
      results = {}

      Movie::FORMATS.each do |name, regex|
        matches = regex.match(from)
        if matches.present?
          results = {
            title: Guesser.pretty_title(matches[1]),
            year: matches[2].try(:to_i)
          }
          break
        end
      end

      results
    end

  end

  def self.containing_folder(filepath)
    filepath.split("/")[-2]
  end

  def self.guess_quality(from)
    matches = Video::QUALITIES.match(from)
    if matches.present?
      quality = matches[0]
    else
      quality = nil
    end
    quality
  end

  def self.filename_without_extension(filename)
    File.basename(filename, File.extname(filename))
  end

  def self.strip_scene_stuff(str)
    str.gsub(/(x264|hdtv|x264-2HD|-LOL)/i, '')
  end

  def self.pretty_title(str)
    str.gsub(/[\.\_\-]/, ' ').titleize.squish.strip
  end

end
