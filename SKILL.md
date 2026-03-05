---
name: phia-design-system
description: >
  Design system visual do PhiaUI. SEMPRE consultar antes de criar ou modificar qualquer componente.
  Cobre tipografia, paleta de cores, espaçamento, sombras, ícones, layout, animação,
  acessibilidade, responsividade, agnosticismo, modularidade e extensibilidade.
---

# PhiaUI Design System

Linguagem visual obrigatória para todos os componentes PhiaUI.
Para padrões de **código** (API, cn/1, variants, testes, segurança) → ver `phia-component/SKILL.md`.

---

## 1. Filosofia & Referência

- **shadcn/ui** é a referência primária — consultar via Context7 (`/shadcn-ui/ui`) antes de implementar
- **Tailwind CSS v4** — CSS-first config via `@theme` / `@source` / `@utility` (sem `tailwind.config.js`)
- **OKLCH** — paleta de cores em espaço perceptualmente uniforme (ampla gama, dark mode preciso)
- **Zero libs externas de UI** — sem Heroicons npm, sem Alpine, sem class-variance-authority
- **Semantic tokens sempre** — nunca usar cores Tailwind brutas (`blue-500`) em componentes

---

## 2. Sistema de Cores

### Tokens Semânticos (todos mapeados em `priv/static/theme.css`)

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `background` | oklch(1 0 0) | oklch(0.145 0 0) | Fundo da página |
| `foreground` | oklch(0.145 0 0) | oklch(0.985 0 0) | Texto principal |
| `primary` | oklch(0.205 0 0) | oklch(0.922 0 0) | CTA, botão principal |
| `primary-foreground` | oklch(0.985 0 0) | oklch(0.205 0 0) | Texto sobre primary |
| `secondary` | oklch(0.97 0 0) | oklch(0.269 0 0) | Ações secundárias |
| `muted` | oklch(0.97 0 0) | oklch(0.269 0 0) | Áreas neutras |
| `muted-foreground` | oklch(0.556 0 0) | oklch(0.708 0 0) | Texto de suporte |
| `accent` | oklch(0.97 0 0) | oklch(0.269 0 0) | Hover em menus |
| `destructive` | oklch(0.577 0.245 27.325) | oklch(0.704 0.191 22.216) | Erros, perigo |
| `border` | oklch(0.922 0 0) | oklch(0.269 0 0) | Bordas e divisores |
| `input` | oklch(0.922 0 0) | oklch(0.269 0 0) | Bordas de inputs |
| `ring` | oklch(0.708 0 0) | oklch(0.556 0 0) | Focus ring |
| `card` / `card-foreground` | background / foreground | idem | Superfície de card |
| `popover` / `popover-foreground` | background / foreground | idem | Overlays flutuantes |
| `sidebar` / `sidebar-*` | — | — | Navegação lateral |
| `chart-1` … `chart-5` | oklch variados | oklch variados | Visualizações |

### Presets de Cor (8 temas em `priv/static/themes/`)

`zinc` (padrão), `slate`, `blue`, `rose`, `orange`, `green`, `violet`, `neutral`

Cada preset redefine apenas os tokens `primary` / `primary-foreground` — demais tokens são neutros.

### Modificadores de Opacidade

```heex
<%# hover: reduz opacidade em vez de cor diferente %>
class="bg-primary hover:bg-primary/90"
class="bg-muted hover:bg-muted/80"
class="text-muted-foreground/70"
```

Usar `/80`, `/90`, `/70` para estados de hover/active — **nunca** inventar nova cor.

### Regra de Ouro

```
✅ bg-primary       ✅ bg-destructive     ✅ bg-muted
❌ bg-blue-500      ❌ bg-red-600         ❌ bg-gray-100
```

---

## 3. Tipografia

### Famílias

```css
/* priv/static/theme.css */
--font-sans: ui-sans-serif, system-ui, sans-serif   /* padrão absoluto */
--font-mono: ui-monospace, 'Cascadia Code', monospace /* código, kbd, OTP */
```

Nenhum componente deve importar Google Fonts ou fontes externas.

### Escala de Tamanho (8 níveis)

