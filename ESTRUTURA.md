# Estrutura do Projeto - Space Shooter

## 📁 Organização das Pastas

### **Scripts/**

Local onde ficam todos os scripts do jogo, organizados por funcionalidade.

Estrutura esperada:

```
Scripts/
├── Player/
│   └── Player.gd
├── Enemies/
│   ├── Enemy1.gd
│   ├── Enemy2.gd
│   └── ...
├── Projectiles/
│   └── Projectile.gd
├── UI/
│   └── UIScript.gd
├── GameManager/
│   └── GameManager.gd
└── Utils/
    └── Helper.gd
```

**Responsabilidade**: Conter toda a lógica de programação do jogo em GDScript.

---

### **Scenes/**

Local onde ficam todas as cenas (scenes) do jogo, divididas em dois grandes grupos:

#### **Scenes/game/**

Cenas relacionadas à gameplay (não são UI).

Estrutura esperada:

```
Scenes/game/
├── Player/
│   └── Player.tscn
├── Enemies/
│   ├── Enemy1.tscn
│   ├── Enemy2.tscn
│   └── ...
├── Projectiles/
│   └── Projectile.tscn
├── Upgrades/
│   ├── Upgrade1.tscn
│   ├── Upgrade2.tscn
│   └── ...
├── Obstacles/
│   └── Obstacle.tscn
└── Level/
    └── Level.tscn
```

**Responsabilidade**: Conter as cenas principais do jogo (player, inimigos, projectéis, upgrades, obstáculos, etc).

#### **Scenes/ui/**

Cenas relacionadas à interface do usuário (UI).

Estrutura esperada:

```
Scenes/ui/
├── Menu/
│   ├── MainMenu.tscn
│   └── PauseMenu.tscn
├── HUD/
│   ├── HealthBar.tscn
│   ├── ScoreDisplay.tscn
│   └── ...
├── Buttons/
│   ├── PlayButton.tscn
│   ├── ExitButton.tscn
│   └── ...
├── Dialogs/
│   ├── GameOverDialog.tscn
│   └── ...
└── Settings/
    └── SettingsMenu.tscn
```

**Responsabilidade**: Conter todas as cenas de interface (menus, botões, HUD, diálogos, etc).

---

### **Assets/**

Local onde ficam todos os recursos do jogo.

#### **Assets/sprites/**

Imagens, texturas e sprites do jogo.

**Responsabilidade**: Armazenar todos os arquivos de imagem (PNG, SVG, etc).

#### **Assets/audio/**

Arquivos de áudio do jogo.

**Responsabilidade**: Armazenar todos os arquivos de som (WAV, OGG, MP3, etc).

---

## 📝 Convenções

- **Scripts**: Usar `PascalCase` para nomes de classes (Ex: `Player.gd`, `Enemy1.gd`)
- **Scenes**: Usar `.tscn` como extensão
- **Assets**: Organizar por tipo (sprites, audio)
- **Pastas**: Criar subpastas para melhor organização conforme necessário

## ✅ Checklist para novos componentes

- [ ] Script criado em `Scripts/[Categoria]/`
- [ ] Cena criada em `Scenes/game/[Categoria]/` ou `Scenes/ui/[Categoria]/`
- [ ] Assets (se houver) adicionados em `Assets/`
- [ ] Estrutura de pastas criada corretamente
