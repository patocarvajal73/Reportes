library(shiny)
library(base)
library(DT)
library(DBI)
library(RODBC)
library(RMySQL)
library(lubridate)
library(timechange)
library(ggplot2)
library(dplyr)





con = dbConnect(odbc::odbc(), "CONCURSAL")
Nom_Liq = dbGetQuery(con, "SELECT * FROM reports.v_NominacionesLiquidaciones")

Nom_Liq$fnominacion = ymd_hms(Nom_Liq$fnominacion)
Nom_Liq$fnominacion = as.Date(Nom_Liq$fnominacion, format="%d-%m-%Y")

Nom_Liq = within(Nom_Liq, {est_nominacion = as.factor(est_nominacion)})
Nom_Liq$estado = factor(Nom_Liq$est_nominacion,
                        levels = c("sinRespuesta", "excusaRechazada","excusaAceptada","excusado","pendienteAceptacionExcusa","aceptadaSuperintendencia","aceptada","anulada","pendiente"), 
                        labels = c("Sin Respuesta","Excusa Rechazada","Excusa Aceptada","Excusa Aceptada","Pendiente Aceptacion Excusa","Aceptada","Aceptada","Anulada","Pendiente"))
View(Nom_Liq)


Tabla1 = within(Nom_Liq, {
  est_nominacion = NULL
  region =NULL
  sop_solicitud_procedimiento = NULL})

Tabla1= as.data.frame(Tabla1)



Tabla2 = within(Nom_Liq, {
  deudor_nomina = NULL
  est_nominacion = NULL
  region =NULL
  Anominacion= NULL
  sop_solicitud_procedimiento = NULL})

Tabla2= as.data.frame(Tabla2)

Tabla2= table(Nom_Liq$liq_nomina,Nom_Liq$estado)



ui = fluidPage(headerPanel("Etapa de Nominación"),
    tabsetPanel(
    tabPanel("Resumen de Nominaciones por Liquidador", column(8,dataTableOutput("tbl_2"))),
    tabPanel("Listado de Nominaciones por Liquidador", dataTableOutput("tbl_1"))))

  
server = function(input, output, session) {
  output$tbl_2 = DT::renderDataTable(Tabla2, server = FALSE,
                                     colnames = c('Liquidador', 'Estado', 'Cantidad'),
                                     filter = 'none',
                                     extensions = 'Buttons',
                                     rownames = FALSE,
                                     options = list(ajax = list(
                                       serverSide = TRUE,
                                       processing = TRUE, 
                                       dataType = 'jsonp',
                                       pageLength = 15,
                                       autoWidth = FALSE)))

   output$tbl_1  = (DT::renderDataTable(Tabla1, server = FALSE,
                              colnames = c('Tipo_Deudor','Liquidador','Fecha_Nominación','Estado'),
                              filter = 'none',
                              extensions = 'Buttons',
                              rownames = FALSE,
                              options = list(ajax = list(
                                serverSide = TRUE,
                                processing = TRUE, 
                                dataType = 'jsonp',
                                pageLength = 15,
                                autoWidth = FALSE))))}


# Run the application 
shinyApp(ui = ui, server = server)