| Classe | rem | px | Uso típico |
|--------|-----|----|------------|
| `text-xs` | 0.75 | 12 | Badges, labels de campo, metadados |
| `text-sm` | 0.875 | 14 | Corpo padrão, itens de lista, inputs |
| `text-base` | 1 | 16 | Parágrafos, descrições longas |
| `text-lg` | 1.125 | 18 | Subtítulos de seção |
| `text-xl` | 1.25 | 20 | Títulos de card, dialog headings |
| `text-2xl` | 1.5 | 24 | Page headings |
| `text-3xl` | 1.875 | 30 | Hero headings |
| `text-4xl` | 2.25 | 36 | Display / landing titles |

### Pesos

| Classe | Uso |
|--------|-----|
| `font-normal` | Corpo de texto, descrições |
| `font-medium` | Labels, botões, itens de menu |
| `font-semibold` | Títulos de componente, card_title |
| `font-mono` | Código, kbd, OTP inputs, timestamps técnicos |

### Line Height

- `leading-none` (1) — headings display
- `leading-tight` (1.25) — títulos compactos
- `leading-normal` (1.5) — padrão de corpo
- `leading-relaxed` (1.625) — texto longo / prose

---

## 4. Sistema de Espaçamento

Base: **4px** (1 unidade Tailwind = 4px). Todo espaçamento é múltiplo de 4.

### Padding por Tipo de Componente

| Componente | Padrão |
|------------|--------|
| Botões sm | `px-3 py-1.5` (12px / 6px) |
| Botões default | `px-4 py-2` (16px / 8px) |
| Botões lg | `px-8 py-2.5` (32px / 10px) |
| Inputs | `px-3 py-2` (12px / 8px) |
| Cards | `p-6` (24px) |
| Card header/footer | `px-6 py-4` (24px / 16px) |
| Popover / Dropdown | `p-1` (4px) para container, `px-2 py-1.5` para item |
| Dialog | `p-6` corpo, `p-6 pt-0` footer |
| Alert | `p-4` (16px) |
| Badge | `px-2.5 py-0.5` (10px / 2px) |
| Kbd | `px-1.5 py-0.5` (6px / 2px) |
| Tooltip | `px-3 py-1.5` (12px / 6px) |

### Gap Patterns

```heex
<%# Stack vertical padrão %>
class="flex flex-col gap-4"
<%# Inline group de botões %>
class="flex items-center gap-2"
<%# Grid de cards %>
class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
<%# Formulário %>
class="space-y-4"
```

### Margin

- Nunca usar `m-*` em componentes de biblioteca — responsabilidade do consumer
- Exceção: `mt-1.5` para mensagens de erro abaixo de inputs

---

## 5. Raio de Borda

Escala baseada em `--radius: 0.625rem` (10px) definida no tema:

| Classe | Valor | Uso |
|--------|-------|-----|
| `rounded-sm` | calc(var(--radius) - 4px) ≈ 6px | Badges, chips, tooltips |
| `rounded-md` | calc(var(--radius) - 2px) ≈ 8px | **Botões, inputs, selects** (padrão de input) |
| `rounded-lg` | var(--radius) ≈ 10px | **Cards, dialogs, popovers, dropdowns** |
| `rounded-xl` | calc(var(--radius) + 4px) ≈ 14px | Sheets, drawers, painéis grandes |
| `rounded-2xl` | calc(var(--radius) + 8px) ≈ 18px | Modal overlays, hero elements |
| `rounded-full` | 9999px | Avatars, radio buttons, progress circular, dots |

### Regras Práticas

- `rounded-md` → tudo que o usuário digita ou clica (inputs, buttons)
- `rounded-lg` → containers que agrupam conteúdo (cards, dialogs)
- `rounded-full` → elementos circulares por natureza (avatar, badge de status, stepper dot)
- Nunca misturar `rounded` (4px Tailwind padrão) com os tokens semânticos acima

---

## 6. Sistema de Sombras

4 níveis para profundidade visual:

| Classe | Uso |
|--------|-----|
| `shadow-sm` | Botões elevados, inputs com foco suave, cards flat |
| `shadow-md` | Popovers, dropdowns, tooltips |
| `shadow-lg` | Dialogs, drawers, sheets |
| `shadow-xl` | Command palette, modais de máxima prioridade |

