require 'nokogiri'
require 'open-uri'
require 'csv'
require 'byebug'

# url_baseにサイトURLを代入
url_base = "https://calorie.slism.jp/"

# 関数get_categories1を定義
def get_categories1(url)
  # 指定のURLを開く
  html = open(url)
  doc = Nokogiri::HTML.parse(html)
  # categories1に全ての大要素(穀物、野菜など)のリンクを取得 
  categories1 = doc.css(".menuContents ul li ul li a")
  # 大要素(穀物、野菜など)のaタグのテキストとリンクを取得しそれぞれの変数に代入
  categories1.map do |category1|
    cat_name1 = category1.text #大要素名前(穀物、野菜)
    cat1 = category1[:href] #大要素リンク
  end
end

# @cat_list1に関数を代入(大要素のリンクが入る)
@cat_list1 = get_categories1(url_base)


urls2 = []
@url_pages = [] 
@datas = []

# 取得した大要素のリンク分処理を繰り返す
@cat_list1.each do |cat|
  # 大要素のリンクを作成、代入しアクセス
  url1 = "#{url_base + cat}"
  html = open(url1)
  doc = Nokogiri::HTML.parse(html)
  # 大要素リンク内のページリンクを取得
  page_a = doc.css("#pager a")
  # ページリンクのURLを生成し配列に追加
  page_a.map do |page|
    page_name = page[:href]
    @url_pages << "#{url_base + page_name}"
  end
end

# ページリンク分処理を繰り返す
@url_pages.uniq.each do |page|
  # 大要素のページリンクアクセス先の中要素(ごはん、きびなど)のaタグ取得
  html = open(page)
  doc = Nokogiri::HTML.parse(html)
  categories2 = doc.css(".ccdsCatList li a")
  # 中要素のaタグ分処理を繰り返す
  categories2.map do |category2|
    cat_name2 = category2.text #中要素(ごはん、きびなど)
    cat2 = category2[:href] #中要素リンク
    # 中要素のリンクを生成
    urls2 << "#{url_base + cat2}"
  end
end

# csv項目用のNoを用意
i = 1

# 中要素(ごはん、きびなど)のリンク分処理を繰り返す
urls2.each do |url2|
  # 中要素(ごはん、きびなど)のリンク先にアクセス
  html = open(url2)
  doc = Nokogiri::HTML.parse(html)
  # csv項目用のタンパク質、脂質、炭水化物を用意
  amount = doc.css("#serving_content").text
  calorie = doc.at_css(".singlelistKcal").text
  food_name = doc.css("#itemImg h2").text
  protein = doc.css("#protein_content").text
  fat = doc.css("#fat_content").text
  carb = doc.css("#carb_content").text
  # 配列datasに名前やタンパク質等のデータを追加
  @datas << [i, food_name, amount, calorie, protein, fat, carb]
  i += 1
end

# CSVファイルにデータを追加し保存
CSV.open("cal_data.csv", "w") do |csv|
  csv << ["No", "食品名", "量(g)", "カロリー(kcal) ", "タンパク質(g)", "脂質(g)", "炭水化物(g)"]
  @datas.each do |data|
    csv << data
    puts "-------------------------------"
    puts data
  end
end
