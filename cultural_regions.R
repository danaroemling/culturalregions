## -----------------------------------------------------------------------------
# Libraries
library(rnaturalearthhires)  # Access to high-resolution world maps (Natural Earth)
library(rnaturalearth)       # Access to lower-resolution world maps (Natural Earth)
library(dplyr)                # Data manipulation, e.g., filtering, selecting
library(sf)                   # Handling spatial data (Simple Features)
library(sp)                   # Spatial data handling (older method)
#library(FactoMineR)           # Principal Component Analysis and other multivariate methods
#library(factoextra)           # Visualizing results of multivariate methods (like PCA)
library(spdep)                # Spatial dependence: weights and testing
library(tidyverse)            # Collection of packages for data manipulation and visualization
#library(ggdendro)             # Visualizing dendrograms (hierarchical clustering)
#library(RColorBrewer)         # Color palettes for plotting
#library(ggwordcloud)          # Create word clouds with ggplot2


## -----------------------------------------------------------------------------
# Get the linguistic data 
matrix <- read.csv(file = '/Users/dana/Documents/R/PHD/data_ling/matrix_cities_x_variables_rel_freq_countries.csv', header = TRUE)
names(matrix) <- gsub("\\.", "", names(matrix))    
names(matrix) <- gsub("\\<X", "", names(matrix)) 

stopwords <- tolower(readLines("/Users/dana/Documents/R/PHD/data_ling/stopwords/stops2.txt"))
for (word in stopwords) {  
  if (word %in% colnames(matrix)) {  
    matrix <- matrix %>% 
      dplyr::select(-word)  
  }  
}  

matrix <- matrix %>% 
  filter(Tokencount > 10000) %>% 
  dplyr::select(1:2005)  

matrix_ger <- matrix %>% 
  filter(Germany == 1) %>% 
  dplyr::select(-Austria, 
                -Switzerland, 
                -Germany)  

matrix <- matrix %>% 
  dplyr::select(-Austria, 
                -Switzerland, 
                -Germany) 




## -----------------------------------------------------------------------------
# Get the geo data
gsa_outline <- ne_countries(country = c("Austria", 
                                        "Germany", 
                                        "Switzerland"), 
                            returnclass = "sf", 
                            scale = "large")
ger_outline <- ne_countries(country = "Germany", 
                            returnclass = "sf", 
                            scale = "large")

gsa_plot <- gsa_outline %>% 
  dplyr::select(geometry)
gsa_spatial <- as_Spatial(gsa_plot)

ger_plot <- ger_outline %>% 
  dplyr::select(geometry)
ger_spatial <- as_Spatial(ger_plot)

cities <- data.frame(
  City = c("Köln", "München", "Wien", "Zürich", "Berlin", "Hamburg"),
  Long = c(6.9578, 11.5755, 16.3731, 8.5417, 13.3833, 10),  # Longitude for each city
  Lat = c(50.9422, 48.1372, 48.2083, 47.3769, 52.5167, 53.55)  # Latitude for each city
)

cities_ger <- data.frame(
  City = c("Köln", "München", "Berlin", "Hamburg"),
  Long = c(6.9578, 11.5755, 13.3833, 10),  # Longitude of the cities
  Lat = c(50.9422, 48.1372, 52.5167, 53.55)  # Latitude of the cities
)

crs2 <- CRS("+init=epsg:4326")

cities_sf <- st_as_sf(cities, 
                      coords = c("Long", 
                                 "Lat"), crs = crs2)
cities_ger_sf <- st_as_sf(cities_ger, 
                      coords = c("Long", 
                                 "Lat"), crs = crs2)



## -----------------------------------------------------------------------------
# Compute Getis-Ord Gi*  
getis_matrix <- matrix
getis_coord <- as.matrix(data.frame(LONG = matrix$lon, 
                                     LAT = matrix$lat))  
neighbours <- knn2nb(knearneigh(getis_coord, 
                                k = 10, 
                                longlat = TRUE))  
