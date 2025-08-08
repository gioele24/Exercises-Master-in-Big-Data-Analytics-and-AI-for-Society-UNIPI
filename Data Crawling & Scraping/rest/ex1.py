# Write a Python program to fetch and display detailed market data for specific cryptocurrencies.
# Your program should be able to access real-time data for Bitcoin (BTC), Ethereum (ETH),
# and Ripple (XRP) against USD and EUR.
#
# The data is available at REST endpoint:
# https://min-api.cryptocompare.com/documentation?key=Price&cat=multipleSymbolsFullPriceEndpoint

import requests

# This function takes the list of cryptos and currencies to retrieve data for, extract
# all requested data into a list of Python dictionaries and return it back to the caller.
def get_crypto_details(cryptos, currencies):
    # Base URL for the CryptoCompare API
    base_url = "https://min-api.cryptocompare.com/data/pricemultifull"

    # Construct the query string for cryptocurrencies and currencies
    fsyms = ','.join(cryptos)
    tsyms = ','.join(currencies)

    # Construct the full URL for the API call
    url = f"{base_url}?fsyms={fsyms}&tsyms={tsyms}"

    # Perform the API call
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        data = response.json()

        # List to collect cryptocurrency details
        crypto_details = []

        # Extract and collect details for each cryptocurrency and currency
        for crypto in cryptos:
            for currency in currencies:
                details = {
                    'crypto': crypto,
                    'currency': currency,
                    'market_cap': data['DISPLAY'][crypto][currency]['MKTCAP'],
                    'current_price': data['DISPLAY'][crypto][currency]['PRICE'],
                    'low_day': data['DISPLAY'][crypto][currency]['LOWDAY'],
                    'high_day': data['DISPLAY'][crypto][currency]['HIGHDAY'],
                    'volume_day': data['DISPLAY'][crypto][currency]['VOLUMEDAYTO']
                }
                crypto_details.append(details)

        return crypto_details
    else:
        print("API call error:", response.status_code)
        return []


# Example usage
cryptos = ['BTC', 'ETH', 'XRP']
currencies = ['USD', 'EUR']

crypto_details = get_crypto_details(cryptos, currencies)

for detail in crypto_details:
    print(detail)
