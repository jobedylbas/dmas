# ui.R
source("helpers.R")
library(shiny)
library(ggplot2)
library(reshape)
library(plotly) # Várias dependencias das bibliotecas acima


iFile = read.csv("scripts/teste.csv", sep=";", header=TRUE)
options = colnames(iFile)
options = options[-1] # Retira o timestamp porque não é algo que queremos monitorar


shinyUI(fluidPage(
  # Título da aplicação
  titlePanel(strong("Monitor de sistema")),
  
  # Input
  sidebarLayout(
    sidebarPanel(
      radioButtons("plotType","Plot type", c("melt"="m", "single"="s"), inline=T),
      conditionalPanel( 
        condition = "input.plotType =='m'",
        {
          MonitorOptions = options[-c(23:40)] 
          MonitorOptions = MonitorOptions[-c(6,10,24,26,30,32,34)] # Retira desnecessário
          checkboxGroupInput('monitorVarsMelt', 'Escolha um tipo de monitoramento: ',
                             MonitorOptions, selected = MonitorOptions[1])
        }
      ),
      conditionalPanel( 
        condition = "input.plotType =='s'",
        {
          MonitorOptionsSingle = options
          checkboxGroupInput('monitorVarsSingle', 'Escolha um tipo de monitoramento: ',
                             MonitorOptionsSingle, selected = MonitorOptionsSingle[1])
        }
      )
      
  ),
  mainPanel(
    # Output
    plotlyOutput( outputId ="graphic", height="auto"),
    downloadButton("downloadData", "Download data"),
    actionButton("stopStream", "Stop"),
    actionButton("playStream", "Play")
  ))
))