neighbours <- include.self(neighbours)  
neighbours_weighted <- nb2listw(neighbours, 
                                style = "B")  

for (i in 5:ncol(matrix))  
{  
  temp <- localG(as.numeric(matrix[,i]), 
                 neighbours_weighted)  
  
  temp <- round(temp, 
                3)  
  
  getis_matrix[,i] <- temp  
}  



# -----------------
# Germany only
getis_ger_matrix <- matrix_ger
getis_ger_coord <- as.matrix(data.frame(LONG = matrix_ger$lon, 
                                    LAT = matrix_ger$lat))  
neighbours_ger <- knn2nb(knearneigh(getis_ger_coord, 
                                k = 10, 
                                longlat = TRUE))  
neighbours_ger <- include.self(neighbours_ger)  
neighbours_ger_weighted <- nb2listw(neighbours_ger, 
                                style = "B")  

for (i in 5:ncol(matrix_ger))  
{  
  temp <- localG(as.numeric(matrix_ger[,i]), 
                 neighbours_ger_weighted)  
  
  temp <- round(temp, 
                3)  
  
  getis_ger_matrix[,i] <- temp  
}  



## -----------------------------------------------------------------------------
# PCA
pca_spatial <- PCA(getis_matrix[8:ncol(getis_matrix)], scale.unit = FALSE, ncp = 5, graph = TRUE)
first_city <- as.data.frame(pca_spatial$ind$coord)
combined_city <- cbind(matrix, 
                       first_city)
combined_city_sf <- st_as_sf(combined_city, coords = c("lon", "lat"), crs = 4326)
# plot.PCA(pca_spatial, axes=c(1, 2))

tiff("scree_pca.tiff", 
     units = "in", 
     width = 7, 
     height = 4.5, 
     res = 300)

fviz_eig(pca_spatial, 
         addlabels = FALSE, 
         ggtheme = theme_minimal(),  
         ncp = 7,  
         barcolor = "plum4",  
         barfill = "plum4",
         linecolor = "white",
         font.label = list(size = 11, color = "white", vjust = -0.5))  +
  theme(
    plot.background = element_rect(fill = "black", color = "black"),
    panel.background = element_rect(fill = "black", color = "black"),
    panel.grid.major = element_line(color = "grey20"),
    panel.grid.minor = element_line(color = "grey10"),
    text = element_text(color = "white"),
    axis.text = element_text(color = "white", margin = margin(r = 10)),
    axis.title = element_text(color = "white", margin = margin(r = 15)),
    plot.title = element_text(color = "white", hjust = 0.5)
  ) +
  geom_point(color = "white", size = 2) +
  geom_text(aes(label = paste0(round(..y.., 1), "%")), 
            color = "white", 
            vjust = -0.8, 
            size = 3)

dev.off()


# -----------------
# PCA Germany
pca_spatial_ger <- PCA(getis_ger_matrix[8:ncol(getis_ger_matrix)], scale.unit = FALSE, ncp = 5, graph = TRUE)
first_city_ger <- as.data.frame(pca_spatial_ger$ind$coord)
combined_city_ger <- cbind(matrix_ger, 
                       first_city_ger)
combined_city_ger_sf <- st_as_sf(combined_city_ger, coords = c("lon", "lat"), crs = 4326)

tiff("scree_pca_ger.tiff", 
     units = "in", 
     width = 7, 
     height = 4.5, 
     res = 300)

fviz_eig(pca_spatial_ger, 
         addlabels = FALSE, 
         ggtheme = theme_minimal(),  
         ncp = 7,  
         barcolor = "plum4",  
         barfill = "plum4",
         linecolor = "white",
         font.label = list(size = 11, color = "white", vjust = -0.5))  +
  theme(
    plot.background = element_rect(fill = "black", color = "black"),
    panel.background = element_rect(fill = "black", color = "black"),
    panel.grid.major = element_line(color = "grey20"),
    panel.grid.minor = element_line(color = "grey10"),
    text = element_text(color = "white"),
    axis.text = element_text(color = "white", margin = margin(r = 10)),
    axis.title = element_text(color = "white", margin = margin(r = 15)),
    plot.title = element_text(color = "white", hjust = 0.5)
  ) +
  geom_point(color = "white", size = 2) +
  geom_text(aes(label = paste0(round(..y.., 1), "%")), 
            color = "white", 
            vjust = -0.8, 
            size = 3)

