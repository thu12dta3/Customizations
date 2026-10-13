# Cosmic Login · telas de bloqueio Linux

[English](README.md) · [Compatibilidade](docs/COMPATIBILITY.md) · [Testes](docs/TESTING.md) · [Etapas](docs/ROADMAP.md)

Escolha a versão pelo **desktop e bloqueador**, não apenas pela distribuição ou pelo gerenciador de login.

| Ambiente | Pacote | Situação |
| --- | --- | --- |
| KDE Plasma 6 | [Baixar ZIP](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen.zip) | Autenticação nativa testada no Plasma 6.7.5/Garuda. O instalador detecta caminhos de outras distribuições e o formato legado LookAndFeel; esse caminho legado ainda é experimental. |
| Hyprland / Hyprlock | [ZIP experimental](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-hyprlock-experimental.zip) | Sintaxe e tipos básicos validados com Hyprlang; faltam testes reais de compositor e senha. |
| Sway / GTKLock em compositor compatível | [ZIP experimental](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-gtklock-experimental.zip) | CSS, widgets nativos e renderização GTK3 validados; faltam testes reais de bloqueio e senha. |
| GNOME Shell | [ZIP experimental](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-gnome-experimental.zip) | Extensão apenas visual, com proteção para API desconhecida. Sintaxe e ciclo de limpeza testados com mocks; falta sessão GNOME real. |
| XFCE, MATE, Cinnamon, LXQt e outros em **X11** | [ZIP experimental](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreen-x11-experimental.zip) | Alternativa com i3lock-color, integrada manualmente ao desktop. Não é um tema direto dos screensavers nativos e não serve para bloquear Wayland via XWayland. |

[Baixar todos os adaptadores](https://raw.githubusercontent.com/thu12dta3/Customizations/main/downloads/cosmic-lockscreens-all.zip). Cada ZIP traz os arquivos completos, fonte, licença, instruções, instalador e rollback. Consulte o README da pasta extraída.

No clone ou pacote completo, `bash install.sh --detect` mostra seu ambiente sem alterar configurações. A instalação do Plasma exige um teste de autenticação antes da ativação. Os outros instaladores exigem `--allow-experimental` e apenas preparam arquivos e lançadores do usuário; não alteram PAM, atalhos ou serviços de bloqueio automático.

Ainda não é possível anunciar funcionamento em **todos os Linux**: o suporte está sendo ampliado por etapas, e os adaptadores novos precisam passar por autenticação real no ambiente correspondente. Antes de usar qualquer versão experimental em suspensão/bloqueio automático, confirme que senha correta desbloqueia, senha incorreta mantém o bloqueio e todos os monitores estão cobertos.

Para o tema de login LightDM, consulte [`themes/lightdm/cosmic-login/`](themes/lightdm/cosmic-login/). A pasta inclui [diagnóstico e correção de tela preta no NVIDIA/WebKit](themes/lightdm/cosmic-login/TROUBLESHOOTING.pt-BR.md), com backups e rollback.

![Prévia da variante Plasma](themes/plasma/cosmic-lockscreen/preview.png)

As pastas LightDM e SDDM são para **login**; a tela de bloqueio dentro da sessão é outro componente. Código GPL-3.0-or-later, com exceções de arquivos derivados declaradas junto deles; fonte JetBrains Mono sob OFL; fotografia com seus termos originais.
