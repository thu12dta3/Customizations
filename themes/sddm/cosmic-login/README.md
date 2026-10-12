# Cosmic Login para SDDM

Variante nativa em Qt Quick do Cosmic Login para KDE Plasma 6. Mantém a fotografia original da Via Láctea, o relógio e a data em português, o formulário à esquerda e a paleta Catppuccin Mocha. Não exibe títulos promocionais nem créditos sobre a fotografia.

Com uma conta, o nome e a foto ficam fixos. Com mais contas, o seletor expansível mostra nome e avatar. A senha é entregue diretamente à API oficial do SDDM; a tela não a salva nem transmite por outro canal. A sessão usa a seleção padrão/última do SDDM sem mostrar um seletor de sessão. Reiniciar e desligar ficam alinhados dentro do cartão.

## Instalação

Para fazer o tema aparecer em **Configurações do sistema → Tela de autenticação (SDDM)**, execute `./scripts/install.sh`. O script copia os arquivos para `/usr/share/sddm/themes/cosmic-login`. Ele não troca o gerenciador de login ativo, não altera a configuração global do SDDM e não reinicia serviços.

A instalação disponibiliza o tema ao SDDM. Selecioná-lo nesse painel não altera o login de um sistema que usa LightDM, nem o bloqueio de uma sessão do Plasma. Para Meta+L, use a variante [`../../plasma/cosmic-lockscreen/`](../../plasma/cosmic-lockscreen/). A composição Qt Quick é compartilhada entre as variantes SDDM e Plasma; a prévia é renderizada dessa interface, sem desenho manual dos controles.

O arquivo de fotografia é a imagem original fornecida. A licença GPL-3.0-or-later do código do tema não altera os termos de uso próprios da fotografia.
