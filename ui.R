library(shiny)
library(leaflet)

shinyUI(fluidPage(
        titlePanel("Estimating Home Prices in King County, WA"),
        
        sidebarLayout(
                sidebarPanel(
                        h3("Rooms/Floors"),
                        sliderInput(
                                "bed",
                                "Number of Bedrooms:",
                                min = 1,
                                max = 10,
                                value = 3,
                                step = 1
                        ),
                        sliderInput(
                                "bath",
                                "Number of Bathrooms:",
                                min = 1,
                                max = 8,
                                value = 2,
                                step = 0.5
                        ),
                        sliderInput(
                                "floors",
                                "Number of Floors:",
                                min = 1,
                                max = 4,
                                value = 1.5,
                                step = 0.5
                        ),
                        h3("Square Footage"),
                        numericInput("sqft",
                                     "Size of Living Area (sqft):",
                                     value = 2000),
                        numericInput("lot",
                                     "Total Size of Lot (sqft):",
                                     value = 8000),
                        h3("Condition"),
                        sliderInput(
                                "condition",
                                "Condition of House (Scale 1 to 5):",
                                min = 1,
                                max = 5,
                                value = 3,
                                step = 1
                        ),
                        sliderInput(
                                "grade",
                                "Overall Grade (Awarded by King County):",
                                min = 1,
                                max = 13,
                                value = 7,
                                step = 1
                        ),
                        sliderInput(
                                "year",
                                "Year Built:",
                                min = 1900,
                                max = 2015,
                                value = 1975,
                                step = 1,
                                sep = ""
                        ),
                        h3("Location"),
                        selectizeInput("zip",
                                       "Zip Code:",
                                       sort(unique(housing$zipcode))),
                        actionButton("action", "Apply Changes")
                ),
                
                mainPanel(fixedPanel(tabsetPanel(
                        tabPanel(
                                "Instructions",
                                h3("Introduction:"),
                                p(
                                        "This application estimates the price of your dream home, if it were located in King County, Washington. Using a data set of 21,612 homes (which includes variables like square footage, number of bedrooms and bathrooms, condition, etc.), the application builds a prediction model to estimate the price of a fictional home, based on your inputs."
                                ),
                                h3("Getting Started:"),
                                tags$ol(
                                        tags$li(
                                                HTML(
                                                        "Once you're ready, switch over to the <em>Estimation</em> tab to get started."
                                                )
                                        ),
                                        tags$li(
                                                "Then, use the sliders, text boxes, and dropdown menus in the grey panel on the left to build your dream home."
                                        ),
                                        tags$li(
                                                HTML(
                                                        "When you're satisfied with your choices, click the <em>Apply Changes</em> button to generate an estimation. It will appear beneath the interactive map."
                                                )
                                        ),
                                        tags$li(
                                                HTML(
                                                        "After you settle on a price point, use the interactive map to explore your surroundings. The <em>Quick Facts</em> box on the right will tell you how your dream home compares to other homes in your new zip code. And the different map layers will show you how homes in your new zip code compare to those in others."
                                                )
                                        )
                                ),
                                h3("Data:"),
                                p(
                                        HTML(
                                                "Housing data was gathered from <a href = 'https://www.kaggle.com/harlfoxem/housesalesprediction' target = '_blank'>Kaggle</a>. Shapefiles were gathered from the <a href = 'https://www.census.gov/geo/maps-data/data/cbf/cbf_zcta.html' target = '_blank'>United States Census Bureau</a>."
                                        )
                                )
                        ),
                        tabPanel(
                                "Estimation",
                                fixedPanel(
                                        width = "63.67%",
                                        height = "auto",
                                        leafletOutput("map", height = 500),
                                        
                                        fixedPanel(
                                                width = 200,
                                                height = "auto",
                                                top = 275,
                                                right = "2.5%",
                                                style = "background:white;padding:12px 15px 12px 15px;border-radius:5px",
                                                tags$div(
                                                        tags$h4("Quick Facts"),
                                                        tags$p(tags$strong("Zip Code:"), style = "margin-bottom:0"),
                                                        textOutput("inputzip"),
                                                        tags$p(tags$strong("Avg. Home Price:"), style = "margin:7px 0 0 0"),
                                                        textOutput("avgprice"),
                                                        tags$p(tags$strong("Avg. Home Size:"), style = "margin:7px 0 0 0"),
                                                        textOutput("avgsize"),
                                                        tags$p(tags$strong("Avg. Home Condition:"), style = "margin:7px 0 0 0"),
                                                        textOutput("avgcondition"),
                                                        tags$p(tags$strong("Avg. Home Age:"), style = "margin:7px 0 0 0"),
                                                        textOutput("avgage")
                                                )
                                        ),
                                        
                                        h2("Your Estimated Home Price:", textOutput("estimate"), style = "text-align:center")
                                )
                        )
                )))
        )
))
