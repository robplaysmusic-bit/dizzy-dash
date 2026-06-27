web:
	rm -rf web
	mkdir -p web
	godot --headless --export-release Web web/index.html
	cd web; zip -r web.zip .

serve:
	python3 -m http.server 8080 --bind 127.0.0.1 --directory web

.PHONY: web serve
