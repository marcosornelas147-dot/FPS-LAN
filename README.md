# FPS LAN
Protótipo 3D FPS para Android com HUD, cenário 3D, mira, disparo, movimento e base de conexão ENet por Wi-Fi.

## APK
O GitHub Actions compila em cada push na branch main. Para iniciar manualmente: Actions → Build FPS LAN Android → Run workflow. Baixe FPS-LAN-APK nos artefatos da execução.

## Multiplayer
A base ENet abre uma sala na porta 24567. Para entrar, edite o IP local em _join_game() no arquivo main.gd. Os dois aparelhos precisam estar na mesma rede Wi-Fi.

## Limitações desta primeira versão
Protótipo inicial: a conexão ENet é iniciada, mas sincronização de jogadores, descoberta automática de salas e combate multiplayer ainda não estão implementados. Os controles touch e o combate precisam de refinamento.
