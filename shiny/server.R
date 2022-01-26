library(shiny)


shinyServer(function(input, output) {
  
  output$graf <- renderPlot({
    narisi_graf(input$leto1)
  })
})



narisi_graf <- function(leto1){
    graf <- ggplot(tabela %>% filter(leto == leto1, regija != "SLOVENIJA"))+
      aes(x = regija, y = stevilo.nesrec) +
      geom_col(position = "dodge",fill = "royalblue1") + 
      theme_classic() +
      labs(
        x = "Regija",
        y = "Število nesreč",
        title = leto1
      ) + theme(
        axis.text.x = element_text(angle = 45, vjust = 0.5)
      )
    print(graf)
}
