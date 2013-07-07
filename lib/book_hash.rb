module BookHash
  class Book
    attr_accessor :author, :published

    attr_reader :hash, :text
    def initialize(opts = {})
      opts = {author: "", published: 0000, text: ""}.merge(opts)
      puts opts
      self.text = opts[:text]
      @author = opts[:author]
      @published = opts[:published]
      generate_hash
    end
    def text=(text)
      @sentences = nil
      @character_count = text.split(//).count.to_f
      @text = text
      generate_hash
    end
    def similarity_to(another_book)
      (levenshtein(@hash, another_book.hash) / @character_count) * 100
    end
    private

    def generate_hash
      @sentences ||= @text.split('.').map(&:strip)
      @sentences.delete_if{|s| s.nil? || s.empty? || s == " "}
      if @hash.nil?
        @hash = ""
        letter_counts = {}
        # roll through the entire body of the text and build the hash
        @sentences.each do |s|
          words = s.split(' ')
          words.delete_if{|word| word.nil? || word.empty? || word == " "}.compact!
          words_sum = 0

          words.each do |word|
            w = word.split(//)
            words_sum += w.count
            w.each do |l|
              letter_counts[l] ||= 0
              letter_counts[l] += 1
            end
          end
          average_word_length = if words.count == 0
            0
          else
            words_sum / words.count
          end

          average = shorten_to_single average_word_length

          best_letter = ''
          highest_count = 0

          # selecting the letter to use for this string
          letter_counts.each do |letter, count|
            next if ['a','e','i','o','u'].include? letter
            best_letter, highest_count = letter, count if count > highest_count
          end

          @hash << "#{best_letter.downcase}#{average}#{shorten_to_single words.count}"
        end
      end
      true
    end
    def sentences
      @sentences
    end
    def sentences=(sentences)
      @hash = nil
      @sentences = sentences
    end
    def shorten_to_single(i = 0)
      i = i.abs
      return i if i < 10
      if i > 10
        i = "#{i}".split(//).inject(0){|sum,value| sum + value.to_i}
      end
      i
    end

    def levenshtein(hash, other, ins=2, del=2, sub=1)
      # ins, del, sub are weighted costs
      return nil if hash.nil?
      return nil if other.nil?
      dm = []        # distance matrix

      # Initialize first row values
      dm[0] = (0..hash.length).collect { |i| i * ins }
      fill = [0] * (hash.length - 1)

      # Initialize first column values
      for i in 1..other.length
        dm[i] = [i * del, fill.flatten]
      end

      # populate matrix
      for i in 1..other.length
        for j in 1..hash.length
      # critical comparison
          dm[i][j] = [
               dm[i-1][j-1] +
                 (hash[j-1] == other[i-1] ? 0 : sub),
                   dm[i][j-1] + ins,
               dm[i-1][j] + del
         ].min
        end
      end

      # The last value in matrix is the
      # Levenshtein distance between the strings
      dm[other.length][hash.length]
    end
  end
end