```heex
<%# Dropdown menu %>
class="shadow-md rounded-lg border border-border bg-popover"
<%# Dialog %>
class="shadow-lg rounded-lg border border-border bg-background"
<%# Toast / Sonner %>
class="shadow-lg rounded-md border border-border"
```

**Nunca usar `shadow-2xl` ou `drop-shadow` em componentes** — reservado para marketing/landing.

---

## 7. Sistema de Ícones

PhiaUI usa **Heroicons** via o componente nativo `<.icon>` (SVG inline, sem npm).

### Tamanhos

| Tamanho | Classes | Uso |
|---------|---------|-----|
| xs | `h-3 w-3` | Badges, indicadores de status |
| sm | `h-4 w-4` | Padrão de ícone em texto (botões, inputs) |
| default | `h-5 w-5` | Ícones standalone, nav items |
| lg | `h-6 w-6` | Empty states, features highlights |

### Acessibilidade

```heex
<%# Decorativo: aria-hidden obrigatório %>
<.icon name="hero-check" class="h-4 w-4" aria-hidden="true" />

<%# Funcional (sem label de texto): aria-label obrigatório %>
<button aria-label="Fechar diálogo">
  <.icon name="hero-x-mark" class="h-4 w-4" aria-hidden="true" />
</button>

<%# Nunca: ícone funcional sem label %>
<button><.icon name="hero-x-mark" class="h-4 w-4" /></button>
```

### Naming Convention

- Usar `hero-*` (outline, 24px) para ações e navegação
- Usar `hero-*-solid` para estados ativos ou filled indicators
- Usar `hero-*-mini` (20px) raramente — preferir `h-4 w-4` no ícone outline

---

## 8. Animação & Motion

### Durações

| Escala | Duration | Uso |
|--------|----------|-----|
| micro | 100ms | Feedback de hover, color transitions |
| fast | 150ms | Tooltips, badges de estado |
| default | 200ms | Dropdowns, popovers |
| medium | 300ms | Dialogs, drawers, sheets |
| slow | 500ms | Páginas, carousels, onboarding |

**Nunca usar > 500ms** para transições de UI (exceto animações explicitamente decorativas).

### Classes Tailwind de Animação

```heex
<%# Transições de cor/opacidade (micro) %>
class="transition-colors duration-100"
class="transition-opacity duration-150"

<%# Transições de transform (default) %>
class="transition-transform duration-200 ease-out"

<%# Entrada de overlay (medium) %>
class="transition-all duration-300 ease-out data-[state=open]:animate-in data-[state=closed]:animate-out"

<%# Loading states %>
class="animate-spin"    <%# spinner %>
class="animate-pulse"   <%# skeleton %>
class="animate-bounce"  <%# indicador de digitação %>
```

### Easing

- **`ease-out`** → entradas (elemento aparecendo na tela)
- **`ease-in`** → saídas (elemento desaparecendo)
- **`ease-in-out`** → movimentos de reposicionamento
- **`linear`** → apenas `animate-spin`

### prefers-reduced-motion (obrigatório)

```heex
<%# Toda animação de duração > 100ms deve respeitar: %>
class="motion-safe:transition-transform motion-safe:duration-300"

<%# Para skeletons e spinners: usar variante Tailwind %>
class="animate-pulse motion-reduce:animate-none"
```

---

## 9. Layout & Posicionamento

### Padrões Flexbox

```heex
<%# Row com alinhamento central (botão com ícone) %>
class="inline-flex items-center gap-2"

<%# Stack vertical (formulário) %>
class="flex flex-col gap-4"

<%# Row com espaço entre (header de card) %>
class="flex items-center justify-between"

<%# Centralizado absoluto (empty state) %>
class="flex flex-col items-center justify-center text-center gap-4"
```

### Grid Patterns

```heex
<%# Metric grid responsivo %>
class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"

<%# Form de 2 colunas %>
class="grid grid-cols-1 md:grid-cols-2 gap-4"

<%# Layout 70/30 %>
class="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-6"
```

### Z-Index (camadas fixas)

| Camada | z-index | Uso |
|--------|---------|-----|
| Base | 0 | Conteúdo normal |
| Sticky | 10 | `z-10` — headers sticky, sticky columns |
| Dropdown | 50 | `z-50` — popovers, dropdowns, tooltips |
| Overlay | 50 | `z-50` — backdrop de dialog |
| Modal | 50 | `z-50` — dialog, sheet, drawer |
| Toast | 50 | `z-50` — notificações (renderizadas por último no DOM) |

