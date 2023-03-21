
# init environment
rm(list = ls())

library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)

base_dir <- here::here()

print(base_dir)

setwd(base_dir)

# load latest enao genre data
all_enao_files <- list.files(path = "data", pattern = "enao-genres-[0-9]{8}.csv")
enao_file_to_use <- sort(all_enao_files, decreasing = T)[1]

print(paste("using ENAO data from", enao_file_to_use))

enao <- as_tibble(read.csv(paste0("data/", enao_file_to_use)))

# load latest bt genre data
all_btg_files <- list.files(path = "data", pattern = "bt-spotify-genres-[0-9]{8}.csv")
btg_file_to_use <- sort(all_btg_files, decreasing = T)[1]

print(paste("using BT Genre data from", btg_file_to_use))

bt_genre <- as_tibble(read.csv(paste0("data/", btg_file_to_use)))

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
  scale_color_identity(guide = F) +
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

# save enao plots
ggsave(filename = paste0("img/", format(Sys.Date(), "%Y%m%d"), "_enao-all-map.jpg"),
       plot = enao.plot,
       device = "jpeg", width = 7, height = 9, units = "in")

ggsave(filename = "enao-all-map-latest.jpg",
       plot = enao.plot,
       device = "jpeg", width = 7, height = 9, units = "in")

# plot contour on top of ENAO scatter
bt_genre.plot <- bt_genre %>%
  uncount(n_tracks) %>%
  left_join(enao.clean %>%
              select(genre, top, left), 
            by = "genre") %>%
  ggplot(aes(x = left, y = top)) +
  stat_density_2d(geom = "polygon",
                  contour = TRUE,
                  aes(fill = after_stat(level)),
                  # color = "gray",
                  bins = 30,
                  show.legend = F) +
  geom_jitter(color = "#4a4a4a", size = 1, alpha = 0.1, width = 0.25, height = 0.25) +
  geom_label(enao.clean %>% 
               filter(genre %in% c("rock", "rap", "pop", "pop rock", "funk", 
                                   "jazz", "focus", "metal", "folk", "techno", 
                                   "classical")),
             mapping = aes(x = left, y = top, label = genre), size = 4, color = "black") +
  scale_x_continuous(name = "\u2190 more atmospheric                              more bouncy \u2192", limits = c(0, 100), expand = c(0, 0)) +
  scale_y_continuous(name = "\u2190 more organic                              more mechanical \u2192", limits = c(0, 100), expand = c(0, 0)) +
  scale_fill_distiller(palette = "Spectral") +
  labs(title = "Mapping my musical taste on Spotify, according to Every Noise at Once") +
  labs(title = paste0("Mapping my musical taste on Spotify", 
                      "\naccording to Every Noise at Once as of ",
                      format(Sys.Date(), "%m/%d/%Y"))) +
  theme_classic() +
  theme(legend.position = "none",
        text = element_text(size = 12,  family = "Arial"),
        plot.title = element_text(hjust = 0.5, size = 16),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())

# save bt genre plots
ggsave(filename = paste0("img/", format(Sys.Date(), "%Y%m%d"), "_bt-genre-map.jpg"),
       plot = bt_genre.plot,
       device = "jpeg", width = 7, height = 9, units = "in")

ggsave(filename = "bt-genre-map-latest.jpg",
       plot = bt_genre.plot,
       device = "jpeg", width = 7, height = 9, units = "in")


