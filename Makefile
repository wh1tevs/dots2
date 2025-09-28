PKGS = my-core my-dev-meta my-sway

.PHONY: $(PKGS) pkgs-all pkgs-clean tmux test-bootstrap

$(PKGS):
	@cd pkgs/$@ && makepkg -si --needed --noconfirm

pkgs-all: $(PKGS)

pkgs-clean:
	@find pkgs -mindepth 2 -maxdepth 2 -type d \( -name pkg -o -name src \) -exec rm -rf {} +
	@find pkgs -mindepth 2 -maxdepth 2 -type f -name "*.pkg.tar.*" -delete

tmux:
	mkdir -p $(HOME)/.config/tmux/plugins
	git clone https://github.com/tmux-plugins/tpm.git $(HOME)/.config/tmux/plugins/tpm

test-bootstrap: Dockerfile.bootstrap bootstrap.sh
	docker build -f Dockerfile.bootstrap -t dots-bootstrap-test .
	docker run --rm -e BOOTSTRAP_PASSWORD=testpass dots-bootstrap-test bash -lc "printf 'test-host\nEurope/Berlin\ntestuser\n' | /bootstrap.sh"