> PhiaUI usa `z-50` como camada única de overlay. A ordem no DOM (renderizado depois) resolve conflitos.
> Nunca usar `z-[9999]` ou valores arbitrários.

---

## 10. Responsividade

### Breakpoints (mobile-first)

| Prefixo | Viewport | Uso principal |
|---------|----------|---------------|
| (sem) | 0px+ | Mobile: base |
| `sm:` | 640px+ | Tablets portrait |
| `md:` | 768px+ | Tablets landscape |
| `lg:` | 1024px+ | Desktops |
| `xl:` | 1280px+ | Desktops grandes |

### Container Queries (Tailwind v4 built-in)

```heex
<%# Preferir container queries para componentes internamente responsivos %>
<div class="@container">
  <div class="grid grid-cols-1 @md:grid-cols-2">...</div>
</div>
```

### Touch Targets

- Mínimo absoluto: `h-10 w-10` (40px × 40px)
- Ideal mobile: `h-11` (44px) para qualquer ação primária
- Itens em lista clicável: `py-3` mínimo (evitar `py-1` em mobile)
- Usar `@media (pointer: coarse)` via Tailwind quando necessário

---

## 11. Modo Escuro

### Mecanismo

```css
/* priv/static/theme.css — troca automática via .dark no <html> */
:root { --background: oklch(1 0 0); }
.dark { --background: oklch(0.145 0 0); }
```

O `ThemeProvider` adiciona/remove `.dark` no `<html>` via `localStorage['phia-mode']`.

### Anti-FOUC

O script de restauração deve ser o **primeiro script** no `<head>`, antes de qualquer CSS:

```html
<script>
  (function(){
    var m = localStorage.getItem('phia-mode');
    if (m === 'dark') document.documentElement.classList.add('dark');
  })();
</script>
```

### Boas Práticas

```heex
<%# Correto: tokens semânticos trocam automaticamente %>
class="bg-background text-foreground border-border"

<%# Evitar: dark: modifier só quando token semântico não existe %>
class="bg-white dark:bg-zinc-900"  <%# ❌ só se não houver token %>
class="bg-background"               <%# ✅ preferir sempre %>
```

---

## 12. Acessibilidade (WCAG 2.2 AA)

> Detalhes de implementação (ARIA roles, focus trap, live regions, keyboard nav) →
> ver `phia-component/SKILL.md` seção "Accessibility Checklist".

### Contraste de Cores (obrigatório)

- Texto normal: mínimo **4.5:1** contra fundo
- Texto grande (≥18pt bold ou ≥24pt): mínimo **3:1**
- Componentes UI (borders de input, ícones funcionais): mínimo **3:1**
- Os tokens OKLCH do PhiaUI foram calibrados para WCAG AA — **não alterar os valores OKLCH**

### Focus Ring (universal)

```heex
<%# Padrão obrigatório em TODO elemento focável %>
class="focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
```

### Reduced Motion (em animações)

```heex
class="transition-transform motion-reduce:transition-none"
class="animate-pulse motion-reduce:animate-none"
```

---

## 13. Agnosticismo

O componente não deve assumir contexto externo nem depender de ordem de filhos.

### Tokens em vez de Cores

```elixir
# ✅ Agnóstico: funciona em qualquer tema
"bg-primary text-primary-foreground"

# ❌ Acoplado a um preset
"bg-blue-600 text-white"
```

### :rest Attrs (transparência total)

```elixir
# Permite data-*, phx-*, hx-*, x-*, qualquer attr HTML válida
attr :rest, :global, doc: "HTML attrs forwarded to root element"
```

### Slots > Props de Conteúdo

```heex
<%# ✅ Agnóstico: consumer decide o conteúdo %>
<.card_header><h2>Título custom</h2></.card_header>

<%# ❌ Acoplado: header só aceita string %>
<.card header="Título" />
```

---

## 14. Modularidade

### Atomic Design Adaptado

| Nível | Exemplos PhiaUI |
|-------|-----------------|
| Átomo | Badge, Separator, Spinner, Kbd, Avatar |
| Molécula | Button (icon+label), Input (field+error), Tooltip (trigger+content) |
| Organismo | Card family, Dialog family, DataGrid, Form |
| Template | Shell, ThemeProvider |

