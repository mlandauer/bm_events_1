require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

page = agent.get("http://www.bluemts.com.au/whatson/?sMonth=5&sYear=2014")
event_urls = page.search(".eventlist").map {|e| e.at("a")["href"]}
#event_urls = ["http://www.bluemts.com.au/whatson/?evID=8662"]

event_urls.each do |event_url|
  puts "Reading #{event_url}..."
  page = agent.get(event_url)
  e = page.at(".event")
  record = {}
  record["source_url"] = event_url
  record["name"] = e.at("h2").inner_text
  if e.at(".date .start")
    record["start_date"] = e.at(".date .start").inner_text.split(":")[1].strip
  end
  if e.at(".date .end")
    record["end_date"] = e.at(".date .end").inner_text.split(":")[1].strip
  end
  if e.at(".date .price")
    record["price"] = e.at(".date .price").inner_text.split(":")[1].strip
  end
  record["date"] = e.at(".date").inner_text.squeeze.strip
  record["description"] = e.at(".desc").inner_text.strip
  record["image_url"] = (page.uri + e.at(".thumb a")["href"]).to_s if e.at(".thumb")
  record["location"] = e.at(".location").inner_text
  record["contact"] = e.at(".contact").inner_text
  record["email"] = e.at(".email a")["href"].split(":")[1] if e.at(".email a")

  p record
  ScraperWiki.save_sqlite(["source_url"], record)
end
