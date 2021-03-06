---
title: "earthR a useful packages for cleaning and visualizing earthquakes"
author: "Gustavo Bruges"
date: "`r Sys.Date()`"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{earthR a useful packages for cleaning and visualizing earthquakes}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

The earthquake R package has useful fun (clean), and visualize, for cleanin and visualizing 
earthquake data from the U.S. National Oceanographic and Atmospheric Administration (NOAA) database. This dataset contains information about 5,933 earthquakes over an approximately
4,000 year time span and is avaialable at the URL:
https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1

# Cleaning data.

As with most data science projects, the first order of business is to clean the dataset to put it into a tidy format.

## eq_clean_data() Function

The eq_clean_data() function may be used to clean up the raw earthquake data.  This function returns a data frame containing the cleaned NOAA earthquake data. A DATE column is created by uniting the year, month and day columns and converting the result to the Date class. LATITUDE and LONGITUDE columns are converted to the numeric class and the LOCATION_NAME column has been cleaned by stripping out the country name (including the colon) and converting the names to title case (as opposed to all caps).

The raw data is provided by NOAA as a compressed, tab-separated variable file.  We begin by reading that file into a data frame named earthquakes_raw.  The raw data frame is then processed by eq_clean_data() and the cleaned data frame is summarized as shown below:

```{r}
library(earthquakeR)
# First read in the raw data file into a data frame from its compressed tab-separated variable file
raw_data<- readr::read_delim("signif.tsv", delim = "\t")
# After we have the raw data, clean it up for use by the visualization functions
cleaned_data <- eq_clean_data(earthquakes_raw)
# and summarize the cleaned data
str(cleaned_data)
```

## Visualizing earthquakes
Four functions have been created that help visualize the data:

Function Name | Description
--------------|------------
geom_timeline() | Geom for creating a timeline from the earthquake data
geom_timeline_label() | Geom for adding annotations to the earthquake data timeline created by geom_timeline()
eq_map() | Function which maps the epicenter (LATITUDE/LONGITUDE) of each earthquake on an interactive map and annotates each with a pop up window which contains the date of the earthquake (by default), and allows the user to select an alternate column of text to use for the label text.
eq_create_label() | Function which creates an HTML label that can be used as annotation text in the interactive leaflet map.

## geom_timeline() Function

The usage for the geom_timeline() function is quite straightforward.  The user must specify the data frame column which contains the earthquake dates as the x aesthetic.  Optionally, the user may also specify a date range to display, setting xmindate as the first year and xmaxdate as the last year to display on the timeline.  

As shown below, the earthquakes for the United States and China are displayed between the years 2000 and 2017:

```{r, eval = TRUE, fig.width=7}
library(earthquakeR)
library(grid)
library(ggmap)
library(magrittr)

cleaned_data <- readr::read_delim("signif.tsv", delim = "\t") %>%
  eq_clean_data() %>% dplyr::filter(COUNTRY == "USA" | COUNTRY == "CHINA")

ggplot(cleaned_data) +
  geom_timeline(aes(x = DATE, colour = TOTAL_DEATHS, size = EQ_PRIMARY), 
                alpha = 0.5, xmindate = 2000, xmaxdate = 2017) +
  theme_classic() +
  theme(legend.position = "bottom",
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(), 
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_line(colour = "grey", size = 0.5)) +
  labs(size = "Richter scale value ", colour = "# deaths ")

```





The color and size aesthetics may be used to display any desired continuous variable.  In the example above, color has been mapped to display the Total Number of Deaths for each earthquake (TOTAL_DEATHS) and the size has been mapped to the earthquake magnitude (EQ_PRIMARY).  The y aesthetic may be used to provide a factor (such as the COUNTRY) and will result in a separate timeline for each level of the factor, as shown below:


```{r, eval = TRUE, fig.width=7}

ggplot(cleaned_data) +
  geom_timeline(aes(x = DATE, y = COUNTRY, colour = TOTAL_DEATHS, size = EQ_PRIMARY), 
                alpha = 0.5, xmindate = 2000, xmaxdate = 2017) +
  theme_classic() +
  theme(legend.position = "bottom",
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(), 
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_line(colour = "grey", size = 0.5)) +
  labs(size = "Richter scale value ", colour = "# deaths ")

```

## geom_timeline_label() Function

The geom_timeline_label() function enables the user to add annotations to the earthquakes shown on the timeline.  The label aesthetic will select the data frame column to use for the annotation text and the n_max aesthetic may be selected to limit the number of 
annotations to the n_max largest earthquakes (by magnitude).  In the example below, the timeline above is enhanced to add 5 annotations, using the text from the EQ_PRIMARY column to label the size of the earthquakes.  Note that six earthquakes were labeled for the country of China, because two earthquakes had the same size equal to 6.0 on the Richter Scale.

```{r, eval = TRUE, fig.width=7}

 ggplot(cleaned_data, aes(DATE, COUNTRY)) +
     geom_timeline(aes(colour = TOTAL_DEATHS, size = EQ_PRIMARY), 
                   alpha = 0.5, xmindate = 2013, xmaxdate = 2017) +
     geom_timeline_label(aes(size = EQ_PRIMARY, label = EQ_PRIMARY), 
                         n_max = 5, xmindate = 2013, xmaxdate = 2017) +
     theme_classic() +
     theme(legend.position = "bottom",
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(), 
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_line(colour = "grey", size = 0.5)) +
     labs(size = "Richter scale value ", colour = "# deaths ") 

```


## eq_map() Function

While the geom_timeline() function displayed the earthquakes along a horizontal timeline, the eq_map() function displays the earthquakes on an inteactive geographical leaflet map.  The annot_col aesthetic may be used to select the data frame column to use for the text for the interactive annotation.  The annotation is created by pointing to an earthquake and clicking the mouse.  In the map below, the earthquake database has been reduced in size to show only earthquakes in Mexico after the year 2000, and the DATE column was selected to show the date of the earthquake that is selected when the user clicks on the earthquake point.



```{r, eval = TRUE, fig.width=7}

  readr::read_delim("signif.tsv", delim = "\t") %>%
  eq_clean_data() %>%
  dplyr::filter(COUNTRY == "CHILE" & lubridate::year(DATE) >= 2000) %>%
  eq_map(annot_col = "DATE")

```

## eq_create_label() Function

If the user desires to show more than just one piece of information about a selected earthquake, the eq_create_label() function may be used.  This function creates an HTML character string for each earthquake in a dataset that will show the cleaned location name (as cleaned by the eq_location_clean() function), the magnitude (EQ_PRIMARY), and the total number of deaths (TOTAL_DEATHS), with boldface labels for each ("Location", "Total deaths", and "Magnitude"). If an earthquake is missing values for any of these, both the label and the value are skipped for that element of the tag.

```{r, eval = TRUE, fig.width=7}

readr::read_delim("signif.tsv", delim = "\t") %>%
  eq_clean_data() %>%
  dplyr::filter(COUNTRY == "JAPAN" & lubridate::year(DATE) >= 2000) %>%
  dplyr::mutate(popup_text = eq_create_label(.)) %>%
  eq_map(annot_col = "popup_text")

```

