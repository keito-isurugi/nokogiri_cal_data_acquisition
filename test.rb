require 'nokogiri'
require 'open-uri'
require 'csv'
require 'byebug'
 
url_base = "https://news.yahoo.co.jp/"

def get_categories(url)
  html = open(url)
  doc = Nokogiri::HTML.parse(html)
  categories = doc.css(".yjnHeader_sub_cat li a")
  categories.map do |category|
    cat_name = category.text
    cat = category[:href]
  end
end

@cat_list = get_categories(url_base)
@infos = []


@cat_list.each do |cat|
  url = "#{url_base + cat}"
  html = open(url)
  doc = Nokogiri::HTML.parse(html)
  titles = doc.css(".sc-ksYbfQ a")
  i = 1
  titles.each do |title|
    @infos << [i,title.text]
    i += 1
  end
end

CSV.open("result.csv", "w") do |csv|
  csv << ["No", "食品名", "量(g)", "カロリー(kcal) ", "タンパク質(g)", "脂質(g)", "炭水化物(g)"]
  @infos.each do |info|
    csv << info
    puts "-------------------------------"
    puts info
  end
end