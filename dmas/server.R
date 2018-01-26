# server.R

source("helpers.R")
library(shiny)
library(ggplot2)
library(reshape)
library(plotly)

shinyServer(function(input, output, session){
  
  # Variáveis e Constantes
  file <- "scripts/teste.csv" # Define o arquivo de entrada
  
  # Prepara os dados para o plot
  # Retorna os dados normalizados do arquivo
  normalizeData <- function(dataFile){
    dataFile[1] <- dataFile[1]-dataFile[1,1] # Timestamp de 0 a n colunas
    dataFile[c(c(2:7), c(44:47))] <- ((dataFile[c(c(2:7),c(44:47))]/1024)/1024)/1024 # Memória de byte p/ Gb
    dataFile[c(42,43)] <- (dataFile[c(42,43)]/1024)/1024 # Net de bytes p/ mb
    return(dataFile)
  }
  
  # Descobre a unidade de medida do gráfico
  yLabel <- function(option){
    if(is.element(option, c( c(2:7), c(44:47)) ))
      return("Gigabyte")
    else{
      if(is.element(option, c(12:40)))
        return("Percentage")
      else{
        if(is.element(options, c(42:43)))
          return("Megabytes")
        else
          return("qualquer")
      }
        
    }
  }
  
  # Função que lê o arquivo cada vez que ele muda  
  # Reactive for streaming data
  dataFile <- reactivePoll(10, session,
                           checkFunc = function(){
                             if(file.exists(file))
                               file.info(file)$mtime[1]
                             else
                               ""
                           },
                           valueFunc = function(){
                             readFile <- read.csv( file, sep=";", header = TRUE)
                             normalizeData(readFile)
                           }
  )
  
  
  # Gera o gráfico
  # Retorna um gráfico baseado na opção escolhida
  plot <- function(headOptions, inputFile, plotType){
    # Grupo de melt + 0 (Vide README)
    if(plotType == 'm'){
      if(is.element(headOptions, c(c(2:5),8,9,c(12:17))))
      {
        data <- inputFile[c(1, headOptions)]
        yNames = colnames(data)
        if(is.element(headOptions, c(12:17)))
        {
          return(plot_ly(data, x= ~timestamp, y=data[,2], type='scatter' ,mode='lines', name=yNames[2], fill='tozeroy', alpha = 0.3) 
               %>% layout(yaxis=list(rangemode="tozero", title=yLabel(headOptions), range=c(0,100)), 
                          xaxis=list(title="Segundos"), showlegend=T))
        }
        else
        {
          return(plot_ly(data, x= ~timestamp, y=data[,2], type='scatter' ,mode='lines', name=yNames[2], fill='tozeroy', alpha = 0.3) 
                 %>% layout(yaxis=list(rangemode="tozero", title=yLabel(headOptions)), 
                            xaxis=list(title="Segundos"), showlegend=T))
        }
               
      }
      else{
        # Grupo de melt +3*2^x (Vide README)
        if(is.element(headOptions, 14:23))
        {
          data <- inputFile[c(1,headOptions,headOptions+6, headOptions+12, headOptions+18)]
          data <- melt(data, id=1)
          return(plot_ly(data, x= ~timestamp, y= ~value, color = ~variable, type='scatter', mode='lines', fill= 'tozeroy', alpha=0.5) 
                %>% layout(yaxis=list(rangemode="tozero", title=yLabel(headOptions), range=c(0,100)),xaxis=list(title="Segundos")))
        }
        else
        {     # Grupo de melt +1 (Vide README)
          if(is.element(headOptions, c(6)))
          {
            data <- inputFile[c(1, headOptions, headOptions+1)]
            data <- melt(data, id=1)
            print(data)
            return(plot_ly(data, x= ~timestamp, y= ~value, color = ~variable, type='scatter', mode='lines', fill= 'tozeroy', alpha=0.5)
                   %>% layout(yaxis=list(rangemode="tozero", title=yLabel(headOptions)), xaxis=list(title="Segundos")))
          }
        }
      }
    }
    else{
      data <- inputFile[c(1, headOptions)]
      yName <- colnames(data)
      if(is.element(headOptions, 12:49))
        return(plot_ly(data, x= ~timestamp, y=data[,2], type='scatter', mode='lines', name=yName[2], fill='tozeroy', alpha = 0.5)
             %>% layout(yaxis=list(rangemode="tozero", title=yLabel(headOptions), range=c(0,100)), 
                        xaxis=list(title="Segundos"), showlegend=T))
      else
        return(plot_ly(data, x= ~timestamp, y=data[,2], type='scatter', mode='lines', name=yName[2], fill='tozeroy', alpha = 0.5)
               %>% layout(yaxis=list(rangemode="tozero", title=yLabel(headOptions)), 
                          xaxis=list(title="Segundos"), showlegend=T))
    }
}
  
  # Output functions
  output$graphic <-
   
      renderPlotly({
        # Lê o arquivo de entrada caso ele mude
        inputFile <- dataFile()
        
        if(input$plotType == 'm')
          headOptions <- getColumns(inputFile, input$monitorVarsMelt)
        else
          headOptions <- getColumns(inputFile, input$monitorVarsSingle)
        # Gera os gráficos
        if(length(readLines(file)) > 3 && file.exists(file) && 
           ((input$plotType == 'm' && length(input$monitorVarsMelt) > 0) || 
            (input$plotType == 's' && length(input$monitorVarsSingle )> 0))
           )
        {
          listPlot <- vector('list')
          listHeights <- NULL
          i <- 1
          for(var in headOptions){
            listPlot[[i]] <- plot(var, inputFile, input$plotType)
            listHeights[i] <- 0.2
            i <- i+1
          }
          subplot(listPlot, shareX = T, nrows = length(listPlot), titleY = T, heights = listHeights)
        } 
        else
        {
           # Gera um gráfico em branco caso não haja arquivo
           data <- data.frame(x=0,y=0)
           plot_ly(data, x=~x, y=~y, mode='lines') %>% layout(yaxis=list(rangemode="nonnegative"), xaxis=list(rangemode="tozero"))
        }
      })
  
  output$downloadData <- 
      downloadHandler(
        filename = function(){ paste("data", '.zip', sep='')},
        content = function(file){
          sheets <- NULL
          i <- 1
          data <- dataFile()
          
          if(input$plotType == 'm'){
            for(var in input$monitorVarsMelt){
              sheetName <- paste(var,".csv", sep="")
              exportData <- getData(data, input$plotType, var)
              write.csv(exportData, sheetName, row.names = F)
              sheets[i]<- sheetName
              i <- i+1
            }
          }
          else{
            for(var in input$monitorVarsSingle){
              sheetName <- paste(var,".csv", sep="")
              exportData <- getData(data, input$plotType, var)
              write.csv(exportData, sheetName, row.names = F)
              sheets[i]<- sheetName
              i <- i+1
            }
          }
          zip(file, sheets)
      }
    )
  })
