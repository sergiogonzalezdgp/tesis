library(tidyverse)
library(dplyr)
# LIMPIEZA DE DATOS Y COMBINAR COLUMNAS

# file.choose()  para buscar el directorio del archivo y cargar CSV
dscompleto <- read.csv("/Users/hablandosolo/Documents/Learning Analytics/tesis/log_p.csv", header = TRUE, sep = ",", encoding = "UTF-8")

#eliminando columnas y filas
log <- dscompleto
log <- rename(log, Fecha = Hora)
log <- select(log, -Descripción, -Origen, -Dirección.IP)
log <-  filter(log, Contexto.del.evento != "189.148.203.31") 
log <- filter(log, Nombre.completo.del.usuario != "-")

#Convirtiendo columna Hora a Fecha
library(lubridate)

log$Fecha <- as.Date(log$Fecha, format="%Y-%m-%d")

#Crear un objeto solo de estudiantes
estudiantes <- filter(log, Nombre.completo.del.usuario != "Admin" & Nombre.completo.del.usuario != "Investigador" & Nombre.completo.del.usuario != "Profesor") 
#Columnas como factor
estudiantes$Nombre.completo.del.usuario <- as.factor(estudiantes$Nombre.completo.del.usuario ) 
estudiantes$Contexto.del.evento <- as.factor(estudiantes$Contexto.del.evento) 
estudiantes$Componente <- as.factor(estudiantes$Componente)
estudiantes$Nombre.evento <- as.factor(estudiantes$Nombre.evento)

#Recuento de interacciones totales
interacciones_cnt <- table(unlist(log$Fecha))
interacciones_cnt <- as.data.frame(interacciones_cnt)
interacciones_cnt <- rename(interacciones_cnt, fecha = Var1, cnt = Freq)
interacciones_cnt$fecha <- as.Date(interacciones_cnt$fecha, format="%Y-%m-%d")

#Recuento de componentes
#componentes_cnt <- table(unlist(log$Componente))
#componentes_cnt <- as.data.frame(componentes_cnt)
#componentes_cnt$Var1 <- as.character(componentes_cnt$Var1)
#componentes_cnt <- rename(componentes_cnt, componente = Var1, cnt = Freq)
#componentes_cnt = componentes_cnt[-1,]

#Recuento de eventos
#eventos_cnt <- table(unlist(log$Contexto.del.evento))
#eventos_cnt <- as.data.frame(eventos_cnt)
#eventos_cnt$Var1 <- as.character(eventos_cnt$Var1)
#eventos_cnt <- rename(eventos_cnt, evento = Var1, cnt = Freq)

#Recuento de usuarios
usuarios_cnt <- table(unlist(estudiantes$Fecha))
usuarios_cnt <- as.data.frame(usuarios_cnt)
usuarios_cnt$Var1 <- as.character(usuarios_cnt$Var1)
usuarios_cnt <- rename(usuarios_cnt, fecha = Var1, cnt = Freq)
usuarios_cnt$fecha <- as.Date(usuarios_cnt$fecha, format="%Y-%m-%d")

#Combinar interacciones totales y usuarios
int_join <- interacciones_cnt %>% left_join(usuarios_cnt, by = "fecha")
int_join <- rename(int_join, Total = cnt.x)
int_join <- rename(int_join, Participantes = cnt.y)
int_join[is.na(int_join)] <- 0

#Tabla de contingencia USUARIO-COMPONENTE
UC <- table(estudiantes$Nombre.completo.del.usuario, estudiantes$Componente)
UCE <-  table(estudiantes$Nombre.completo.del.usuario, estudiantes$Contexto.del.evento)

tabla_nombre_componente <- ftable(log$Nombre.completo.del.usuario, log$Componente)

#Tabla de contingencia usuarios y fecha
contingencia_usuario_fecha <- table(log$Fecha, log$Nombre.completo.del.usuario)

## TABLA DE CONTEXTO DEL EVENTO
library(readxl)
t_contexto <- read_excel("log_limp2.xlsx")
View(t_contexto)
t_contexto <- rename(t_contexto, Fecha = Hora)
t_contexto <- select(t_contexto, -Descripción, -Origen, -Dirección.IP)
t_contexto <-  filter(t_contexto, Contexto.del.evento != "189.148.203.31") 
t_contexto <- filter(t_contexto, Nombre.completo.del.usuario != "-")
t_contexto <- filter(t_contexto, Nombre.completo.del.usuario != "Administrador pregrado virtual" & Nombre.completo.del.usuario != "Sergio González" & Nombre.completo.del.usuario != "Alan Maldonado M.") 
t_contexto <- table(t_contexto$Contexto.del.evento)
t_contexto = as.data.frame(t_contexto)
t_tabla = as.data.frame(t_tabla)
t_contexto_2 <- t_contexto %>%  left_join(t_tabla, by = "Freq")
t_contexto_2 <- rename(t_contexto_2, antes = Var1.x)
t_contexto_2 <- rename(t_contexto_2, despues = Var1.y)
t_contexto_2 <- rename(t_contexto_2, frecuencia = Freq)
t_contexto_2$frecuencia <- NULL
