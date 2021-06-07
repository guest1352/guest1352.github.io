NAME=$(shell echo $$( echo '$@' | tr '[:lower:]' '[:upper:]'))
DATE=$(shell echo $$( date -I -r src/$(NAME).tex | sed 's/-/ /g'))
all: htmld qemu torrent
htmld:
	@echo "Compiling $(NAME)"
	for i in 1 2; do ( cd src && hevea $(NAME).tex -O -o ../$(NAME)/index.html ); done
	rm -f $(NAME)/*.haux $(NAME)/*.htoc $(NAME)/*.image*
	sed -i "s/DATE/$(DATE)/g;\
		s/index001.png/\/documents\/src\/images\/hellolinuxworld.png/g;\
		s/<\/style>/body { background-image: url('\/documents\/src\/images\/bg.png'); \
		 } \nhtml { cursor: url('\/stuff\/cursor.gif'), auto; height: 100% } \n<\/style>/g" $(NAME)/index.html
qemu:
	@echo "Compiling $(NAME)"
	for i in 1 2; do ( cd src && hevea $(NAME).tex -O -o ../$(NAME)/index.html ); done
	rm -f $(NAME)/*.haux $(NAME)/*.htoc $(NAME)/*.image*
	sed -i "s/DATE/$(DATE)/g;\
		s/<\/style>/body { background-image: url('\/documents\/src\/images\/bg.png'); \
		 } \nhtml { cursor: url('\/stuff\/cursor.gif'), auto; height: 100% } \n<\/style>/g" $(NAME)/index.html
torrent:
	@echo "Compiling $(NAME)"
	for i in 1 2; do ( cd src && hevea $(NAME).tex -O -o ../$(NAME)/index.html ); done
	rm -f $(NAME)/*.haux $(NAME)/*.htoc $(NAME)/*.image*
	sed -i "s/DATE/$(DATE)/g;\
		s/<\/style>/body { background-image: url('\/documents\/src\/images\/bg.png'); \
		 } \nhtml { cursor: url('\/stuff\/cursor.gif'), auto; height: 100% } \n<\/style>/g" $(NAME)/index.html
run:
	firefox .
