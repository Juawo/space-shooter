### Configurando as Collision Layers (O "Quem sou eu")
No Godot, a Layer define em qual camada o objeto está, e a Mask define o que ele "enxerga" (com o que ele colide).

#### Layer | Nome | Descrição
1 - Player - Apenas o corpo da sua nave.
2 - Enemies - Todos os seus 4 tipos de inimigos.
3 - PlayerProjectiles - Seus tiros.
4 - EnemyProjectiles - Tiros do Enemy 2 e 4.

Configuração de Mask (Quem deve olhar quem):

Player (Hitbox/Area2D): Deve ter a Mask 2 (Enemies) e 4 (EnemyProjectiles).

Enemies: Devem ter a Mask 1 (Player) — para causar dano por contato — e 3 (PlayerProjectiles).

PlayerProjectiles: Devem ter apenas a Mask 2 (Enemies).

### Uso de Groups (O "O que eu sou")
Enquanto as camadas cuidam da física, os Groups facilitam a lógica no código. Você pode usá-los para identificar o objeto dentro da função _on_area_entered.

No Inspetor (aba Node > Groups), adicione as seguintes tags:

"enemy": Coloque nos 4 tipos de inimigos.

"player_bullet": Nos seus tiros.

"enemy_bullet": Nos tiros dos inimigos 2 e 4.