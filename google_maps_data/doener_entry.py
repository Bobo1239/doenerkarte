import pandas as pd
import webbrowser


if __name__ == "__main__":
    input_file_path = 'munich_doener_df.json'
    doener_df = pd.read_json(input_file_path, lines=True)

    for idx, place in doener_df.iterrows():

        place_id = place['place_id']
        maps_url = f"https://www.google.com/maps/place/?q=place_id:{place_id}"
        # Open the URL in the default web browser
        webbrowser.open(maps_url)
        print(f"{place['name']}, {place['address']}")
        price = input("Dönerpreis:")
        year = input("Jahr:")

        doener_df.at[idx, 'year'] = year
        doener_df.at[idx, 'price'] = price

    df_output_file_path = 'munich_doener_df_with_price.json'
    doener_df.to_json(df_output_file_path, orient='records', lines=True)
    