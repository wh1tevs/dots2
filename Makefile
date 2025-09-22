PKGS = my-core my-dev-meta my-sway

.PHONY: $(PKGS) pkgs-install pkgs-clean tmux

$(pkgs):
	@cd pkgs/$@ && makepkg -si --noconfirm

pkgs-install: $(PKGS)

tmux:
	mkdir -p $(HOME)/.config/tmux/plugins
	git clone https://github.com/tmux-plugins/tpm.git $(HOME)/.config/tmux/plugins/tpm