dev.off()



## -----------------------------------------------------------------------------
# Mapping

tiff("pca_all_dim1_nofunction.tiff", 
     units = "in", 
     width = 4, 
     height = 4.8, 
     res = 300,
     bg = "black")

ggplot() +
  # 1. Dark background for the countries with subtle off-white borders
  geom_sf(data = gsa_plot, 
          aes(geometry = geometry), 
          color = "grey80",     # Dark grey border instead of harsh black
          fill = "grey25",     # Very dark grey/off-black country fill
          size = 0.5) +
  
  # 2. The cities filled by Dim.5 (Gradient remains, but we add a subtle border so they pop)
  geom_sf(data = combined_city_sf, 
          aes(fill = Dim.1), 
          shape = 21, 
          size = 3, 
          color = "grey25",    # Matches the country fill so the dots look crisp
          stroke = 0.5) +       # Added a tiny stroke so colors don't bleed into the background
  
  # 3. City labels changed to an off-white/light grey
  geom_sf_text(data = cities_sf, 
               aes(label = City), 
               size = 2, 
               nudge_x = 0, 
               nudge_y = -0.15, 
               family = "Optima",
               color = "grey85") +  # Off-white so it's readable but not blinding
  
  # 4. Changed the "X" marks to white so they are visible
  geom_sf(data = cities_sf, 
          aes(geometry = geometry), 
          shape = 4,
          color = "white") +    # Forces the X to be white
  
  theme_minimal() +
  
  # 5. Adjusted gradient for dark mode (Midpoint changed from white to a dark/neutral tone)
  scale_fill_gradient2(low = "#e66101",       # Brighter red so it stands out on dark backgrounds
                       mid = "white",        # Grey mid-point so it doesn't blend into the black country fill
                       high = "#5e3c99",      # Brighter blue for visibility
                       midpoint = 0) +
  
  ggtitle("Dimension 1") +
  
  # 6. Full Dark Mode canvas settings
  theme(
    # Make the overall canvas completely black
    plot.background = element_rect(fill = "black", color = "black"),
    panel.background = element_rect(fill = "black", color = "black"),
    
    # Keep your original removals
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    # White title text with your original spacing
    plot.title = element_text(color = "white",
                              size = 10, 
                              hjust = 0.5, 
                              vjust = -7,
                              margin = margin(b = 15)),
    
    # Keep legend hidden
    legend.position = "none"
  )

dev.off()




# -----------------
# Mapping Germany

tiff("pca_ger_dim4_nofunction.tiff", 
     units = "in", 
     width = 4, 
     height = 4.8, 
     res = 300,
     bg = "black")

