library(shiny)

shinyUI(fluidPage(
  titlePanel(""),
  sidebarLayout(position = "right",
                sidebarPanel(
                  sliderInput(
                    "leto1",
                    label = "Leto:",
                    min = 2007, max = 2020, step = 1,
                    round = FALSE, sep = "", ticks = FALSE,
                    value = 2010
                  ))
                ,
                mainPanel(plotOutput("graf"))),
  uiOutput("izborTabPanel")))