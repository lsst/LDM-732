all: scope.png

%.png : %.dot
	dot -Tpng $< -o $@

clean:
	rm *.png || true
