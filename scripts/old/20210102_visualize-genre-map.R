library(data.table)
library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)

setwd("~/Desktop/Projects/spotify-genre-map/data/")

# import artist genres
artist_genres <- read.csv("2020.07.25 - artist genres.csv")

# clean/parse genre location on every noise at once
enao <- read.csv("2020.07.25 - every-noise-at-once-scrape.csv")

enao.clean <- enao %>%
    mutate(left_clean1 = as.numeric(gsub("px", "", left)),
           top_clean1 = as.numeric(gsub("px", "", top)),
           size_clean1 = as.numeric(gsub("%", "", size)),
           left_clean2 = rescale(left_clean1,
                                 from = c(min(left_clean1), max(left_clean1)),
                                 to = c(0, 100)),
           top_clean2 = rescale(top_clean1,
                                from = c(min(top_clean1), max(top_clean1)),
                                to = c(100, 0)),
           size_clean2 = rescale(size_clean1,
                                 from = c(min(size_clean1), max(size_clean1)),
                                 to = c(0, 1))) %>%
    select(genre, color, size_clean2, top_clean2, left_clean2) %>%
    rename(size = size_clean2, top = top_clean2, left = left_clean2)

# clean artist genres
artist_genres.clean <- artist_genres %>% 
    separate(genres, sep = "\\|", into = paste0("var", 1:15)) %>% 
    pivot_longer(var1:var15) %>% 
    filter(!is.na(value) & value != "") %>% 
    select(-name) %>%
    rename(genre = value) %>%
    data.table()

# aggregate information and merge on every-noise-at-once data
genres <- artist_genres.clean[, .(N = .N, S = sum(count)), by = genre] %>%
    left_join(enao.clean, by = "genre")

# plot it
ggplot(genres, aes(x = left, y = top)) +
    geom_density2d(aes(color = ..level..), size = 0.8, bins = 25) + 
    stat_density2d(aes(fill = ..level..), bins = 25, geom = "polygon", alpha = 0.1) +
    geom_point(enao.clean, mapping = aes(x = left, y = top), size = 0.1, alpha = 0.5) +
    geom_label(enao.clean %>% 
                   filter(genre %in% c("rock", "rap", "pop", "pop rock", "funk", 
                                       "jazz", "focus", "metal", "folk", "techno", 
                                       "classical")),
               mapping = aes(x = left, y = top, label = genre), size = 4, color = "black") +
    #geom_point(genres, mapping = aes(x = left, y = top, size = S), shape = 21, color = "black", fill = "#77bdee") +
    #scale_color_discrete() +
    scale_color_gradient(low = "#06D6A0", high = "#EF476F") +
    scale_fill_gradient(low = "#06D6A0", high = "#EF476F") +
    scale_x_continuous(name = "← more atmospheric                              more bouncy →", limits = c(0, 100), expand = c(0, 0)) +
    scale_y_continuous(name = "← more organic                              more mechanical →", limits = c(0, 100), expand = c(0, 0)) +
    labs(title = "Mapping my musical taste on Spotify,\naccording to Every Noise at Once") +
    theme_classic() +
    theme(legend.position = "none",
          text = element_text(size = 12,  family = "Arial"),
          plot.title = element_text(hjust = 0.5, size = 16),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank())

ggsave("../enao-bt-map.jpg", device = "jpeg", width = 7, height = 9, units = "in")

# export data for observable version
write.csv(enao.clean, "enao-genres-clean.csv", row.names = F)
artist_genres.clean %>%
    select(artist, genre) %>%
    mutate(genre = as.character(genre)) %>%
    left_join(enao.clean %>%
                  mutate(genre = as.character(genre)) %>%
                  select(genre, top, left), 
              by = "genre") %>%
    write.csv("bt-genres-clean.csv", row.names = F)

