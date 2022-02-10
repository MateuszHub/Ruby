

def httpGet(url)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:95.0) Gecko/20100101 Firefox/95.0"
    request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
    request["Accept-Language"] = "pl,en-US;q=0.7,en;q=0.3"

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end
    return response
end
    
    
def getDetailedDesc(url)
    result = ""
    resp = httpGet(url).body
    ht = Nokogiri::HTML5(resp)
    ht.css('#feature-bullets ul li:not(.aok-hidden) span.a-list-item').each do |span|
        result += span.text + "."
    end
    return result
end
    
    
def getItemsFromPage(keywords, page = 1)
    response = httpGet("https://www.amazon.de/s?rh=n%3A427957031&fs=true&language=pl&page=#{page}")
    doc = Nokogiri::HTML5(response.body)
    result = []
    doc.css('.s-main-slot > .s-result-item .s-card-container').each do |part|
        html = Nokogiri::HTML5.fragment(part)
        title = html.css('h2>a>span').first.text
        matches = true 
        keywords.each do |kw|
            if title !~ /#{kw}/i
                matches = false
            end
        end
        if matches == true 
            link =  "https://www.amazon.de" + html.css('h2>a').first['href']
            price = html.css('.a-price-whole').first
            if price.nil? 
                price = "-1"
            else
                price = price.text
                price = price.gsub(/[^0-9.,]/,'')
                price = price.gsub(",", ".")
            end
            details = getDetailedDesc(link) 
            result.append({:title => title, :price => price, :link => link, :desc => details})   
        end
    end
    return result
end