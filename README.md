# Learning Analytics con R studio 
Este es la documentación del proceso de limpieza y visualización de un conjunto de datos extraídos de Moodle. El conjunto de datos fue obtenido en un lapso de 7 meses. 

## Preparación de los datos 
El archivo "log_p.csv" fue pre-procesado en Microsoft Excel y fue exportado en .csv con codificación UTF-8. Se realizaron las siguientes acciones
* Combinación de las variables de "Nombre.de.usuario.completo" y "Usuario.afectado"
* La variable "Contexto.del.evento" fue modificado para reducir la extensión de los nombres de cada categoría y se encuentra en el archivo readme/Contexto_del_evento.txt 
* Conversión de la variable "Hora" a formato fecha
* Anonimizado de los participantes

## Limpieza de los datos
Los datos fueron importados desde el archivo [log_p.csv](https://github.com/sergiogonzalezdgp/tesis/log_p.csv) , tomando la primera fila como nombres de columna, usando una "," como separador y especificando codificación UTF-8 y fue almacenado en el objeto "dscompleto".

## Transformación de los datos
Se cargaron las siguientes librerías
```
library(tidyverse)
library(dplyr)
library(lubridate)
```
### Separación del conjunto de datos
Posteriormente se creó un objeto que excluye las variables de "Dirección.IP", "Origen" y "Descripción" y fue almacenado en el objeto "log". La columna hora fue transformado a formato fecha.
```
log <- dscompleto
log <- rename(log, Fecha = Hora)
log <- select(log, -Descripción, -Origen, -Dirección.IP)
log <-  filter(log, Contexto.del.evento != "189.148.203.31") 
log <- filter(log, Nombre.completo.del.usuario != "-")
log$Fecha <- as.Date(log$Fecha, format="%Y-%m-%d")
```
También, se excluyeron aquellos registros realizados por el administrador, investigador y profesor de la asignatura para crear un segundo objeto llamado "estudiantes". 
```
estudiantes <- filter(log, Nombre.completo.del.usuario != "Admin" & Nombre.completo.del.usuario != "Investigador" & Nombre.completo.del.usuario != "Profesor") 
estudiantes$Nombre.completo.del.usuario <- as.factor(estudiantes$Nombre.completo.del.usuario ) 
estudiantes$Contexto.del.evento <- as.factor(estudiantes$Contexto.del.evento) 
estudiantes$Componente <- as.factor(estudiantes$Componente)
estudiantes$Nombre.evento <- as.factor(estudiantes$Nombre.evento)
```
### Tablas de frecuencia
Se generaron dos objetos para el conteo total de registros "interacciones_cnt" y el conteo total de los estudiantes "usuarios_cnt". Ambos fueron transformados a tablas de frecuencia a partir de las fechas en que se generaron los registros en plataforma.

### Componentes y Contexto del evento
Para obtener una comparativa de las frecuencias de usuarios totales y estudiantes se combinaron las tablas de frecuencias para crear un nuevo objeto llamado "int_join".

###

##Visualización de los datos