library(tidyverse)
library(dplyr)
# LIMPIEZA DE DATOS Y COMBINAR COLUMNAS

# file.choose()  para buscar el directorio del archivo y cargar CSV
dscompleto <- read.csv("/Users/hablandosolo/Documents/Learning Analytics/tesis/log_p.csv", header = TRUE, sep = ",", encoding = "UTF-8")

#eliminando columnas y filas
log <- dscompleto
log <- rename(log, Fecha = Hora)
log <- select(log, -Descripción, -Origen, -Dirección.IP)
log <- filter(log, Contexto.del.evento != "189.148.203.31")


##########
source("/Users/hablandosolo/Documents/Learning Analytics/tesis/.R")

#Convirtiendo columna Hora a Fecha
library(lubridate)

log$Fecha <- as.Date(log$Fecha, format="%Y-%m-%d")

#Recuento de interacciones totales
interacciones_cnt <- table(unlist(log$Fecha))
interacciones_cnt <- as.data.frame(interacciones_cnt)
interacciones_cnt <- rename(interacciones_cnt, fecha = Var1, cnt = Freq)
interacciones_cnt$fecha <- as.Date(interacciones_cnt$fecha, format="%Y-%m-%d")

#Recuento de componentes
componentes_cnt <- table(unlist(log$Componente))
componentes_cnt <- as.data.frame(componentes_cnt)
componentes_cnt$Var1 <- as.character(componentes_cnt$Var1)
componentes_cnt <- rename(componentes_cnt, componente = Var1, cnt = Freq)
componentes_cnt = componentes_cnt[-1,]

#Recuento de eventos
eventos_cnt <- table(unlist(log$Contexto.del.evento))
eventos_cnt <- as.data.frame(eventos_cnt)
eventos_cnt$Var1 <- as.character(eventos_cnt$Var1)
eventos_cnt <- rename(eventos_cnt, evento = Var1, cnt = Freq)





#Tabla de contingencia usuarios y fecha
contingencia_usuario_fecha <- table(log$Fecha, log$Nombre.completo.del.usuario)

#Crear un objeto solo de estudiantes
estudiantes <- filter(log, Nombre.completo.de.usuario != "Admin" & usuario != "Investigador" & usuario!= "Profesor") 

