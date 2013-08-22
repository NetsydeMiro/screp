module TextUtilities

  def titlize(title)
    title.strip.split(' ').map(&:capitalize).join(' ')
  end

  def filename_scrub(filename, 
                     unsafe_grep = /[^0-9A-Za-z]/, 
                     safe_string = '_')
    filename.gsub(unsafe_grep, safe_string)
  end


  def typo(text, corrections)
    if text.respond_to? :each 
      text.each do |t|
        typo_helper t, corrections
      end
    else
      typo_helper text, corrections
    end
  end

  private

  def typo_helper(text, corrections)
    corrections.each do |k,v|
      text.gsub!(k, v)
    end
  end
end
