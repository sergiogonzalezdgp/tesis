############################################
####-----------EXPLORAR DATOS----------#####
############################################

source("/Users/hablandosolo/Documents/Learning Analytics/tesis/1.Limpieza_de_datos.R")

#Conteo lineal
library(ggpubr)
it_g <- ggplot(interacciones_cnt, aes(fecha, cnt)) + geom_line() + scale_x_date('Mes') +
        ylab("Interacciones") + xlab("") + labs(title="Conteo todos los usuarios") +
        theme(plot.title = element_text(hjust = 0.5)) +geom_smooth(method = "lm")
ut_g <- ggplot(usuarios_cnt, aes(fecha, cnt)) + geom_line() + scale_x_date('Mes')  + 
        ylab("Interacciones") + xlab("") + labs(title="Conteo Estudiantes") +
        theme(plot.title = element_text(hjust = 0.5))+geom_smooth(method = "lm")
figura1 <- ggarrange(it_g, ut_g, ncol = 2, nrow = 1) + theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))

#Comparar conteos lineales 
figura2 <- ggplot(int_join, aes(fecha)) +   
  geom_area(aes(y = Total), color = "blue", alpha=0.5, fill = "blue", linetype = "blank") +
  geom_area(aes(y = Participantes), color = "red", alpha=0.8, fill = "red", linetype = "blank") +
  labs(title = "Comparación de usuarios totales y participantes")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ylab("Interacciones") + xlab("")+
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"))
figura2 


#Conteo gráfico de barra
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

#Último mes de clases
ultimomes <- ggplot(ago.sep, aes(fecha, cnt)) + geom_line() + scale_x_date('Mes') +
  ylab("Interacciones") + xlab("") + labs(title="Último mes de clases") +
  theme(plot.title = element_text(hjust = 0.5))

#Gráfico de densidad uso de componentes
figura4 <- ggplot(estudiantes, aes(Fecha)) +
      geom_density(aes(fill=factor(Componente)), alpha=0.8, linetype = "blank") + 
      labs(title="Gráfico de densidad", 
      subtitle="Uso de componentes estudiantes",
      x="Meses", y= "Densidad",
      fill="Componentes") +
      theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.margin = unit(c(1, 1, 1, 1), "cm")) 

#Mapa de calor contingencia USUARIO-COMPONENTES
yellow <- colorRampPalette(c("yellow", "deeppink3")) #Creando colores
figura5 <- heatmap(UC, Rowv = NA, Colv = NA, col = yellow(100)) 
figura6 <- heatmap(UCE, Rowv = NA, Colv = NA, col = yellow(100)) 


#Ordenar Tabla Frecuencias de Eventos y graficar
eventos_cnt <- eventos_cnt[order(eventos_cnt$cnt), ] 
dotchart(eventos_cnt$cnt, labels=row.names(eventos_cnt), 
         cex=0.6, xlab="cnt")

#Ordenar Tabla Frecuencias de usuarios y graficar
usuarios_cnt <- usuarios_cnt[order(usuarios_cnt$cnt), ] 
dotchart(usuarios_cnt$cnt, labels=row.names(usuarios_cnt), 
         cex=0.6, xlab="cnt")

#Matriz correlación componentes
pairs(~Archivos enviados+Carpeta+Chat+Cuestionario+Foro+H5P+Recurso+Sistema+Tarea+URL+Usuario, data = states, 
      main ="Scatter plot matrix generated with pairs()")
