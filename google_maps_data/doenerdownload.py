import requests
import pandas as pd
import numpy as np
import time
import json

def m_to_lon(m, reference_lat):
    # Earth radius at the equator (mean radius)
    earth_radius_m = 6371000

    # Calculate the circumference of the Earth at the given latitude
    earth_circumference_m_at_reference_latitude = 2 * np.pi * earth_radius_m * np.cos(reference_lat*np.pi/180)

    lon = (m / earth_circumference_m_at_reference_latitude)*360
    return lon

def m_to_lat(m):
    # lat constant at every point
    lat = m / 111177
    return lat

def create_lat_lon_grid(center, radius, width, height):
    """_summary_

    Args:
        center (list(float)): center of box [lat, lon]
        radius (int): radius of google search circles in m
        width (int): width (lon) of box in m
        height (int): height (lat) of box in m

    Returns:
        lat_lon_grid (np.array(float)): list of grid points
        r_adjusted (int): new adjusted google search radius
    """
    # assert(width < 100000), f"width = {width}m is too large!"
    assert(height < 100000), f"height = {height}m is too large!"

    d = 2*radius
    # number of grid points in lon/width direction
    a = int(np.round(width/d))
    # number of grid points in lat/height direction
    b = int(np.round(height/d))
    r_adjusted = int(np.max([(width/a), (height/b)])/2)

    lon_min = center[1] - m_to_lon(width/2, center[0])
    lon_max = center[1] + m_to_lon(width/2, center[0])
    lat_min = center[0] - m_to_lat(height/2)
    lat_max = center[0] + m_to_lat(height/2)
    # Generate a uniform grid in lon and lat dimensions with a, b grid points in each dimension
    lon_values = np.linspace(lon_min, lon_max, a)  # Adjust the range based on your requirements
    lat_values = np.linspace(lat_min, lat_max, b)  # Adjust the range based on your requirements
    
    # Create a 2D grid using meshgrid
    lat_grid, lon_grid = np.meshgrid(lat_values, lon_values)

    lat_lon_grid = np.column_stack((lat_grid.flatten(), lon_grid.flatten()))
    
    return lat_lon_grid, r_adjusted

def google_place_request(location, radius, api_key='AIzaSyAn_1vHU9EfL2QxQBVCt0O8ftzdZieGdic'):
    """_summary_

    Args:
        location (list(float)): center of search area
        radius (int): search radius in m
        api_key (str, optional): _description_. Defaults to 'AIzaSyAn_1vHU9EfL2QxQBVCt0O8ftzdZieGdic'.

    Returns:
        doener_df (pd.DataFrame): _description_
        doener_data (rsponse.json): _description_
    """
    url = f'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={location[0]}, {location[1]}&radius={radius}&types=restaurant&keyword=döner&key={api_key}'

    response = requests.get(url)
    doener_data = response.json()

    doener_data_list = []
    for place in doener_data['results']:
        doener_data_list.append({
            'name': place['name'],
            'address': place['vicinity'],
            'lat': float(place['geometry']['location']['lat']),
            'lon': float(place['geometry']['location']['lng']),
            'rating': place['rating'],
            'place_id': place['place_id']
        })

    doener_df = pd.DataFrame(doener_data_list)
    return doener_df, doener_data

def download_doener_grid(center, radius, width, height, api_key='AIzaSyAn_1vHU9EfL2QxQBVCt0O8ftzdZieGdic'):
    """_summary_

    Args:
        center (string): center of box as "lat, lon"
        radius (int): approx google search radius in m
        width (int): box width (lon) in m
        height (int): box height (lat) in m
        api_key (str, optional): _description_. Defaults to 'AIzaSyAn_1vHU9EfL2QxQBVCt0O8ftzdZieGdic'.

    Returns:
        doener_df (pd.DataFrame): _description_
        doener_data_json (list(response.json)): _description_
    """
    center = [float(string) for string in center.split(', ')]
    lat_lon_grid, r_adjusted = create_lat_lon_grid(center, radius, width, height)
    num_requests = lat_lon_grid.shape[0]

    print(f"starting requests:")
    doener_df = pd.DataFrame(columns=['name', 'address', 'lat', 'lon', 'rating', 'place_id'])
    doener_data_json = []
    for idx, location in enumerate(lat_lon_grid):
        print(f"request {idx} out of {num_requests}: location={location}")
        doener_df_loc, doener_data = google_place_request(location, r_adjusted, api_key=api_key)
        time.sleep(1)

        doener_df = pd.concat([doener_df, doener_df_loc], ignore_index=True).drop_duplicates(subset='address')
        doener_data_json.append(doener_data)

    return doener_df, doener_data_json

api_key = 'AIzaSyAn_1vHU9EfL2QxQBVCt0O8ftzdZieGdic'
munich= "48.137174, 11.577493" # munich central location
radius = 1500  # Radius in meters, adjust as needed
width = 30000
height = 25000

# url = f'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={location}&radius={radius}&types=restaurant&keyword=döner&key={api_key}'

if __name__ == "__main__":
    
    doener_df, doener_data_json = download_doener_grid(munich, radius, width, height)

    df_output_file_path = 'munich_doener_df.json'
    doener_df.to_json(df_output_file_path, orient='records', lines=True)
    print(f'DataFrame has been saved to {df_output_file_path}')

    merged_dict = {}
    for response in doener_data_json:
        merged_dict.update(response)

    # Write the Merged Dictionary to a JSON File
    response_output_file_path = 'merged_response_output.json'
    with open(response_output_file_path, 'w') as json_file:
        json.dump(merged_dict, json_file, indent=2)
    print(f'response data has been saved to {response_output_file_path}')