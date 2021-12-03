# -*- coding: utf-8 -*-

import os
import pandas as pd
from datetime import datetime

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

# change to project dir
if os.getcwd()[-17:] != "spotify-genre-map":
    os.chdir("/Users/ben-tanen/Desktop/Projects/spotify-genre-map")

# set up selenium driver
chrome_options = Options()
chrome_options.add_argument("--headless")
driver = webdriver.Chrome(ChromeDriverManager().install(), options = chrome_options)
url = "https://everynoise.com/"
driver.get(url)

# scrape all genres + convert style attributes to DataFrame
genres_elems = driver.find_elements_by_class_name("genre")

genres_objs = [ ]
for genre in genres_elems:
    genre_obj = {
        "genre": genre.get_attribute("innerText"),
        "preview_url": genre.get_attribute("preview_url"),
        "preview_track": genre.get_attribute("title")
    }
    
    for style in genre.get_attribute("style").split(";")[:-1]:
        [key,value] = style.split(":")
        genre_obj[key.strip().replace("-", "_")] = value.strip()
    
    genres_objs.append(genre_obj)
    
genres_df = pd.DataFrame(genres_objs)

# add run date to df
today = datetime.today().strftime("%Y%m%d")
genres_df["run_date"] = today

# save data
genres_df.to_csv("data/enao-genres-%s.csv" % today, index = False)
genres_df.to_csv("enao-genres-latest.csv", index = False)

