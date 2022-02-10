require 'net/http'
require 'uri'
require 'nokogiri'
require 'sequel'
require './lib.rb'

DB = Sequel.sqlite # memory database, requires sqlite3
    
DB.create_table :items do
    primary_key :id
    String :title
    Float :price
    String :link
    String :desc
end
items = DB[:items]

puts "Wprowadz slowa kluczowe oddzielone spacja:"
keys = gets
keys = keys.chomp
keywords = keys.split(" ")

puts "Zaczynamy przeszukiwanie"

page = 1
while true
    result = getItemsFromPage(keywords, page)
    result.each do |item|
        items.insert(:title => item[:title], :price => item[:price], :link => item[:link], :desc => item[:desc])   
    end

    puts "Łącznie znaleziono #{items.count} produktów spełniajacych kryteria"
    puts "Czy chcesz kontynuowac szuaknie [t/n]?"
    a = gets.chomp
    if a=="n"
        break
    end
    page += 1
end

puts "Przedmioty posortowane wg ceny:"
items.order(:price).each do |item|
    puts item
end

