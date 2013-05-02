require 'net/http'
require 'uri'

namespace :maintain do

  desc "Check online retailer links"
  task :buynow_links => :environment do
    OnlineRetailerLink.to_be_checked.limit(30).each { |link|
      test_and_update(link)
    }
  end
  
  desc "Check external links for product reviews"
  task :product_review_links => :environment do
    ProductReview.to_be_checked.limit(30).each { |review|
      test_and_update(review)
    }
  end
  
  def test_and_update(item)
    begin
      new_status = link_test(item.url)
    rescue
      new_status = 500 # something bad happened with our link checker, flag it and move on
    end
    item.update_attributes(:link_checked_at => Time.now, :link_status => new_status)  
    sleep(15) # Don't crash others' sites.  
  end
  
  def link_test(url)
    uri = URI.parse(url)
    # response = nil
    # Net::HTTP.start(uri.host, uri.port) { |http|
    #   response = http.head(uri.path.size > 0 ? uri.path : "/")
    # }  

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Harman link verifier. Contact adam.anderson@harman.com"
    response = http.request(request)

    response.code
  end

end