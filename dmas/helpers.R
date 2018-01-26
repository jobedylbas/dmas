# helpers.R
# Functions that are utils for dmas

# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session.

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# getColumn
# file -> dataframe that was read by read.csv()
# monitorVar -> a string  
# Returns the column number of the variable
# that has been whatching
getColumn <- function(file, monitorVar)
{
  return(which(colnames(file)==monitorVar))
}

# getColumns
# file -> data.frame that was read by read.csv() function
# monitorVar -> list of strings
# Returns the column numbers of the variables
# that has been watching
getColumns <- function(file, monitorVars)
{
  columns <- vector('list')
  i <- 1
  for(var in monitorVars)
  {
    columns[i] <- getColumn(file, var)
    i <- i +1
  }
  return(columns)
}

# getData
# Return the datafram that we are watching
# file -> dataframe with all the data that was read by read.csv() function
# plotType -> single or agreggate
# monitorVar -> Variable that we are monitoring
getData <- function(file, plotType, monitorVar)
{
  if(plotType == 'm')
  {
    # Melting group + 0
    if(is.element(getColumn(file, monitorVar), c(c(2:5),8,9,c(12:17))))
      data <- file[c(1, getColumn(file, monitorVar))]
    else
    {
      # Melting group + 6
      if(is.element(getColumn(file, monitorVar), 14:23))
        data <- file[c(1, getColumn(file, monitorVar), getColumn(file, monitorVar)+6,
                       getColumn(file, monitorVar)+12, getColumn(file, monitorVar)+18)]
      # Melting group + 1
      else
        data <- file[c(1, getColumn(file, monitorVar), getColumn(file, monitorVar)+1)]
    }
  }
  else
    data <- file[c(1, getColumn(file, monitorVar))]
  return(data)
}

# yLabel
# Returns the label of y axis based on which variable has been watching
# monitorVar -> column number that we are monitoring
yScale <- function(monitorVar)
{
  if(is.element(monitorVar, c( c(2:9), c(44:47) ) ))
    return("Gigabyte")
  else{
    if(is.element(monitorVar, c(12:40)))
      return("Percentage")
    else{
      if(is.element(monitorVar, c(42:43)))
        return("Megabytes")
      else
        return("qualquer")
    }
    
  }
}


