library(shiny)
library(leaflet)
library(rgdal)
library(dplyr)
library(lubridate)

pred <- glm(price ~ ., data = housing)

zips <- readOGR("zips")

zip.avgs <-
        housing %>% group_by(zipcode) %>% summarize(
                price = mean(price),
                sqft_living = mean(sqft_living),
                condition = mean(condition),
                yr_built = mean(yr_built)
        )

content <-
        paste0(
                "<h3 style = 'margin-bottom: 5px'>",
                zip.avgs$zipcode,
                "</h3><b>Average Price: </b>",
                paste0("$", formatC(
                        as.numeric(zip.avgs$price),
                        format = "f",
                        digits = 0,
                        big.mark = ","
                )),
                "<br/><b>Average Square Footage: </b>",
                round(zip.avgs$sqft_living, 0),
                " sqft",
                "<br/><b>Average Condition: </b>",
                round(zip.avgs$condition, 1),
                " out of 5",
                "<br/><b>Average Age of Home: </b>",
                round(year(Sys.Date()) - zip.avgs$yr_built, 0),
                " years old"
        )

shinyServer(function(input, output) {
        output$estimate <- renderText({
                input$action
                
                isolate({
                        dream.home <-
                                data.frame(
                                        bedrooms = input$bed,
                                        bathrooms = input$bath,
                                        floors = input$floors,
                                        sqft_living = input$sqft,
                                        sqft_lot = input$lot,
                                        condition = input$condition,
                                        grade = input$grade,
                                        yr_built = input$year,
                                        zipcode = input$zip
                                )
                        
                        
                        x <- predict(pred, dream.home)
                        
                        paste0(
                                "$",
                                formatC(
                                        as.numeric(x),
                                        format = "f",
                                        digits = 0,
                                        big.mark = ","
                                )
                        )
                })
                
        })
        
        output$map <- renderLeaflet({
                leaflet(zips) %>%
                        addProviderTiles(providers$CartoDB.Positron) %>%
                        addPolygons(
                                color = "#444444",
                                weight = 0.25,
                                smoothFactor = 0.5,
                                opacity = 1.0,
                                fillOpacity = 0.75,
                                fillColor = colorBin("Blues", zip.avgs$price, bins = 8)(zip.avgs$price),
                                popup = content,
                                group = "Home Price",
                                highlightOptions = highlightOptions(
                                        color = "white",
                                        weight = 1,
                                        bringToFront = TRUE
                                )
                        ) %>%
                        addPolygons(
                                color = "#444444",
                                weight = 0.25,
                                smoothFactor = 0.5,
                                opacity = 1.0,
                                fillOpacity = 0.75,
                                fillColor = colorBin("Blues", zip.avgs$sqft_living, bins = 8)(zip.avgs$sqft_living),
                                popup = content,
                                group = "Square Footage",
                                highlightOptions = highlightOptions(
                                        color = "white",
                                        weight = 1,
                                        bringToFront = TRUE
                                )
                        ) %>%
                        addPolygons(
                                color = "#444444",
                                weight = 0.25,
                                smoothFactor = 0.5,
                                opacity = 1.0,
                                fillOpacity = 0.75,
                                fillColor = colorBin("Blues", zip.avgs$condition, bins = 4)(zip.avgs$condition),
                                popup = content,
                                group = "Condition",
                                highlightOptions = highlightOptions(
                                        color = "white",
                                        weight = 1,
                                        bringToFront = TRUE
                                )
                        ) %>%
                        addPolygons(
                                color = "#444444",
                                weight = 0.25,
                                smoothFactor = 0.5,
                                opacity = 1.0,
                                fillOpacity = 0.75,
                                fillColor = colorBin(
                                        "Blues",
                                        year(Sys.Date()) - zip.avgs$yr_built,
                                        bins = 8
                                )(year(Sys.Date()) - zip.avgs$yr_built),
                                popup = content,
                                group = "Age of Home",
                                highlightOptions = highlightOptions(
                                        color = "white",
                                        weight = 1,
                                        bringToFront = TRUE
                                )
                        ) %>%
                        addLayersControl(
                                position = "topright",
                                baseGroups = c(
                                        "Home Price",
                                        "Square Footage",
                                        "Condition",
                                        "Age of Home"
                                )
                        ) %>%
                        setView(-121.9048, 47.3578, zoom = 9)
        })
        
        observeEvent(input$map_groups, {
                map <- leafletProxy("map") %>% clearControls()
                if (input$map_groups == "Home Price")
                {
                        map %>% addLegend(
                                "bottomleft",
                                pal = colorBin("Blues", zip.avgs$price, bins = 8),
                                values = zip.avgs$price,
                                title = "Avg. Home Price",
                                labFormat = labelFormat(prefix = "$"),
                                opacity = 1
                        )
                }
                else if (input$map_groups == "Square Footage")
                {
                        map %>% addLegend(
                                "bottomleft",
                                pal = colorBin("Blues", zip.avgs$sqft_living, bins = 8),
                                values = zip.avgs$sqft_living,
                                title = "Avg. Square Footage",
                                opacity = 1
                        )
                }
                else if (input$map_groups == "Condition")
                {
                        map %>% addLegend(
                                "bottomleft",
                                pal = colorBin("Blues", zip.avgs$condition, bins = 4),
                                values = zip.avgs$condition,
                                title = "Avg. Condition",
                                opacity = 1
                        )
                }
                else if (input$map_groups == "Age of Home")
                {
                        map %>% addLegend(
                                "bottomleft",
                                pal = colorBin(
                                        "Blues",
                                        year(Sys.Date()) - zip.avgs$yr_built,
                                        bins = 8
                                ),
                                values = year(Sys.Date()) - zip.avgs$yr_built,
                                title = "Avg. Age of Home",
                                opacity = 1
                        )
                }
        })
        
        output$inputzip <- renderText({
                input$action
                
                isolate({
                        print(input$zip)
                })
        })
        
        output$avgprice <- renderText({
                input$action
                
                isolate({
                        x <- zip.avgs %>% filter(zipcode == input$zip) %>% select(price)
                        paste0(
                                "$",
                                formatC(
                                        as.numeric(x[[1]]),
                                        format = "f",
                                        digits = 0,
                                        big.mark = ","
                                )
                        )
                })
        })
        
        output$avgsize <- renderText({
                input$action
                
                isolate({
                        x <-
                                zip.avgs %>% filter(zipcode == input$zip) %>% select(sqft_living)
                        paste(round(x[[1]], 0), " sqft")
                })
        })
        
        output$avgcondition <- renderText({
                input$action
                
                isolate({
                        x <- zip.avgs %>% filter(zipcode == input$zip) %>% select(condition)
                        paste(round(x[[1]], 1), " out of 5")
                })
        })
        
        output$avgage <- renderText({
                input$action
                
                isolate({
                        x <- zip.avgs %>% filter(zipcode == input$zip) %>% select(yr_built)
                        paste(round(year(Sys.Date(
                                
                        )) - x[[1]]), " years")
                })
        })
        
})
