defmodule Crawler.ScraperTest do
  use ExUnit.Case
  doctest Crawler.Scraper

  test "Stats Products" do
    {:ok, content} = File.read("test/data.html")
    products = Crawler.Scraper.parse_products(content)
    assert length(products) == 26
    stats = Crawler.Scraper.stats_products(products)
    assert stats.total == 26
    assert stats.max_price == 35790000
    assert stats.min_price == 590000

    assert stats.number_phone == 7
    assert stats.number_mac == 7
    assert stats.number_watch == 5
    assert stats.number_airpod == 3
    assert stats.number_others == 4
  end

  test "Parse Product" do
    sample = "{\"@context\":\"http://schema.org\",\"@type\":\"Product\",\"name\":\"Apple MacBook Pro (2020) M1 Chip, 13 inch, 8GB, 512GB SSD\",\"description\":\"\",\"url\":\"https://shopee.vn/Apple-MacBook-Pro-(2020)-M1-Chip-13-inch-8GB-512GB-SSD-i.88201679.6773948914\",\"productID\":\"6773948914\",\"image\":\"https://cf.shopee.vn/file/42c51761d53b623a5bc6fcf8772d9e94\",\"brand\":\"Apple\",\"offers\":{\"@type\":\"Offer\",\"price\":\"35790000.00\",\"priceCurrency\":\"VND\",\"availability\":\"http://schema.org/InStock\"}}"
    expect = %Product.Item{
      high_price: 35790000,
      image: "https://cf.shopee.vn/file/42c51761d53b623a5bc6fcf8772d9e94",
      low_price: 35790000,
      name: "Apple MacBook Pro (2020) M1 Chip, 13 inch, 8GB, 512GB SSD",
      url: "https://shopee.vn/Apple-MacBook-Pro-(2020)-M1-Chip-13-inch-8GB-512GB-SSD-i.88201679.6773948914"
    }
    actual = Crawler.Scraper.parse_product(sample)
    assert actual == expect
  end

  test "Parse Product with low and high price" do
    sample = "{\"@context\":\"http://schema.org\",\"@type\":\"Product\",\"name\":\"Apple Magic Mouse 2 Multi-Touch\",\"description\":\"\",\"url\":\"https://shopee.vn/Apple-Magic-Mouse-2-Multi-Touch-i.88201679.3355877166\",\"productID\":\"3355877166\",\"image\":\"https://cf.shopee.vn/file/65839ad53060d658482f23c57197ebe2\",\"brand\":\"Apple\",\"offers\":{\"@type\":\"AggregateOffer\",\"lowPrice\":\"2090000.00\",\"highPrice\":\"2990000.00\",\"priceCurrency\":\"VND\",\"availability\":\"http://schema.org/InStock\"},\"aggregateRating\":{\"@type\":\"AggregateRating\",\"bestRating\":5,\"worstRating\":1,\"ratingCount\":\"40\",\"ratingValue\":\"4.90\"}}"
    expect = %Product.Item{
      high_price: 2990000,
      image: "https://cf.shopee.vn/file/65839ad53060d658482f23c57197ebe2",
      low_price: 2090000,
      name: "Apple Magic Mouse 2 Multi-Touch",
      url: "https://shopee.vn/Apple-Magic-Mouse-2-Multi-Touch-i.88201679.3355877166"
    }
    actual = Crawler.Scraper.parse_product(sample)
    assert actual == expect
  end
end
