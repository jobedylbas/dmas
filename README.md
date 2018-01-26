# dmas
Serviço de monitoramento de recursos computacionais

Requisitos:

  Adicionar o dmon na pasta scripts.

  No R adicionar as seguintes bibliotecas:
    
    - ggplot2 (Para gerar os gráficos)
        install.packages("ggplot2")
        library(ggplot2)

    - shiny (Web application framework for R)
        install.packages("shiny")
        library(shiny)

    - plotly (R graphing library)
        install.packages("plotly")
        library(plotly)

    - reshape (Para remapear os dados)
        install.packages("reshape")
        library(reshape)

Execução no R:
  
    runApp("dmas", launch.browser=T)

Após no terminal executar o pymon.py para gerar os dados:

    $./pymon.py
