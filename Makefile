PKGS = my-core my-dev-meta my-sway

.PHONY: $(PKGS) pkgs-install pkgs-clean tmux

$(PKGS):
	@cd pkgs/$@ && makepkg -si --needed --noconfirm

pkgs-install: $(PKGS)

tmux:
	mkdir -p $(HOME)/.config/tmux/plugins
	git clone https://github.com/tmux-plugins/tpm.git $(HOME)/.config/tmux/plugins/tpm

