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

genres_objs = [{
    style.split(":")[0].strip().replace("-", "_"): style.split(":")[1].strip() 
    for style in ("genre: %s;%s" % (genre.get_attribute("innerText"), genre.get_attribute("style"))).split(";") 
    if len(style) > 0
 } for genre in genres_elems]

genres_df = pd.DataFrame(genres_objs)

# add run date to df
today = datetime.today().strftime("%Y%m%d")
genres_df["run_date"] = today

# save data
genres_df.to_csv("data/enao-genres-%s.csv" % today, index = False)
genres_df.to_csv("enao-genres-latest.csv", index = False)

