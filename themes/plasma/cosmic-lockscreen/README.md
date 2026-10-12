# Cosmic Login — bloqueio do Plasma

Tela de bloqueio para KDE Plasma 6.7, com a mesma composição do Cosmic Login: fotografia original, relógio e data à esquerda, cartão translúcido, foto e nome da conta atual, seta dentro do campo de senha e opções de energia alinhadas ao cartão. A hora e a data usam linhas e alturas próprias. A fonte JetBrains Mono é incluída sob OFL.

O bloqueio mantém a sessão atual. Ele desbloqueia exclusivamente o usuário dessa sessão; os seletores de outras contas pertencem às variantes de login LightDM/SDDM. A senha é entregue a `authenticator.respond()`, API nativa do Plasma. O componente trata prompts PAM, falhas, tentativas posteriores e sucesso.

## Testar e instalar

```bash
/usr/lib/kscreenlocker_greet --testing --shell "$PWD/themes/plasma/cosmic-lockscreen"
```

Esse comando abre uma janela de teste e não bloqueia a sessão. Digite a senha do sistema e confirme que ela fecha por autenticação. Só então execute:

```bash
themes/plasma/cosmic-lockscreen/scripts/install.sh --authentication-tested
```

O Plasma 6.7 carrega o bloqueio pelo pacote `Plasma/Shell`, não pelo tema do SDDM nem pelo antigo campo `Greeter/Theme`. O instalador modifica apenas `LockScreenUi.qml` do pacote de shell padrão e acrescenta os recursos locais em `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen`. Preserva `LockScreen.qml`, o mecanismo de autenticação do KDE e os demais arquivos do desktop. Não encerra a sessão nem a bloqueia automaticamente.

O backup fica em `/var/backups/cosmic-lockscreen-DATA-HORA`. Seu caminho também é registrado em `~/.local/state/cosmic-login/lockscreen-backup.txt`. Para restaurar:

```bash
themes/plasma/cosmic-lockscreen/scripts/rollback.sh /var/backups/cosmic-lockscreen-DATA-HORA
```

Uma atualização de `plasma-workspace` pode restaurar o arquivo original; após uma mudança de versão do Plasma, repita o teste antes de reinstalar. A fotografia continua sob seus termos originais, sem créditos sobrepostos.
