PKGS = my-core my-dev-meta my-sway

.PHONY: $(PKGS) pkgs-install pkgs-clean tmux

$(PKGS):
	@cd pkgs/$@ && makepkg -si --needed --noconfirm

pkgs-install: $(PKGS)

pkgs-clean:
	@find pkgs -mindepth 2 -maxdepth 2 -type d \( -name pkg -o -name src \) -exec rm -rf {} +
	@find pkgs -mindepth 2 -maxdepth 2 -type f -name "*.pkg.tar.*" -delete

tmux:
	mkdir -p $(HOME)/.config/tmux/plugins
	git clone https://github.com/tmux-plugins/tpm.git $(HOME)/.config/tmux/plugins/tpm

