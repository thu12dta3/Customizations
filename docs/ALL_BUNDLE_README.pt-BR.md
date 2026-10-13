# Cosmic Login — pacote completo de telas de bloqueio

Este arquivo contém cinco adaptadores de tela de bloqueio. Escolha pelo desktop, tipo de sessão e bloqueador nativo; não apenas pelo nome da distribuição.

| Ambiente | Pasta | Situação |
| --- | --- | --- |
| KDE Plasma 6 | `themes/plasma/cosmic-lockscreen/` | Autenticação real testada no Garuda / Plasma 6.7.5. Outras versões precisam do próprio teste. |
| Hyprland + Hyprlock | `themes/hyprlock/cosmic-lockscreen/` | Experimental; falta teste real com compositor e PAM. |
| Sway / wlroots compatível + GTKLock | `themes/gtklock/cosmic-lockscreen/` | Experimental; falta teste real de bloqueio e PAM. |
| GNOME Shell | `themes/gnome/cosmic-lockscreen/` | Extensão visual experimental; autenticação continua sendo do GNOME. |
| X11 + i3lock-color | `themes/x11/cosmic-lockscreen/` | Bloqueador alternativo experimental; não use em Wayland/XWayland. |

Leia o README da pasta escolhida antes de instalar. A detecção não muda configurações. Os instaladores experimentais exigem `--allow-experimental` e preparam arquivos do usuário; não alteram PAM, atalhos de bloqueio nem serviços de inatividade. Nenhum deles usa um formulário genérico para capturar senha.

Consulte `docs/COMPATIBILITY.md`, `docs/TESTING.md` e `docs/ROADMAP.md` para limites e etapas. O repositório completo, os temas de login LightDM/SDDM e atualizações estão em [thu12dta3/Customizations](https://github.com/thu12dta3/Customizations).
