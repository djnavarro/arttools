
PKGNAME = arttools
PKGVERS = 0.0.0.9000

all: document build check install site clean

document:
	Rscript -e 'roxygen2::roxygenise()'

build: install_deps
	R CMD build .

check: build
	R CMD check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

install_deps:
	Rscript \
	-e 'if (!requireNamespace("remotes")) install.packages("remotes")' \
	-e 'remotes::install_deps(dependencies = TRUE)'

install: build
	R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

site:
	Rscript -e 'pkgdown::build_site()'

clean:
	@rm -rf $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