### Famílias Composable

Componentes com estrutura interna devem ser famílias:

```heex
<%# Card family %>
<.card>
  <.card_header>
    <.card_title>Título</.card_title>
    <.card_description>Desc</.card_description>
  </.card_header>
  <.card_content>Conteúdo</.card_content>
  <.card_footer class="justify-end">
    <.button>Ação</.button>
  </.card_footer>
</.card>
```

Cada membro da família: `attr :class, :string, default: nil` + `attr :rest, :global`.

### Sub-componentes Independentes

Cada sub-componente deve funcionar standalone:

```heex
<%# Válido fora do contexto pai %>
<.card_header>
  <.card_title>Só o header</.card_title>
</.card_header>
```

---

## 15. Extensibilidade

### cn/1 Override (último ganha)

```elixir
defp classes(assigns) do
  cn([
    "base-class-1 base-class-2",   # base
    variant_class(assigns.variant), # variant
    size_class(assigns.size),       # size
    assigns.class                   # override do consumer — sempre último
  ])
end
```

### Named Slots com :let Context

```elixir
slot :item, doc: "Cada item da lista" do
  attr :disabled, :boolean, default: false
  attr :value, :string, required: true
end
```

```heex
<.select :let={item}>
  <:item value="a" disabled={true}>Opção A</:item>
</.select>
```

### Tema via CSS Variables

Consumers podem sobrescrever tokens por escopo:

```css
/* Em um componente customizado do consumer */
[data-phia-theme="brand"] {
  --primary: oklch(0.55 0.25 280); /* roxo da marca */
}
```

---

## 16. Estados de Componente

Todo componente interativo deve ter estilo para todos os 6 estados:

| Estado | Classes Tailwind |
|--------|-----------------|
| Default | (base) |
| Hover | `hover:bg-accent hover:text-accent-foreground` |
| Focus | `focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2` |
| Active | `active:scale-95` ou `active:opacity-90` |
| Disabled | `disabled:pointer-events-none disabled:opacity-50` |
| Loading | `cursor-wait` + `animate-spin` no ícone filho |

### Padrão para Botão (referência)

```elixir
defp base_classes do
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium " <>
  "transition-colors duration-100 " <>
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " <>
  "disabled:pointer-events-none disabled:opacity-50"
end
```

---

## 17. Anti-Patterns Visuais

| ❌ Anti-Pattern | ✅ Correto | Razão |
|-----------------|-----------|-------|
| `bg-blue-500` | `bg-primary` | Quebra theming |
| `text-red-600` | `text-destructive` | Quebra theming |
| `bg-white dark:bg-gray-900` | `bg-background` | Duplica lógica do token |
| `z-[9999]` | `z-50` | Z-index arbitrário |
| `duration-700` | `duration-300` (máx dialog) | Animação longa prejudica UX |
| `animate-spin` sem `motion-reduce:` | `animate-spin motion-reduce:animate-none` | Acessibilidade |
| `h-8 w-8` em touch target | `h-10 w-10` mínimo | WCAG 2.2 |
| `rounded` (4px) | `rounded-md` / `rounded-lg` | Inconsistente com tema |
| `shadow-2xl` | `shadow-lg` (máximo) | Escala de profundidade |
| `font-bold` | `font-semibold` | Peso excessivo em UI |
| `leading-loose` | `leading-normal` / `leading-relaxed` | Espaçamento excessivo |
| Gap de `gap-8` em mobile | `gap-4 sm:gap-8` | Layout mobile quebrado |
| Margem em componente | Nenhuma (responsabilidade do consumer) | Acoplamento de layout |
| Fonte externa (Google Fonts) | System font stack | Performance + privacidade |
| SVG de user input direto | Sanitizar antes | Segurança XSS |

---

## Referências Rápidas

- `priv/static/theme.css` — todos os tokens OKLCH com valores
- `priv/static/themes/` — 8 presets de cor
- `lib/phia_ui/class_merger.ex` — cn/1 implementation
- `lib/phia_ui/components/` — componentes existentes como referência
- `phia-component/SKILL.md` — padrões de código (API, testes, segurança)
- Context7 `/shadcn-ui/ui` — referência shadcn/ui atualizada
