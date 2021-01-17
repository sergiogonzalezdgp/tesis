############################################
######### EXPLORAR DATOS ###################
############################################

source("/Users/hablandosolo/Documents/Learning Analytics/tesis/1.Limpieza_de_datos.R")

ggplot(interacciones_cnt,aes(fecha, cnt)) + geom_col()
ggplot(componentes_cnt,aes(cnt, componente)) + geom_col()
