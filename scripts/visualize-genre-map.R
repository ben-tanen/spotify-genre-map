
# init environment
rm(list = ls())

library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)

print(getwd())

if (!grepl("spotify-genre-map(/)?$", getwd())) setwd("~/Desktop/Projects/spotify-genre-map/")

# load latest enao genre data
all_files <- list.files(path = "data", pattern = "enao-genres-[0-9]{8}.csv")
file_to_use <- sort(all_files, decreasing = T)[1]

print(paste("using data from", file_to_use))

enao <- read.csv(paste0("data/", file_to_use))

# clean enao genre data + plot it as a scatter
enao.clean <- enao %>%
  mutate(color_clean1 = gsub("rgb[(]|[)]| ", "", color),
         top_clean1 = as.numeric(gsub("px", "", top)),
         left_clean1 = as.numeric(gsub("px", "", left)),
         size_clean1 = as.numeric(gsub("%", "", font_size)),
         top_clean2 = rescale(top_clean1,
                              from = c(min(top_clean1), max(top_clean1)),
                              to = c(100, 0)),
         left_clean2 = rescale(left_clean1,
                               from = c(min(left_clean1), max(left_clean1)),
                               to = c(0, 100)),
         size_clean2 = rescale(size_clean1,
                               from = c(min(size_clean1), max(size_clean1)),
                               to = c(0, 1))) %>%
  separate(color_clean1, into = c("r", "g", "b"), sep = ",") %>%
  mutate(across(c("r", "g", "b"), ~ as.numeric(.x) / 255),
         color_clean2 = rgb(r, g, b)) %>%
  select(genre, color = color_clean2, size = size_clean2, top = top_clean2, left = left_clean2)

point_colors <- enao.clean$color
names(point_colors) <- enao.clean$color

print(paste0("plotting data for ", nrow(enao.clean), " genres"))

enao.plot <- enao.clean %>%
  ggplot(aes(x = left, y = top)) +
  geom_point(aes(color = color), size = 0.5, alpha = 0.4) +
  geom_label(enao.clean %>% 
               filter(genre %in% c("rock", "rap", "pop", "pop rock", "funk", 
                                   "jazz", "focus", "metal", "folk", "techno", 
                                   "classical")),
             mapping = aes(x = left, y = top, label = genre), size = 4, color = "black") +
  scale_x_continuous(name = "\u2190 more atmospheric                              more bouncy \u2192", limits = c(0, 100), expand = c(0, 0)) +
  scale_y_continuous(name = "\u2190 more organic                              more mechanical \u2192", limits = c(0, 100), expand = c(0, 0)) +
  scale_color_manual(values = point_colors, guide = F) +
  labs(title = paste0("Mapping the ", 
                      comma(nrow(enao)),
                      " distinct musical genres on Spotify,\naccording to Every Noise at Once as of ",
                      format(Sys.Date(), "%m/%d/%Y"))) +
  theme_classic() +
  theme(legend.position = "none",
        text = element_text(size = 12,  family = "Arial"),
        plot.title = element_text(hjust = 0.5, size = 16),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())

# save plots
ggsave(filename = paste0("img/", format(Sys.Date(), "%Y%m%d"), "_enao-all-map.jpg"),
       plot = enao.plot,
       device = "jpeg", width = 7, height = 9, units = "in")

ggsave(filename = "enao-all-map-latest.jpg",
       plot = enao.plot,
       device = "jpeg", width = 7, height = 9, units = "in")

