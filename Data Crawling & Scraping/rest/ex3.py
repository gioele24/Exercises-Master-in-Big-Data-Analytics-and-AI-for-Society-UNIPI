import requests
import pandas as pd
from datetime import datetime, timedelta

from trio import current_effective_deadline

# --- CONFIGURATION ---
CITY = "Pisa"
LATITUDE = 43.7167
LONGITUDE = 10.4000
YEARS_BACK = 30  # How many years to look back

# Open-Meteo API endpoints
CURRENT_WEATHER_URL = "https://api.open-meteo.com/v1/forecast"
HISTORICAL_WEATHER_URL = "https://archive-api.open-meteo.com/v1/archive"


# --- FUNCTION TO FETCH CURRENT WEATHER ---
def get_current_weather():
    """
    Fetch current weather conditions for today.
    """
    params = {
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "current_weather": True,
        "timezone": "Europe/Rome"
    }

    response = requests.get(CURRENT_WEATHER_URL, params=params)
    if response.status_code == 200:

        return response.json()["current_weather"]
    else:
        print("Error fetching current weather:", response.status_code)
        return None


# --- FUNCTION TO FETCH HISTORICAL WEATHER ---
def get_historical_weather(year):
    """
    Fetch historical weather data for the given year on today's date.
    """
    today = datetime.today()
    past_date = today.replace(year=year).strftime("%Y-%m-%d")

    params = {
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "start_date": past_date,
        "end_date": past_date,
        "daily": ["temperature_2m_max", "temperature_2m_min", "precipitation_sum", "windspeed_10m_max"],
        "timezone": "Europe/Rome"
    }

    response = requests.get(HISTORICAL_WEATHER_URL, params=params)
    if response.status_code == 200:
        return response.json()["daily"]
    else:
        print(f"Error fetching historical weather for {year}: {response.status_code}")
        return None


# --- FUNCTION TO PROCESS HISTORICAL DATA ---
def process_historical_data():
    """
    Retrieve and process historical weather data for the last 30 years.
    """
    historical_data = []

    for year in range(datetime.today().year - YEARS_BACK, datetime.today().year):
        data = get_historical_weather(year)
        if data:
            historical_data.append({
                "year": year,
                "temp_max": data["temperature_2m_max"][0],
                "temp_min": data["temperature_2m_min"][0],
                "precipitation": data["precipitation_sum"][0],
                "windspeed": data["windspeed_10m_max"][0],
            })

    return pd.DataFrame(historical_data)


# --- FUNCTION TO COMPARE DATA ---
def compare_weather(current, historical_df):
    """
    Compare today's weather with the historical averages over the past 30 years.
    """
    summary = {
        "temp_max": historical_df["temp_max"].mean(),
        "temp_min": historical_df["temp_min"].mean(),
        "precipitation": historical_df["precipitation"].mean(),
        "windspeed": historical_df["windspeed"].mean(),
    }

    print("\n **Weather Comparison for Today vs Past 30 Years** \n")
    print(f"City: {CITY} | Date: {datetime.today().strftime('%Y-%m-%d')}\n")

    print(f"Max Temperature: {current['temperature']}°C (vs {summary['temp_max']:.1f}°C avg)")
    print(f"Min Temperature: {current['temperature']}°C (vs {summary['temp_min']:.1f}°C avg)")
    print(f"Wind Speed: {current['windspeed']} km/h (vs {summary['windspeed']:.1f} km/h avg)")
    print(f"Precipitation:  {summary['precipitation']:.1f} mm avg")


# --- FUNCTION TO SAVE DATA ---
def save_to_csv(df, filename):
    """
    Save historical weather data to a CSV file.
    """
    df.to_csv(filename, index=False)
    print(f"Data saved to {filename}")


# --- MAIN FUNCTION ---
def main():
    print(f"Fetching today's weather for {CITY}...")
    current_weather = get_current_weather()

    if not current_weather:
        print("Error retrieving current weather. Exiting.")
        return

    print(f"Fetching historical weather for the past {YEARS_BACK} years...")
    historical_df = process_historical_data()

    if historical_df.empty:
        print("No historical data found. Exiting.")
        return

    compare_weather(current_weather, historical_df)
    save_to_csv(historical_df, "historical_weather_pisa.csv")


if __name__ == "__main__":
    main()