ggplot() +
  # 1. Dark background for the countries with subtle off-white borders
  geom_sf(data = ger_plot, 
          aes(geometry = geometry), 
          color = "grey80",     # Dark grey border instead of harsh black
          fill = "grey25",     # Very dark grey/off-black country fill
          size = 0.5) +
  
  # 2. The cities filled by Dim.5 (Gradient remains, but we add a subtle border so they pop)
  geom_sf(data = combined_city_ger_sf, 
          aes(fill = Dim.4), 
          shape = 21, 
          size = 3, 
          color = "grey25",    # Matches the country fill so the dots look crisp
          stroke = 0.5) +       # Added a tiny stroke so colors don't bleed into the background
  
  # 3. City labels changed to an off-white/light grey
  geom_sf_text(data = cities_ger_sf, 
               aes(label = City), 
               size = 2, 
               nudge_x = 0, 
               nudge_y = -0.15, 
               family = "Optima",
               color = "grey85") +  # Off-white so it's readable but not blinding
  
  # 4. Changed the "X" marks to white so they are visible
  geom_sf(data = cities_ger_sf, 
          aes(geometry = geometry), 
          shape = 4,
          color = "white") +    # Forces the X to be white
  
  theme_minimal() +
  
  # 5. Adjusted gradient for dark mode (Midpoint changed from white to a dark/neutral tone)
  scale_fill_gradient2(low = "#e66101",       # Brighter red so it stands out on dark backgrounds
                       mid = "white",        # Grey mid-point so it doesn't blend into the black country fill
                       high = "#5e3c99",      # Brighter blue for visibility
                       midpoint = 0) +
  
  ggtitle("Dimension 4") +
  
  # 6. Full Dark Mode canvas settings
  theme(
    # Make the overall canvas completely black
    plot.background = element_rect(fill = "black", color = "black"),
    panel.background = element_rect(fill = "black", color = "black"),
    
    # Keep your original removals
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    # White title text with your original spacing
    plot.title = element_text(color = "white",
                              size = 10, 
                              hjust = 0.5, 
                              vjust = -7,
                              margin = margin(b = 15)),
    
    # Keep legend hidden
    legend.position = "none"
  )

dev.off()








## -----------------------------------------------------------------------------
# Extracting significant words
first <- as.data.frame(pca_spatial$var$coord)
colnames(first) <- c("d1", 
                     "d2", 
                     "d3", 
                     "d4", 
                     "d5")

extracted_dims <- lapply(1:5, function(i) {
  col_name <- paste0("d", i)
  
  # Sort the data frame by the current dimension
  sorted_df <- first[order(first[[col_name]], decreasing = TRUE), , drop = FALSE]
  
  # Get top 50 and bottom 50 data frames
  top_50 <- head(sorted_df, 50)
  bot_50 <- tail(sorted_df, 50)
  
  # Create a 4-column data frame for this specific dimension
  dim_df <- data.frame(
    Var_High = rownames(top_50),
    Val_High = top_50[[col_name]],
    Var_Low  = rownames(bot_50),
    Val_Low  = bot_50[[col_name]]
  )
  
  # Give the columns unique names based on the dimension number (e.g., Dim1_High_Var)
  colnames(dim_df) <- paste0("Dim", i, "_", c("High_Var", "High_Val", "Low_Var", "Low_Val"))
  return(dim_df)
})

wide_loadings <- do.call(cbind, extracted_dims)

write.csv(wide_loadings, "pca_loadings_wide.csv", row.names = FALSE)





# -----------------
# Germany

first <- as.data.frame(pca_spatial_ger$var$coord)
colnames(first) <- c("d1", 
                     "d2", 
                     "d3", 
                     "d4", 
                     "d5")

extracted_dims_ger <- lapply(1:5, function(i) {
  col_name <- paste0("d", i)
  
  # Sort the data frame by the current dimension
  sorted_df <- first[order(first[[col_name]], decreasing = TRUE), , drop = FALSE]
  
  # Get top 50 and bottom 50 data frames
  top_50 <- head(sorted_df, 50)
  bot_50 <- tail(sorted_df, 50)
  
  # Create a 4-column data frame for this specific dimension
  dim_df <- data.frame(
    Var_High = rownames(top_50),
    Val_High = top_50[[col_name]],
    Var_Low  = rownames(bot_50),
    Val_Low  = bot_50[[col_name]]
  )
  
  # Give the columns unique names based on the dimension number (e.g., Dim1_High_Var)
  colnames(dim_df) <- paste0("Dim", i, "_", c("High_Var", "High_Val", "Low_Var", "Low_Val"))
  return(dim_df)
})

wide_loadings_ger <- do.call(cbind, extracted_dims_ger)

write.csv(wide_loadings_ger, "pca_loadings_wide_ger.csv", row.names = FALSE)






