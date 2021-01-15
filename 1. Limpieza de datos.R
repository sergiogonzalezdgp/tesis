library(tidyverse)
# LIMPIEZA DE DATOS Y COMBINAR COLUMNAS

# file.choose()  para buscar el directorio del archivo y cargar CSV
dscompleto <- read.csv("/Users/hablandosolo/Documents/Learning Analytics/tesis/log_p.csv", header = TRUE, sep = ",")

#eliminando columnas y filas
log <- select(dscompleto, -Descripcion, -Origen, -IP)
log <- filter(dscompleto, Contexto.del.evento != "189.148.203.31")

#Cambiando nombre Contexto.del.evento
source("/Users/hablandosolo/Documents/Learning Analytics/tesis/cambiar.evento.R")

#Convirtiendo columna Hora a Fecha
library(lubridate)
log$Hora <- as.Date(log$Hora, format="%Y-%m-%d")
log$Hora <- rename(log, Fecha = Hora)



#Crear un objeto solo de estudiantes
estudiantes <- filter(dscompleto, usuario != "Admin" & usuario != "Investigador" & usuario!= "Profesor") 

