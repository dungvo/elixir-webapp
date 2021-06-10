defmodule Crawler.Scraper do
  @doc """
    Fetch a list of all of the product of Apple Flagship Store from Shopee.
  """

  def get_products(url, force \\ false) do
    content =
      case force do
        true  -> save_cache(url)
        false ->
          case PhoenixCache.Cache.get(url) do
            {:ok, content} -> content
            {:error, _}    -> save_cache(url)
          end
    end
    products = parse_products(content)
    stats_products(products)
  end

  def stats_products(products) do
    low_prices = Enum.map(products, &(&1.low_price))
    high_prices = Enum.map(products, &(&1.high_price))
    total = length(products)
    number_phone = length(Enum.filter(products, &(String.contains?(&1.name, "Phone") )))
    number_mac = length(Enum.filter(products, &(String.contains?(&1.name, "Mac") )))
    number_watch = length(Enum.filter(products, &(String.contains?(&1.name, "Watch") )))
    number_airpod = length(Enum.filter(products, &(String.contains?(&1.name, "AirPod") )))
    number_others = total - number_phone - number_mac - number_watch - number_airpod
    %Product.Stats{
      total: length(products),
      min_price: Enum.min(low_prices),
      max_price: Enum.max(high_prices),
      products: Enum.sort(products, &(&1.high_price > &2.high_price)),
      number_phone: number_phone,
      number_mac: number_mac,
      number_watch: number_watch,
      number_airpod: number_airpod,
      number_others: number_others
    }
  end

  def parse_products(content) do
    if content == nil do
      []
    else
      content
      |> Floki.find("script")
      |> Floki.find("[data-rh=true]")
      |> Enum.map(&(Floki.children(&1) |> Floki.text()))
      |> Enum.map(&parse_product(&1))
      |> Enum.filter(&(&1 != nil))
    end
  end

  def parse_product(data) do
    #IO.inspect(data)
    data_map = Jason.decode!(data)
    if data_map["@type"] != "Product" do
      nil
    else
      offers = data_map["offers"]
      price = Map.get(offers, "price", "0.0")
      %Product.Item{
        name: data_map["name"],
        image: data_map["image"],
        low_price: parse_price(Map.get(offers, "lowPrice", price)),
        high_price: parse_price(Map.get(offers, "highPrice", price)),
        url: data_map["url"]
      }
    end
  end

  defp parse_price(price_as_str) do
    case Float.parse(price_as_str) do
      :error      -> 0
      {number, _} -> round(number)
    end
  end

  defp save_cache(url) do
    case get_content_from_url(url) do
      {:ok, content} ->
        PhoenixCache.Cache.set(url, content)
        content
      _ -> nil
    end
  end

  defp get_content_from_url(url) do
    headers = []
    options = [recv_timeout: 10000]
    case HTTPoison.get(url, headers, options) do
      {:ok, response} ->
        case response.status_code do
          200 -> {:ok, response.body}
          _   -> :error
        end
      _ -> :error
    end
  end
end
