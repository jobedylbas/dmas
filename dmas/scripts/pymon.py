#!/usr/bin/env python3
#-*- coding: utf-8 -*-
# Script para rodar o dmon e exportar
# o arquivo txt para csv e json
import subprocess
import os

csvFilename = "teste.csv" # Arquivo que será exportado
dataFilename = "teste.txt" # Arquivo necessário p/ o dmon executar
jsonFilename = "teste.json" # Arquivo que será exportado
headCsv = "" # Cabeçalho do arquivo csv
nLinesWri = 0

csvFile = open( csvFilename, 'w', 1) # Abre o arquivo csv
jsonFile = open (jsonFilename, 'w', 1) # Abre arquivo json

subprocess.run(['./dmon','start', dataFilename]) # Inicia o dmon



# Pega o primeiro sample de dados p/ escrever o cabeçalho
while len(headCsv) == 0:
    data = str(subprocess.check_output(['./dmon','parse', dataFilename]))
    lines = data.split('\\n') # lista das linhas
    headCsv = lines[0] # Pega o cabeçalho

# Primeira linha tem que ser alterada devido a erros
headCsv = headCsv[2:]
csvFile.write(headCsv + '\n') # Escreve cabeçalho

print("Captando dados e gerando csv...")

# Escreve o primeiro sample de dados no csv
while len(lines) < 4:
	data = str(subprocess.check_output(['./dmon','parse', dataFilename]))
	lines = data.split('\\n') # lista das linhas

for line in lines[3:len(lines)-1]: # (ultima linha contém apenas ' por isso é removida)
    csvFile.write(line + '\n')
    nLinesWri = nLinesWri + 1

lastLine = len(lines)-1 # Ultima linha lida do parse

# Pegar os próximos dados sem escrever o cabeçalho novamente
while nLinesWri < 60:

    # Data recebe o valor do parsing feito pelo dmon
    data = str(subprocess.check_output(['./dmon','parse', dataFilename]))
    lines = data.split('\\n') # lista das linhas

    # Se a ultima linha escrita é diferente do tamanho de data -> data changed
    if(len(lines)-lastLine > 0):
        # Escreve as linhas a partir da última no arquivo csv
        for line in lines[lastLine:len(lines)-1]: # (ultima linha contém apenas ' por isso é removida)
                csvFile.write(line + '\n')
                nLinesWri = nLinesWri + 1
            #else:
                # Exclui linhas passadas
        lastLine = len(lines)-1 # Salva o número da última linha escrita

subprocess.run(['./dmon', 'stop']) # Para o dmon parar
print("Monitor stopped")
csvFile.close() # fecha o arquivo csv
jsonFile.close() # fecha o arquivo json
print("Fim do script")
