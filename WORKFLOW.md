# Workflow de Versionamento e Colaboração

Este projeto utiliza um fluxo de versionamento baseado em **branches fixas** + **branches de feature**, com o objetivo de manter o código organizado, evitar conflitos desnecessários e garantir que sempre exista uma versão estável do jogo.

---

## 📂 Estrutura de Branches

### **`main`**

- Contém apenas **versões estáveis**
- Código **sempre funcional**
- Representa uma versão **"apresentável"** do projeto
- **Nunca recebe commits diretos**

### **`develop`**

- Branch de **integração**
- Onde as funcionalidades desenvolvidas são **reunidas**
- Pode ficar **temporariamente instável**
- Serve como **"campo de testes"** antes de ir para a `main`
- **Nunca recebe commits diretos**

### **`feature/*`**

- Branches **temporárias**
- Cada feature deve ser desenvolvida em sua **própria branch**
- Sempre criadas a partir da **`develop`**

**Exemplos:**

- `feature/player-movement`
- `feature/enemy-spawner`
- `feature/score-system`
- `feature/menu-ui`

---

## ⚠️ Regras Importantes

- **Não commitar diretamente na `main`**
- **Não commitar diretamente na `develop`**
- **Todo código entra via Pull Request**
- **Cada feature deve ser isolada em sua própria branch**

> **Se essas regras não forem seguidas, o workflow perde o sentido.**

---

## 📋 Passo a Passo do Workflow

### **Atualizar a `develop`**

Antes de criar qualquer feature:

```bash
git checkout develop
git pull origin develop
```

### **Criar uma branch de feature**

```bash
git checkout -b feature/nome-da-feature
```

**Exemplo:**

```bash
git checkout -b feature/player-movement
```

### **Desenvolver a feature**

- Commits **pequenos** e **claros**
- Mensagens de commit **objetivas**

**Exemplo:**

```
Add player movement with touch input
Fix player rotation smoothing
```

### **Enviar a feature para o repositório**

```bash
git push origin feature/nome-da-feature
```

### **Abrir Pull Request**

- **Origem:** `feature/nome-da-feature`
- **Destino:** `develop`
- O outro membro **revisa**
- Após aprovação, a feature é **integrada** na `develop`

### **Testes na `develop`**

Após integrar uma ou mais features:

- **Testar o jogo**
- **Verificar** se sistemas não quebraram
- **Corrigir problemas** antes de levar para a `main`

**Correções devem ser feitas em:**

- `fix/*` ou
- nova `feature/*`

### **Atualizar a `main`**

Quando o conjunto de funcionalidades estiver **estável** e fizer sentido como uma versão:

```bash
git checkout main
git pull origin main
git merge develop
git push origin main
```

**Ou via Pull Request:**

```
develop → main
```

> **Esse passo não é frequente e deve ser feito apenas quando a versão estiver realmente pronta.**

---

## 🔀 Resumo Visual do Fluxo

```
feature/*  →  develop  →  main
```

- **`feature/*`**: desenvolvimento isolado
- **`develop`**: integração e testes
- **`main`**: versão estável

---

## 🎯 Objetivo do Workflow

- Evitar conflitos desnecessários
- Manter sempre uma versão funcional do projeto
- Facilitar o trabalho em dupla
- Simular um fluxo profissional de desenvolvimento
- Permitir erros sem comprometer a versão estável
