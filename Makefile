all: test pex-in-docker

cache:
	# create pycache
	python main.py >/dev/null || true

pex-in-docker:
	docker run --rm -v $(PWD):/x python:3.6-alpine sh -c "apk add --no-cache make && cd /x && make install-dev pex-local"

pex-local: cache
	pex --python=python3 . argcomplete setuptools pystache -e vindaloo.vindaloo:run -o latest/vindaloo.pex --python-shebang='/usr/bin/env python3' --disable-cache

test:
	pipenv run py.test tests

coverage:
	pipenv run py.test --cov=vindaloo --cov-report html tests

clean:
	sudo find . -name '__pycache__' -exec rm -rf {} +;
	sudo find . -name '*.pyc' -exec rm -rf {} +;
	-rm -rf build dist

install-dev:
	pip install argcomplete pex pystache

test-all: clean 3.9-alpine 3.8-alpine 3.7-alpine 3.6-alpine

upload:
	python setup.py sdist bdist_wheel
	python -m twine upload dist/*

%-alpine:
	docker run --rm -v $(PWD):/x python:$@ sh -c "pip install pipenv; cd /x; pipenv lock; pipenv install --dev; pipenv run pytest tests"

.PHONY: all cache pex-local pex-in-docker test coverage clean test-all upload
