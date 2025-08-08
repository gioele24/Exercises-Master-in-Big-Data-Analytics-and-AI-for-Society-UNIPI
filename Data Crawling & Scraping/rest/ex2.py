# The goal of this exercise is to develop a Python program that leverages the CryptoCompare API
# to fetch and analyze the social media presence and popularity of major cryptocurrencies. The
# students will focus on Bitcoin (BTC), Ethereum (ETH), and Ripple (XRP), exploring their social
# media statistics including Twitter followers, Reddit subscribers, and CryptoCompare followers.

import requests

def get_coin_ids(cryptos, API_KEY):
    # Replace 'YOUR_API_KEY' with your actual API key

    # Dictionary to store the coin_ids
    coin_ids = {}

    for c in cryptos:
        url = f"https://min-api.cryptocompare.com/data/all/coinlist?summary=true&fsym={c}"

        # Make the API call
        response = requests.get(url)
        data = response.json()
        coin_id = data['Data'][c.upper()]["Id"]
        symbol = data['Data'][c.upper()]['Symbol']
        coin_ids[symbol] = coin_id

    return coin_ids



def get_social_stats(coin_ids, API_KEY):
    base_url = "https://min-api.cryptocompare.com/data/social/coin/latest"
    social_stats = {}
    for crypto, coin_id in coin_ids.items():
        # Append the coin ID and API key to the base URL for the request
        url = base_url + f"?coinId={coin_id}&api_key={API_KEY}"
        response = requests.get(url)
        data = response.json()
        if 'Data' in data:
            # Extract social data if available
            social_data = data['Data']
            # Collect social stats, defaulting to 'N/A' if not available
            stats = {
                'Twitter': social_data.get('Twitter', {}).get('followers', 'N/A'),
                'Reddit': social_data.get('Reddit', {}).get('subscribers', 'N/A'),
                'CryptoCompare': social_data.get('CryptoCompare', {}).get('Followers', 'N/A'),
            }
            social_stats[crypto] = stats
    return social_stats

def main(cryptos, API_KEY):
    # Retrieve coin IDs for the given cryptocurrencies
    coin_ids = get_coin_ids(cryptos, API_KEY)
    # Retrieve social stats for the given coin IDs
    social_stats = get_social_stats(coin_ids, API_KEY)
    # Print the social stats for each cryptocurrency
    for crypto, stats in social_stats.items():
        print(f"Social Stats (followers or subscribers) for {crypto}:")
        for platform, value in stats.items():
            print(f"{platform}: {value}")
        print("-" * 20)


if __name__ == "__main__":
    cryptos = ['BTC', 'ETH', 'XRP']

    API_KEY = "???"  # Placeholder for the user's API key

    main(cryptos, API_KEY)
