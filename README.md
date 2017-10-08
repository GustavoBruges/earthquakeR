# earthquakeR
R Capstone Project
The package includes several exported functions to handle NOAA data. The provided data set includes data on earthquakes starting year 2150 B.C. and contains dates, locations, magnitudes, severity and other features.

This package handles basic data cleaning using function eq_clean_data() and then two types of visualizations. The first is a ggplot2-based earthquake timeline of selected earthquakes using geom_timeline() and geom_timeline_label() with optional usage of theme_timeline() function. The second visualization is based on leaflet package and shows the earthquakes with some basic parameters on a map.