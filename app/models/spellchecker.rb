require 'set'

class Spellchecker

  
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)
  def initialize(text_file_name)
    #read file text_file_name
    #extract words from string (file contents) using method 'words' below.
    #put in dictionary with their frequency (calling train! method)
    #data = ''
    f = File.open(text_file_name, "r")  
    data = f.read
    wordarr = words(data)
    train!(wordarr)
  end

  def dictionary
    #getter for instance attribute
    @dictionary
  end
  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}. Default count should be 0 (argument of Hash constructor).
    @dictionary = Hash.new 0
    word_list.each { |word| @dictionary[word] += 1 }
  end

  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
    @dictionary[word]
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)

    #all strings obtained by deleting a letter (each letter)
    count = word.length
    i = count
    deletes = []

    while i != 0
      thechar = word[i-1]
      deletes.push(word.delete(thechar))
      i = i - 1
    end
 
    transposes = []
    #all strings obtained by switching two consecutive letters
    
    wordarr = word.split("")
    wordcopy = Array.new(wordarr)
    index = 0

    while index < wordarr.length
      copychar = wordcopy[index]
      wordcopy[index] = wordcopy[index+1]
      wordcopy[index+1] = copychar
      
      transposes.push(wordcopy.join)
      wordcopy = Array.new(wordarr)
      index += 1
    end
     
    inserts = []
    wordc = String.new(word)
    index = 0

    # all strings obtained by inserting letters (all possible letters in all possible positions)
    while index <= wordarr.length
      ALPHABET.each_char do |x|
        #replace each index with every letter of the alphabet
     	wordc.insert(index,x.to_s)
        inserts.push(wordc)
        wordc = String.new(word)
      end
      wordc = String.new(word)
      index += 1
    end
    
    replaces = []
    wordcopy = Array.new(wordarr)
    index = 0

    #all strings obtained by replacing letters (all possible letters in all possible positions)
    while index < wordarr.length
      ALPHABET.each_char do |x|
        #replace each index with every letter of the alphabet
     	wordcopy[index] = x
        replaces.push(wordcopy.join)
      end
      wordcopy = Array.new(wordarr)
      index += 1
    end
      

    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
    arr2 = []
    
    arr1 = edits1(word)
    arr1.each do |e|
   	 arr2.concat(edits1(e))
    end 

    return known(arr2)
  end

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
    result = words.find_all {|w| @dictionary.has_key?(w) }
    result.empty? ? nil : result
  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil
  def correct(word)
    words = []
    words = known([word])
    if words 
      if words.length == 1
        return words
      end
    end
    words = known(edits1(word))
    if !words
      words = known_edits2(word)
    end
    if words
      words_2 = []
      @dictionary.sort_by {|k,v| v}.reverse.each do |key, value|
        str = key.dup
	if words.include?(str) == true
	  if words_2.include?(str) == false
	    words_2.push(str)
          end
        end
      end
      return words_2
    end
    return nil
  end
    
  
end
