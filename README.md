# Learning Analytics con R studio 
Este es la documentación del proceso de limpieza y visualización de un conjunto de datos extraídos de Moodle. El conjunto de datos fue obtenido en un lapso de 7 meses de las cuales existen fechas en que no se registraron ingresos al curso. Este conjunto de datos no presenta valores N/A. Los datos presentan datos de fecha, variables cualitativas (categorías) y númericas de Direción IP.

## Procedimiento
* [Comprensión del dominio de la aplicación](#comprensión-del-dominio-de-la-aplicación)
* [Creación del conjunto de datos](#Creación-del-conjunto-de-datos)
* [Limpieza y Pre procesamiento](#limpieza-y-pre-procesamiento)
* [Reducción de datos](#reducción-de-datos)
* [Tarea de minería de datos](#tarea-de-minería-de-datos)
* [Algoritmo de minería de datos](#algoritmo-de-minería-de-datos)
* [Minería de datos](#minería-de-datos)
* [Interpretación de patrones](#interpretación-de-patrones)
* [Consolidación del conocimiento](#consolidación-del-conocimiento)
* [## Referencias](#referencias)

## Comprensión del dominio de la aplicación
El conjunto de datos utilizado contiene un total de 3240 observaciones y 8 variables. Estos corresponden a los registros almacenados por la plataforma Moodle de un curso conformado por 12 estudiantes, el administrador de la plataforma, un profesor y un investigador. El curso pertenece a una universidad del sur de Chile de una carrera de pregrado y fueron capturados entre los meses de abril y agosto del año 2020 en un contexto de aislamiento social y por lo tanto, en una modalidad de clases a distancia con el uso de Learning Managment System (LMS). Se busca identificar grupos relevantes que describan comportamientos de uso de la plataforma institucional como evidencias de las experiencias de aprendizaje en línea de los estudiantes.

### Variables registradas
* Fecha
* Nombre.del.usuario.completo
* Contexto.del.evento
* Componente
* Nombre.evento
* Descripción
* Origen
* Dirección.IP

## Creación del conjunto de datos
La creación del conjunto de datos fue realizada mediante la descarga directa de la plataforma institucional basada en Moodle. Desde su interfaz predeterminada se filtró el curso del periodo antes mencionado y se generó un archivo en formato Comma Separated Values `.csv`. El archivo `log_p.csv` fue pre-procesado en Microsoft Excel y fue exportado en .csv con codificación UTF-8.

## Limpieza y Pre procesamiento 
Para la limpieza y pre procesamiento de los datos se llevaron a cabo las siguientes acciones.
* Combinación de las variables de "Nombre.de.usuario.completo" y "Usuario.afectado"
* La variable "Contexto.del.evento" fue modificado para reducir la extensión de los nombres de cada categoría y se encuentra en el archivo readme/Contexto_del_evento.txt 
* Conversión de la variable "Hora" a formato fecha
* Anonimizado de los participantes
* Codificación de la variable Componentes

## Reducción de datos
Los datos fueron importados a RStudio desde el archivo [log_p.csv](https://github.com/sergiogonzalezdgp/tesis/log_p.csv) , tomando la primera fila como nombres de columna, usando una "," como separador y especificando codificación UTF-8 y fue almacenado en el objeto `dscompleto`. 

### Transformación de los datos
Se utilizaron las siguientes librerías para la transformación de los datos.
```
library(tidyverse)
library(dplyr)
library(lubridate)
```
### Separación del conjunto de datos
Posteriormente se creó un objeto que excluye las variables de "Dirección.IP", "Origen" y "Descripción" y fue almacenado en el objeto `log`. La columna hora fue transformado a formato fecha.
```
log <- dscompleto
log <- rename(log, Fecha = Hora)
log <- select(log, -Descripción, -Origen, -Dirección.IP)
log <-  filter(log, Contexto.del.evento != "189.148.203.31") 
log <- filter(log, Nombre.completo.del.usuario != "-")
log$Fecha <- as.Date(log$Fecha, format="%Y-%m-%d")
```
También, se excluyeron aquellos registros realizados por el administrador, investigador y profesor de la asignatura para crear un segundo objeto llamado `estudiantes`. 
```
estudiantes <- filter(log, Nombre.completo.del.usuario != "Admin" & Nombre.completo.del.usuario != "Investigador" & Nombre.completo.del.usuario != "Profesor") 
estudiantes$Nombre.completo.del.usuario <- as.factor(estudiantes$Nombre.completo.del.usuario ) 
estudiantes$Contexto.del.evento <- as.factor(estudiantes$Contexto.del.evento) 
estudiantes$Componente <- as.factor(estudiantes$Componente)
estudiantes$Nombre.evento <- as.factor(estudiantes$Nombre.evento)
```
### Tablas de frecuencia
Se generaron dos objetos para el conteo total de registros `interacciones_cnt` y el conteo total de los estudiantes `usuarios_cnt`. Ambos fueron transformados a tablas de frecuencia a partir de las fechas en que se generaron los registros en plataforma.
```
#Recuento de interacciones totales
interacciones_cnt <- table(unlist(log$Fecha))
interacciones_cnt <- as.data.frame(interacciones_cnt)
interacciones_cnt <- rename(interacciones_cnt, fecha = Var1, cnt = Freq)
interacciones_cnt$fecha <- as.Date(interacciones_cnt$fecha, format="%Y-%m-%d")

#Recuento de usuarios
usuarios_cnt <- table(unlist(estudiantes$Fecha))
usuarios_cnt <- as.data.frame(usuarios_cnt)
usuarios_cnt$Var1 <- as.character(usuarios_cnt$Var1)
usuarios_cnt <- rename(usuarios_cnt, fecha = Var1, cnt = Freq)
usuarios_cnt$fecha <- as.Date(usuarios_cnt$fecha, format="%Y-%m-%d")
```
### Componentes y Contexto del evento
Para obtener una comparativa de las frecuencias de usuarios totales y estudiantes se combinaron las tablas de frecuencias para crear un nuevo objeto llamado "int_join". Se combinaron hacia la izquierda según la fecha de entrada de los usuarios totales y luego se reemplazaron los valores N/A por 0.
```
int_join <- interacciones_cnt %>% left_join(usuarios_cnt, by = "fecha")
int_join <- rename(int_join, Total = cnt.x)
int_join <- rename(int_join, Participantes = cnt.y)
int_join[is.na(int_join)] <- 0
```
### Tablas de frecuencia
Para poder observar los componentes más utilizados de la plataforma se construye una tabla de contingencia con el recuento de estudiantes que accedieron a los diferentes componentes del sistema y contextos de los eventos.
 
```
UC <- table(estudiantes$Nombre.completo.del.usuario, estudiantes$Componente)
UCE <-  table(estudiantes$Nombre.completo.del.usuario, estudiantes$Contexto.del.evento)
```
## Visualización de los datos
Se carga la librería ggpubr para visualizar diferentes gráficos en un mismo plot. Se utiliza además `ggplot2` que ya ha sido cargado anteriormente con las librerías anteriores.
```
library(ggpubr)
```
### Graficando el acceso al curso
El primer paso fue obtener una imagen global de los accesos al curso a través del tiempo. Para esto se generaron dos gráficas para comparar el comportamiento general de todos los usuarios (registros completos de plataforma) y los estudiantes. 
```
it_g <- ggplot(interacciones_cnt, aes(fecha, cnt)) + geom_line() + scale_x_date('Mes') +
        ylab("Interacciones") + xlab("") + labs(title="Conteo todos los usuarios") +
        theme(plot.title = element_text(hjust = 0.5))
ut_g <- ggplot(usuarios_cnt, aes(fecha, cnt)) + geom_line() + scale_x_date('Mes')  + 
        ylab("Interacciones") + xlab("") + labs(title="Conteo Estudiantes") +
        theme(plot.title = element_text(hjust = 0.5))
figura1 <- ggarrange(it_g, ut_g, ncol = 2, nrow = 1) + theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))
```
![Figura1](img/figura1.jpeg)

Por otra parte, se realiza el mismo procedimiento para generar otro gráfico, esta vez de barras ajustando un degradado según el mínimo y máximo de registros. También se integran en un mismo plot para su comparación.

```
it_b <- ggplot(interacciones_cnt,aes(fecha, cnt, fill = cnt)) + geom_col() + 
        scale_fill_gradient(low = "yellow", high = "red", na.value = NA) +
        ylab("Usuarios totales") + xlab("")
ut_b <- ggplot(usuarios_cnt,aes(fecha, cnt, fill = cnt)) + geom_col() + 
        scale_fill_gradient(low = "yellow", high = "red", na.value = NA) +
        ylab("Participantes") + xlab("")
figura3 <- ggarrange(it_b, ut_b, ncol = 2, nrow = 1) +
          labs(title = "Interacciones a través del tiempo") +
          theme(plot.title = element_text(hjust = 0.5)) +
          theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))
```

![Figura1](img/Figura3.jpeg)

En ambos gráficos se puede observar bajas en la cantidad de registros en los periodos comprendidos entre mayo y junio y otra baja en los meses de agosto. Por otra parte, ambos gráficos muestran un máximo de interacciones en diferentes periodos del año. Con la función `summary()` se reportaron siguientes datos:
```
#Todos los usuarios

fecha                 cnt        
 Min.   :2020-04-05   Min.   :  1.00  
 1st Qu.:2020-05-09   1st Qu.:  4.00  
 Median :2020-06-21   Median : 14.00  
 Mean   :2020-06-21   Mean   : 27.66  
 3rd Qu.:2020-08-03   3rd Qu.: 37.00  
 Max.   :2020-09-25   Max.   :202.00  
```

```
#Estudiantes

fecha                 cnt        
 Min.   :2020-04-13   Min.   :  1.00  
 1st Qu.:2020-05-11   1st Qu.:  3.00  
 Median :2020-06-22   Median :  6.00  
 Mean   :2020-06-20   Mean   : 18.39  
 3rd Qu.:2020-08-02   3rd Qu.: 20.00  
 Max.   :2020-09-23   Max.   :157.00  
```

En los gráficos anteriores aún es complejo comparar ambas frecuencias de acceso a causa de las diferentes escalas. Por lo tanto, se genera un tercer plot en el que se sobreponen ambas gráficas.
```
figura2 <- ggplot(int_join, aes(fecha)) +   
  geom_area(aes(y = Total), color = "blue", alpha=0.5, fill = "blue", linetype = "blank") +
  geom_area(aes(y = Participantes), color = "red", alpha=0.8, fill = "red", linetype = "blank") +
  labs(title = "Comparación de usuarios totales y participantes")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ylab("Interacciones") + xlab("")+
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))
figura2 
```
En color azul se encuentra graficado los registros totales mientras que en color rojo se sobreponen los datos de los estudiantes. Uno de los elementos que sobresalen en este gráfico es la cantidad de usuarios que estaban presentes en plataforma durante el último mes de clases, lo que se mantuvo al excluir al administrador, profesor e investigador. También se observa en el resto del gráfico que durante los meses anteriores a agosto, existen más cantidad registros a causa de la administración, el profesor e investigador. Por otra parte, durante el primer mes hay registros sólo de la administración, profesor e investigador.
![Figura1](img/Figura2.jpeg)

Para obtener una imagen más detallada de este periodo se extraen los datos entre el 02 de agosto y 02 de septiembre y se almacena en el objeto `ago.sep`. Se reemplazan las fechas faltantes entre estas fechas y se reemplazan por cero y posteriormente se grafica.
```
ago.sep <- filter(usuarios_cnt, usuarios_cnt$fecha >= "2020/08/01" & usuarios_cnt$fecha <= "2020/09/02")
ago.sep <- ago.sep %>% complete(fecha = seq.Date(min(fecha), max(fecha), by="day")) 
ago.sep[is.na(ago.sep)] <- 0
ultimomes <- ggplot(ago.sep, aes(fecha, cnt)) + geom_line() + scale_x_date('Mes') +
  ylab("Interacciones") + xlab("") + labs(title="Último mes de clases") +
  theme(plot.title = element_text(hjust = 0.5))
```
![Figura1](img/Figura5.jpeg)

Del total de registros de estudiantes `1748` se calculó la cantidad de usuarios del último mes con la función `sum`.
```
> sum(ago.sep$cnt)
[1] 501
```

### Tabla de frecuencia
Para el análisis de posterior, se generó una tabla de frecuencia a partir de la variable `Contexto.del.evento` y `Nombre.completo.del.usuario` la cual posteriormente fue transformado a una matriz. Además se escalaron los datos para hacer comparables las variablos, procedimiento que consiste en que los datos tengan una media de "0" y una desviación estandar de 1.

```
UCE_escalado = as.data.frame.matrix(scale(UCE)) #Escalar
UCE_escalado
```

## Tarea de minería de datos
Se decide utilizar una tarea de agrupamiento que corresponde a las tareas de tipo descriptiva. La literatura también la describe como un método de análisis multivariante para la representación de relaciones. El agrupamiento tiene como objetivo encontrar grupos o conjuntos de elementos que entre sí sean similares (Hernández et al., 2010). Esto quiere decir que se busca que los elementos que pertenen a un grupo tengan un grado alto de similitud entre sí. En algunos casos se pueden determinar el número de grupos que se desea encontrar y en otros casos esto se puede determinar mediante un algoritmo de agrupamiento según las características de los datos (Hernández et al., 2010).

## Algoritmo de minería de datos

Para determinar la cantidad óptima de clúster existen varios métodos, entre ellos el método del codo, el método de silueta y Gap. En primera instancia, la idea de los métodos de particionamiento como el kmeans, es definir una cantidad de cluster en que la suma total de la variación intra clúster sea minimizada.


<math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
  <mtable displaystyle="true">
    <mlabeledtr>
      <mtd id="mjx-eqn-1">
        <mtext>(1)</mtext>
      </mtd>
      <mtd>
        <mi>m</mi>
        <mi>i</mi>
        <mi>n</mi>
        <mi>i</mi>
        <mi>m</mi>
        <mi>i</mi>
        <mi>z</mi>
        <mi>e</mi>
        <mrow class="MJX-TeXAtom-ORD">
          <mo maxsize="2.470em" minsize="2.470em">(</mo>
        </mrow>
        <munderover>
          <mo>&#x2211;<!-- ∑ --></mo>
          <mrow class="MJX-TeXAtom-ORD">
            <mi>k</mi>
            <mo>=</mo>
            <mn>1</mn>
          </mrow>
          <mi>k</mi>
        </munderover>
        <mi>W</mi>
        <mo stretchy="false">(</mo>
        <msub>
          <mi>C</mi>
          <mi>k</mi>
        </msub>
        <mo stretchy="false">)</mo>
        <mrow class="MJX-TeXAtom-ORD">
          <mo maxsize="2.470em" minsize="2.470em">)</mo>
        </mrow>
      </mtd>
    </mlabeledtr>
  </mtable>
</math>


Con el método del codo, el total de la suma de los cuadrados intra cluster mide lo compacto del cluster, el cual debe ser lo más bajo posible. El metodo de silueta mide la calidad del clustering, determinando qué tan bien se posiciona cada objeto dentro del clúster. El método GAP compara el total de la variación intracluster para diferentes valores de k con los valores esperados bajo una distribución de referencia nula en los datos.

Para determinar la cantidad de cluster se utilizó la  función `fviz_nbclust` del paquete FactoMineR. Esta función permite calcular y graficar los 3 métodos mencionados anteriormente.


El algoritmo utilizado fue el K medias, que es un método de agrupamiento por vecindad, en que los datos con características similares se ubican en el espacio mediante sus centros o prototipos (Hernández et al., 2010). K medias opera directamente en una matriz de datos en busca de similitudes, y necesita un conjunto de posiciones tentativas alrededor de las cuales organizar grupos para el ajuste posterior. 


![Algoritmo K-means](img/kmean.svg)


El algoritmo realiza los siguientes pasos:

* Fijar el número de cluster igual o mayor a 2
* Calcula los centroides de cada cluster
* Asigna sus puntos mas cercanos al centroide
* Recalcula la posición del centroide y repite




## Minería de datos

Se cargó la librería `factoextra` y se ejecutó la función `fviz_nbclust` correspondiente para cada uno de los métodos.


### Cantidad óptima de Cluster para los usuarios
Aunque el método del codo no sugiere claramente un punto de quiebre en la curva,  se podría asumir que desde el cuarto clúster hay un cambio de dirección más claro.
```
set.seed(123)
fviz_nbclust(UCE_escalado, kmeans, method = "wss")
``` 

![Elbow Method](img/elbow.jpeg)
 
Con respecto al método de silueta nos sugiere claramente que un número de 8 cluster es el ideal.
```
set.seed(123)
fviz_nbclust(UCE_escalado, kmeans, method = "sillhoutte")
```

![Silhouette Method](img/silhouette.jpeg)

En el caso del método estadístico Gap, éste indica que estadísticamente el conjunto de datos se puede agrupar de forma óptima en un solo clúster.
```
set.seed(123)
fviz_nbclust(UCE_escalado, kmeans, method = "gap_stat")

```

![Gap Method](img/gap.jpeg)

### Extracción de cluster de usuarios
Debido a que los métodos para determinar la cantidad de clúster óptimos difieren entre sí, se decide graficar la distribución de k=1 hasta k=4. 


![](img/k1k4.jpeg)

* La extracción de K=2 arrojó dos cluster de tamaño 6 y 6 con 20.1% de la suma de los cuadrados internos. 
* La extracción con K=3 arrojó clúster de tamaño 4, 2 y 6 con un 35,7% de la suma de cuadrados internos.
* La extracción con K=4 encontró clúster de tamaño 4, 4, 2 y2 con un 48,1% de la suma de los cuadrados internos.

Con la misma tabla de frecuencias se realizó una segunda extracción de cluster para las actividades y recursos de la plataforma. Para esto, se realizó el mismo procedimiento anterior. En este caso se hizo una rotación de la tabla.

### Cantidad óptima de Cluster para los recursos de plataforma
La tarea de agrupación por vecindad y en este caso el algoritmo kmeans, es muy sensible a los cambios en los datos, por lo que la rotación de la tabla de frecuencias muestra ajustes totalmente diferentes al modelo anterior. El método del codo indica que el número óptimo es de dos clúster.

![](img/elbow2.jpeg)

El método del ancho medio de la silueta tambiñen sugiere un corte de dos clúster.


![](img/silhouette2.jpeg)

El tercer método sugiere que el número óptimo de cluster es de 1.

![](img/gap2.jpeg)

### Extraccion de clúster para recursos de la plataforma



## Interpretación de patrones

## Consolidación del conocimiento


## Referencias
* Datanovia. (2020)K-Means Clustering in R: Algorithm and Practical Examples Datanovia.com https://www.datanovia.com/en/lessons/k-means-clustering-in-r-algorith-and-practical-examples/
* Hernández Orallo, J., Ramírez Quintana, M. J., & Ferri Ramírez, C. (2010). Introducción a la minería de datos. Pearson.
* W.L. Myers and G.P. Patil, Multivariate Methods of Representing Relations 13
in R for Prioritization Purposes, Environmental and Ecological Statistics 6,
DOI 10.1007/978-1-4614-3122-0_2, © Springer Science+Business Media, LLC 2012
