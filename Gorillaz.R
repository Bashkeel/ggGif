library(spotifyr)
library(tidyverse)
library(ggridges)
library(lubridate)
library(purrr)
library(ggplot2)
library(magick)
library(magrittr)
library(stringr)

# Pull audio features using spotifyr package
Sys.setenv(SPOTIFY_CLIENT_ID = 'INSERT USERNAME HERE')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'INSERT PASSWORD HERE')
access_token <- get_spotify_access_token()
gorillaz <- get_artist_audio_features('Gorillaz')
gorillaz <- gorillaz %>%
  filter(album_name != "Demon Days Live At The Manchester Opera House")


# Valence Plot by Album
album_names <- gorillaz %>%
  arrange(album_release_year) %>%
  mutate(label = paste0(album_name, " (", year(album_release_year), ")")) %>%
  pull(label) %>% unique

p1 <- ggplot(gorillaz, aes(x=valence, y=as.character(album_release_year))) +
  geom_density_ridges() +
  theme_ridges(center_axis_labels = TRUE, grid = FALSE, font_size = 6) +
  labs(x="Song Valence (Positivity)", y="") +
  ggtitle("How happy are Gorillaz tracks?", "Song Valence by Album") + 
  scale_x_continuous(breaks=c(0,0.25, 0.5, 0.75, 1)) +
  scale_y_discrete(labels=album_names) +
  theme(plot.title = element_text(face = 'bold', size = 14, hjust = 0),
        plot.subtitle = element_text(size = 10, hjust = 0))
ggsave("Gorillaz Plot.png", p1, width=5, height=3)


# (Re)load the valence plot and the gif
background <- image_read("Gorillaz Plot.png")
plot_gif <- image_read('Gorillaz gif.gif')
plot_gif <- image_scale(plot_gif, "250")
looped_gif <- c(rep(plot_gif, 10))

# Add the movement of the gif on the plot background by frame
x_movement <- c(c(1:(length(looped_gif)/2))*10, c((length(looped_gif)/2):1)*10) *5 + 500
x_movement <- c(seq(300, 1300, length.out = length(looped_gif)/2), 
                rev(seq(300, 1300, length.out = length(looped_gif)/2)))

y_movement <- c(rep(600, (length(looped_gif)/8)),
                seq(600, 500, length.out = (length(looped_gif)/10)),
                rep(500, (length(looped_gif)/8)),
                seq(500, 600, length.out = (length(looped_gif)/10)),
                rep(600, (length(looped_gif)/20)))
y_movement <- c(y_movement, rev(y_movement))
frames <- map(1:length(looped_gif), function(frame){
  hjust <- x_movement[frame]
  vjust <- y_movement[frame]
  offset_string <- paste0("+", hjust, "+", vjust)
  image_composite(background, looped_gif[frame], offset = offset_string)
})

# Add gif (w/ movement) to background plot
image_animate(image_join(frames), fps = 10, loop = 0)
