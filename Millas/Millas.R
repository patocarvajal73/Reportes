library(shiny)

mpgdata = mtcars
mpgdata$am = factor(mpgdata$am, labels = c("Automatico","Manual"))


# Interfaz de usuarios
ui = fluidPage(

    # Titulo de la app
    headerPanel("Millas"),

    # creamos un sidebar panel para las entradas
    sidebarPanel(
           
  # input 1: selector de la variable a visualizar frente a mpg
    selectInput("var", "variable:",
                choices = c("cilindros" = "cyl",
                            "Transmision" = "am",
                            "Motores" = "gear")),
  
  # Input 2: Checbox para si deben incluir los outliers
    checkboxInput("outliers", "Mostrar los outliers", TRUE)
  
  ),
  
  # el mainPanel visualizara los resultados (salidas)
        mainPanel(
          # output 1: texto formateado de la variable output$texto
          h3(textOutput("texto")),
          
          # output 2: plot de la variable definida contra mpg
          plotOutput("mpgPlot")
        )

    )

# lógica de la parte del servidor
server = function(input,output) {
  
  # Calcular el texto de la fórmula
  # es una expresión reactiva genera 2 variables de salida
  # output$texto y output$mpgPlot
   formulatexto = reactive({
     paste("mpg ~", input$var)
   })
  # output del titulo es la variable output$texto
   output$texto = renderText({
     formulatexto()
   })
   
   # generar el plot de la variable contra mpg
   # excluimos los outliers si se requiere
   
   output$mpgPlot = renderPlot({
     boxplot(as.formula(formulatexto()),
             data = mpgdata,
             outline = input$outliers,
             col = "#75aadb", pch = 19)
   })
   
   
}

# Hay que unir las 2 partes y ejecutarlas
shinyApp(ui=ui, server=server)