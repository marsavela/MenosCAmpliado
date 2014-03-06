###############################################################################
#  Fichero para realizar correctamente la tarea de compilacion, carga y       #
#  edicion de enlaces de las distintas partes del proyecto.                   #
#                         Jose Miguel Benedi, 2012-2013 <jbenedi@dsic.upv.es> #
###############################################################################
CC_OPTIONS = -pedantic
CC_LIBRARY = -lfl
CC_LINKS_FLAGS = $(CC_LIBRARY) $(CC_OPTIONS)
OBJECTS = ./alex.o  ./asin.o ./principal.o 

cmc:	$(OBJECTS)
	gcc -o cmc $(OBJECTS) -L./lib -I./include $(CC_LINKS_FLAGS) -ltds -lgci

principal.o: ./src/principal.c
	gcc -c ./src/principal.c -I./include $(CC_OPTIONS)

asin.o:	asin.c
	gcc -c asin.c -I./include $(CC_OPTIONS)

alex.o:	alex.c asin.c
	gcc -c alex.c -I./include $(CC_OPTIONS)

asin.c:	asin.y
	bison -oasin.c -d asin.y
	mv asin.h ./include	

alex.c:	alex.l 
	flex -oalex.c alex.l
clean:
	rm -f alex.c asin.c ./include/asin.h asin-yac.output 
	rm -f alex.o asin.o lexico.o principal.o *.?~
###############################################################################
