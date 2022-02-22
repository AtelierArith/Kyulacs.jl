.phony : all, build, build-gpu, web, test, test-gpu, clean

DOCKER_IMAGE=kyulacsjl

all: build

build:
	-rm -f Manifest.toml docs/Manifest.toml
	docker build -t ${DOCKER_IMAGE} .
	docker-compose build
	docker-compose run --rm julia julia --project=@. -e 'using Pkg; Pkg.instantiate()'
	docker-compose run --rm julia julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'

build-gpu:
	-rm -f Manifest.toml docs/Manifest.toml
	docker build -t ${DOCKER_IMAGE} -f Dockerfile.gpu .
	docker-compose build
	docker-compose run --rm julia-gpu julia --project=@. -e 'using Pkg; Pkg.instantiate()'
	docker-compose run --rm julia-gpu julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'

# Excecute in docker container
web: docs
	julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); \
		include("docs/make.jl"); \
		using LiveServer; servedocs(host="0.0.0.0"); \
		'

test: build
	docker-compose run --rm julia julia -e 'using Pkg; Pkg.activate("."); Pkg.test()'

test-gpu: build
	docker-compose run --rm julia-gpu julia -e 'using Pkg; Pkg.activate("."); Pkg.test()'

clean:
	docker-compose down
	-find $(CURDIR) -name "*.ipynb" -type f -delete
	-find $(CURDIR) -name "*.html" -type f -delete
	-find $(CURDIR) -name "*.gif" -type f -delete
	-find $(CURDIR) -name "*.ipynb_checkpoints" -type d -exec rm -rf "{}" +
	-rm -f  Manifest.toml docs/Manifest.toml
	-rm -rf docs/build
