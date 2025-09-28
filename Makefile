PKGS := $(notdir $(patsubst %/,%,$(wildcard pkgs/*/)))
ARCH_PKGS := $(notdir $(patsubst %/,%,$(wildcard arch/*/)))

$(PKGS):
	@stow --no-folding --dotfiles --target=$(HOME) -d pkgs -R $@

$(ARCH_PKGS):
	@cd arch/$@ && makepkg -si --needed --noconfirm

pkgs-clean:
	@find arch -mindepth 2 -maxdepth 2 -type d \( -name pkg -o -name src \) -exec rm -rf {} +
	@find arch -mindepth 2 -maxdepth 2 -type f -name "*.pkg.tar.*" -delete

tmux-plugins:
	mkdir -p $(HOME)/.config/tmux/plugins
	git clone https://github.com/tmux-plugins/tpm.git $(HOME)/.config/tmux/plugins/tpm

.PHONY: $(PKGS) $(ARCH_PKGS) pkgs-clean tmux-plugins
