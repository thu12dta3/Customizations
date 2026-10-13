# Solução de problemas — LightDM WebKit2

## Tela preta com ponteiro visível

Se o greeter mostra apenas uma tela preta, mas o ponteiro se move ou parece interagir com controles invisíveis, a página pode estar carregando enquanto o WebKitGTK falha ao compor os pixels. Em máquinas NVIDIA, isso pode estar relacionado à composição acelerada ou ao renderer DMABUF. Isso é diferente de uma senha recusada.

Confirme primeiro qual greeter e tema estão efetivamente selecionados:

```bash
systemctl status display-manager --no-pager
lightdm --show-config
grep -nE '^\s*webkit_theme\s*=' /etc/lightdm/lightdm-webkit2-greeter.conf
```

Para verificar se o greeter abriu uma sessão e conferir mensagens do serviço:

```bash
sudo journalctl -b -u lightdm --no-pager
```

Uma linha `pam_unix(lightdm:session): session opened` confirma que a autenticação abriu uma sessão; não confirma que a imagem do greeter foi desenhada corretamente. Evite digitar a senha às cegas. Se ficar preso na tela preta, use `Ctrl`+`Alt`+`F3` para abrir um terminal de texto, entre com seu usuário e siga o rollback abaixo.

## Compatibilidade de renderização NVIDIA

WebKitGTK oferece `WEBKIT_DISABLE_DMABUF_RENDERER=1` para desativar seu renderer DMABUF e usar outro caminho de renderização. O workaround também desativa o modo de composição acelerada com `WEBKIT_DISABLE_COMPOSITING_MODE=1`. O resultado depende da combinação de GPU, driver e WebKitGTK; confirme visualmente no seu computador.

No caso que motivou este guia, `WEBKIT_DISABLE_COMPOSITING_MODE=1` sozinho **não** resolveu a tela preta. O caminho com DMABUF é uma tentativa adicional; não o considere corrigido até confirmar que o greeter foi desenhado depois de um novo início do LightDM.

No clone deste repositório, com Cosmic Login já ativado:

```bash
cd themes/lightdm/cosmic-login
sudo bash scripts/apply-nvidia-render-workaround.sh
```

O script:

- faz backup das configurações atuais e do wrapper em `/var/backups/cosmic-login-webkit-nvidia-*`;
- instala um wrapper que passa as duas variáveis ao greeter WebKit;
- configura `greeter-wrapper` no LightDM e verifica o resultado com o parser do próprio LightDM;
- mantém `lightdm-webkit2-greeter` e `cosmic-login` selecionados;
- não reinicia o serviço nem encerra sua sessão automaticamente.

Salve seu trabalho e reinicie o LightDM para testar o próximo greeter. **Isso encerra a sessão gráfica atual.**

```bash
sudo systemctl restart lightdm
```

## Rollback

Use o caminho de backup impresso pelo script. Isso restaura o estado imediatamente anterior ao workaround e mantém a configuração Cosmic que já estava ativa:

```bash
sudo bash /var/backups/cosmic-login-webkit-nvidia-DATA-HORA-PID/rollback.sh \
  /var/backups/cosmic-login-webkit-nvidia-DATA-HORA-PID
sudo systemctl restart lightdm
```

Se também quiser desfazer a ativação original do Cosmic, use o caminho `cosmic-login-activation-*` criado por `scripts/enable.sh`, conforme as instruções de [instalação](README.md).

## Diagnóstico adicional

Registre a GPU e o driver em uso:

```bash
lspci -k | grep -A4 -Ei 'VGA|3D|Display'
```

Consulte os registros do LightDM sem colar saídas completas em público. Logs gerais podem conter dados privados de outros aplicativos. Se o workaround não corrigir a imagem, restaure-o pelo backup e investigue o driver Xorg/NVIDIA e os erros WebKit antes de tentar outro reinício.

Este ajuste não altera PAM, senhas, autologin, sessão Plasma, SDDM, GRUB ou partições. A referência do WebKitGTK descreve a variável DMABUF como forma de trocar o caminho de renderer: [WebKitGTK 2.41.1](https://planet.webkitgtk.org/2023/05/18/webkitgtk-2-41-1/). Um relato upstream também documenta falhas de composição WebKitGTK em NVIDIA: [WebKit bug 180739](https://bugs.webkit.org/show_bug.cgi?id=180739).
