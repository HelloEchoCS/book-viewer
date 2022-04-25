require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @chapters = File.readlines("data/toc.txt")
  # @chapters = File.read("data/toc.txt").split("\n")
end

helpers do
  def in_paragraphs(str)
    id = 0
    str.split("\n\n").map do |para|
      id += 1
      "<p id=#{id}>#{para}</p>"
    end.join
  end

  def highlight_matches(para, matched_str)
    para.gsub(matched_str, "<strong>#{matched_str}</strong>")
  end

  def para_id(content)
    id = 1
    content.split("\n\n").each_with_object({}) do |para, hsh|
      hsh[id] = para
      id += 1
    end
  end

  def chapter_search(search_str)
    results = {}
    @chapters.each_with_index do |title, idx|
      content = File.read("data/chp#{idx + 1}.txt")
      results[title] = []
      paragraphs = para_id(content)
      paragraphs.each do |id, para|
        if para.include?(search_str)
          matched_data = { chapter_num: idx + 1,
                           paragraph: para,
                           paragraph_id: id
                         }
          results[title] << matched_data
        end
      end
    end
    results
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "Book Shelf"

  erb :home
  # This also works:
  # erb :home, :locals => {:title => "Book Shelf"}
end

get "/chapters/:number" do
  number = params[:number]

  redirect "/" unless (1..@chapters.size).cover? number.to_i

  @content = File.read("data/chp#{number}.txt")
  @title = @chapters[number.to_i - 1]

  erb :chapter
end

get "/search" do
  @search_str = params[:query]
  @results = @search_str ? chapter_search(@search_str) : []
  erb :search
end