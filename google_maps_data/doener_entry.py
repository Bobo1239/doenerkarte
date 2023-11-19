import pandas as pd
import webbrowser
import os


if __name__ == "__main__":
    input_file_path = 'munich_doener_df.json'
    doener_df = pd.read_json(input_file_path, lines=True)

    
    df_price_file_path = 'munich_doener_df_with_price.json'
    if not os.path.exists(df_price_file_path):
        doener_df.to_json(df_price_file_path, orient='records', lines=True)

    num_doeners = len(doener_df)

    for idx, place in doener_df.iterrows():

        doener_df = pd.read_json(df_price_file_path, lines=True)

        place_id = place['place_id']
        maps_url = f"https://www.google.com/maps/place/?q=place_id:{place_id}"
        # Open the URL in the default web browser
        webbrowser.open(maps_url)
        print(f"Döner {idx} out of {num_doeners}: {place['name']}, {place['address']}")
        price = input("Dönerpreis / €:")
        year = input("Jahr:")

        doener_df.at[idx, 'year'] = year
        doener_df.at[idx, 'price'] = price

        doener_df.to_json(df_price_file_path, orient='records', lines=True)
    