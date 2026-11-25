# Neovim no dia a dia

Configuração de Gustavo, preparada em 23/11/2026. O tema padrão é Tomorrow Night, com a paleta da extensão instalada no Zed: fundo `#1e1f21` e texto `#c5c8c6`. O fundo é uniforme entre texto, números de linha e área vazia; os marcadores `~` ficam visíveis. A busca mantém a prévia dos arquivos, sem molduras ou linha divisória abaixo do campo de texto. Os atalhos seguem o mapa JetBrains selecionado no Zed. O Neovim continua tendo modos de edição; os painéis de Git e GitHub têm seus próprios atalhos.

## Instalar a partir deste repositório

Esta configuração é usada com Neovim 0.12.6 no Linux. Tenha Git e zsh instalados; a busca no projeto usa ripgrep (`rg`). Os servidores de linguagem podem exigir ferramentas próprias, como Node.js, Python ou Go.

Em outra máquina, clone os dotfiles em `~/dotfiles` e crie um link para a pasta `nvim/`. Se `~/dotfiles` ou o caminho de configuração do Neovim já existirem, escolha outro destino ou faça backup antes de continuar:

```sh
git clone --branch main https://github.com/GustavoLyra23/vim.git "$HOME/dotfiles"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
ln -s "$HOME/dotfiles/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

Na primeira abertura, o Lazy baixa os plugins e o Mason tenta instalar os servidores ausentes. Esses downloads exigem internet. Use `:Lazy restore` para restaurar as versões de `lazy-lock.json`. Codex e GitHub precisam dos comandos `codex` e `gh` instalados e autenticados para usar suas integrações.

O repositório também inclui configurações de shell, terminal e Zed e os testes citados neste guia. Os comandos acima ativam apenas a configuração do Neovim.

## Começar

Abra um terminal novo ou execute `source ~/.zshrc`. Entre na pasta do projeto antes de abrir o editor, para que a busca, o Git e o Codex usem o diretório correto:

```sh
cd ~/etro/seu-projeto
nvim
# Também pode abrir diretamente um arquivo:
nvim src/arquivo.ts
```

- `i` começa a escrever; `Esc` volta à navegação.
- Em navegação, pressione `Espaço` e espere o menu. `Espaço Espaço` busca os atalhos.
- `Ctrl+S` salva. Para um arquivo novo sem nome, use `:w caminho/do/arquivo` e Enter.
- `Espaço q` sai, com confirmação quando houver alterações sem salvar.
- `Espaço h` ou `:NeovimGuia` abre este guia dentro do editor.
- `Espaço n` abre o histórico de notificações, incluindo erros de plugins e instalações.

O autocomplete aparece enquanto você escreve. `Tab`/`Shift+Tab` ou as setas selecionam; `Enter` aceita a seleção. Sem seleção, Enter insere uma nova linha. `Ctrl+Espaço` abre as sugestões manualmente. `Esc` fecha o menu; outro Esc volta à navegação.

### Entender os comandos

Há três formas de usar o editor:

- No terminal, `nvim arquivo` abre ou cria um arquivo. `nvim` sozinho abre a tela inicial.
- Dentro do Neovim, `i` entra no modo de edição e `Esc` volta ao modo normal, usado para navegar e executar atalhos. Se o menu de autocomplete estiver aberto, pressione Esc novamente.
- No modo normal, `:` abre a linha de comandos. Digite o comando e pressione Enter. Por exemplo, `:w` salva o arquivo.

`Ctrl+S` significa segurar Ctrl e apertar S. Já `Espaço g d` significa apertar Espaço, soltar, apertar g e depois d. Não segure Espaço. As sequências com Espaço funcionam no modo normal. Quando encontrar `<leader>` em uma configuração, ele significa Espaço nesta instalação.

| Comando | O que faz |
| --- | --- |
| `:w` | Salva o arquivo atual |
| `:w nome-do-arquivo` | Dá um nome e salva um arquivo novo |
| `:q` | Fecha a janela atual; avisa se houver alterações sem salvar |
| `:wq` | Salva o arquivo e fecha a janela atual |
| `:q!` | Fecha sem salvar; use quando quiser abandonar as alterações |
| `:NeovimGuia` | Abre este guia |
| `:Mason` | Mostra os servidores de linguagem e suas instalações |
| `:enew` | Cria um buffer vazio |
| `:vsplit arquivo` | Abre um arquivo em um painel à direita |
| `:vnew` | Abre um buffer vazio em um painel à direita |
| `:close` | Fecha o painel atual; mantém a última janela do editor aberta |
| `:TerminalBuffer` | Abre um terminal como outro buffer na janela atual |
| `:Changes` | Abre a revisão das alterações do repositório, incluindo arquivos novos e stage |
| `:OrganizarImports` | Adiciona e limpa imports nas linguagens configuradas |
| `:ls` | Lista os buffers e seus números |
| `:buffer 3` | Abre o buffer de número 3 |

Para treinar, execute `nvim /tmp/treino-neovim.txt` no terminal. Aperte `i`, escreva uma frase e pressione Esc. Digite `:w` e Enter para salvar; depois `:q` e Enter para sair. Abra o mesmo arquivo novamente para conferir o texto salvo.

No trabalho, comece com `Ctrl+E` para escolher um arquivo, `i` para editar e `Ctrl+S` para salvar. Pressione Esc e Espaço quando precisar descobrir uma ação. `Espaço g d` abre o diff; `Espaço g s` prepara o trecho atual para um commit; `Espaço g g` abre o painel de Git. Preparar um trecho, também chamado de *stage*, escolhe o que entrará no próximo commit. O commit é uma etapa separada.

Para IA, `Espaço a n` abre o Codex e `Espaço a r` retoma conversas anteriores. Para GitHub, `Espaço o p` lista os PRs do repositório atual.

## Atalhos

Os atalhos seguem o [mapa JetBrains ativo no Zed](https://github.com/zed-industries/zed/blob/main/assets/keymaps/linux/jetbrains.json). `Ctrl+N` continua criando um buffer, como configurado aqui, e `Ctrl+W` continua sendo o prefixo de navegação entre painéis do Neovim.

Na coluna alternativa, as teclas depois de `Espaço` são uma sequência, em modo de navegação. Por exemplo, `Espaço f f` abre a busca de arquivos.

| Ação | Atalho próximo do Zed | Alternativa |
| --- | --- | --- |
| Abrir arquivo | `Ctrl+E` ou `Ctrl+Shift+N` | `Espaço f f` |
| Novo buffer | `Ctrl+N` | `Espaço b a` |
| Terminal como buffer | `:TerminalBuffer` | `Espaço b t` |
| Escolher buffer aberto | | `Espaço b b` |
| Buscar no arquivo | `Ctrl+F` | `/texto` e Enter |
| Buscar no projeto | `Ctrl+Shift+F` | `Espaço f g` |
| Paleta de comandos | `Ctrl+Shift+A` | `:` seguido do comando e Tab |
| Explorar arquivos | `Alt+1` | `Espaço e` |
| Arquivos recentes | | `Espaço f r` |
| Temas com prévia | `:Temas` | `Espaço f t` |
| Salvar | `Ctrl+S` | `Espaço w` |
| Desfazer / refazer | `Ctrl+Z` / `Ctrl+Shift+Z` | `u` / `Ctrl+R` em navegação |
| Selecionar tudo | `Ctrl+A` | `ggVG` |
| Selecionar por palavra | `Ctrl+Shift+←` / `Ctrl+Shift+→` | |
| Selecionar por caractere ou linha | `Shift+←/→` ou `Shift+↑/↓` | |
| Copiar / recortar seleção | `Ctrl+C` / `Ctrl+X` | `y` / `d` na seleção visual |
| Colar | `Ctrl+V` | `p` ou colagem do terminal |
| Duplicar / apagar linha | `Ctrl+D` / `Ctrl+Y` | `yyp` / `dd` |
| Mover linha | `Alt+Shift+↑` / `Alt+Shift+↓` | |
| Comentar linha ou seleção | `Ctrl+/` | `gcc` na linha; `gc` na seleção |
| Próximo arquivo / anterior | `Ctrl+Tab` / `Ctrl+Shift+Tab` | `Espaço b n` / `Espaço b p` |
| Fechar arquivo | | `Espaço b d` |
| Dividir à direita | `Ctrl+W`, depois `v` | `Espaço b v` |
| Fechar painel | `Shift+Esc` | `Espaço x` ou `:close` |
| Definição | `Ctrl+B` | `Espaço c d` |
| Implementação / definição do tipo | `Ctrl+Alt+B` / `Ctrl+Shift+B` | |
| Voltar / avançar na navegação | `Ctrl+Alt+←` / `Ctrl+Alt+→` | |
| Função anterior / seguinte | `Ctrl+Alt+↑` / `Ctrl+Alt+↓` | |
| Referências | `Alt+F7` ou `Ctrl+Alt+F7` | `Espaço c i` |
| Renomear símbolo | `Shift+F6` | `Espaço c r` |
| Ações de código | `Alt+Enter` | `Espaço c a` |
| Documentação / assinatura | `Ctrl+Q` / `Ctrl+P` | `K` para documentação |
| Formatar | `Ctrl+Alt+L` | `Espaço c f` |
| Organizar imports | `Ctrl+Alt+O` | `Espaço c o` ou `:OrganizarImports` |
| Erros e avisos do arquivo | `Ctrl+Shift+Q` | |
| Próximo erro / anterior | `F2` / `Shift+F2` | `Espaço c e` mostra o erro da linha |
| Todos os diagnósticos | `Alt+6` | |
| Símbolos do arquivo | `Alt+7` ou `Ctrl+F12` | `Espaço c s` |
| Terminal integrado | `Alt+F12` | `Espaço t` |
| Novo terminal como buffer | `Ctrl+Shift+T` | `Espaço b t` |
| Git e commits | `Ctrl+K` ou `Alt+0` | `Espaço g g` |
| Buscar arquivos alterados | | `Espaço g f` |
| Buscar trechos do diff | | `Espaço g F` |
| Todas as alterações do Git | `:Changes` | `Espaço g v` |

Use `v` para selecionar caracteres e `V` para selecionar linhas. A área de transferência depende do suporte do terminal; a colagem do próprio terminal, normalmente `Ctrl+Shift+V`, também funciona.

### Navegar com Ctrl+Alt e as setas

`Ctrl+Alt+↓` vai para a próxima função ou método do arquivo; `Ctrl+Alt+↑` vai para a anterior. Os destinos vêm do servidor de linguagem conectado ao arquivo. Se não houver outra função naquela direção, o editor avisa e mantém o cursor. Use `:checkhealth vim.lsp` para conferir o servidor caso a navegação não encontre símbolos.

`Ctrl+Alt+←` volta à posição anterior do histórico e `Ctrl+Alt+→` avança novamente. Isso inclui os saltos entre funções e as definições abertas em outros arquivos com `Ctrl+B`. Os atalhos funcionam durante a edição; `Ctrl+Alt+L` continua formatando o código.

No seu GNOME, as quatro combinações estão reservadas para trocar de área de trabalho. Para liberá-las, execute uma vez no terminal do sistema:

```sh
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super>Page_Up', '<Super>KP_Prior', '<Super><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Page_Down', '<Super>KP_Next', '<Super><Alt>Right']"
```

Esses comandos mantêm a troca de áreas com `Super+Page Up/Down` e `Super+Alt+←/→`. A mudança no GNOME ficou pendente porque o ambiente da sessão de configuração não conseguiu acessar o D-Bus para gravá-la. Reabra o Neovim para carregar os novos atalhos.

### Seleção com Shift

Segure Ctrl e Shift e aperte ← ou → para selecionar palavras, tanto ao navegar quanto ao escrever. Repita para ampliar a seleção; use a direção contrária para reduzi-la. O movimento segue os limites de palavra do Neovim e pode incluir o espaço entre palavras. Shift com as setas seleciona por caractere ou linha; Shift+Home/End vai até o início ou fim da linha.

Essa seleção entra no modo Select: digitar substitui o trecho selecionado. `Ctrl+C` copia, `Ctrl+X` recorta e `Ctrl+V` substitui pelo conteúdo da área de transferência. Esc cancela a seleção. Para os comandos tradicionais do Vim, como `y`, use a seleção visual com `v` ou `V`, ou pressione `Ctrl+G` para converter a seleção atual em visual.

### Buffers abertos e rascunhos

Um buffer é o conteúdo aberto na memória do editor. Pode ser um arquivo existente ou um rascunho ainda sem nome. A barra superior mostra esses buffers.

A barra usa o mesmo fundo do editor em qualquer tema. O arquivo ativo aparece em negrito; arquivos com alterações sem salvar têm o nome sublinhado.

Os nomes também acompanham o estado no Git: verde para novos, amarelo para modificados ou renomeados e vermelho para removidos ou em conflito. Mudanças ainda sem salvar também recebem a cor de modificação. Colocar um arquivo no stage mantém sua cor; depois do commit, ele volta à cor normal. Os tons seguem o tema escolhido. A atualização ocorre ao salvar, trocar de buffer, voltar do terminal ou retornar ao editor.

- `Ctrl+N` cria um buffer vazio e já entra no modo de escrita. `Espaço b a` faz o mesmo no modo normal.
- `Esc`, depois `Espaço b b`, abre a lista. Digite parte do nome, escolha com as setas e pressione Enter. Buffers sem nome aparecem como `[Scratch]`.
- `Ctrl+Tab` avança e `Ctrl+Shift+Tab` volta entre os buffers. Trocar de buffer mantém as alterações na memória; ainda é preciso salvá-las no disco.
- Para dar um nome ao rascunho, pressione Esc e use `:w caminho/do/arquivo`, seguido de Enter. Depois, `Ctrl+S` salva normalmente.
- `Espaço b d` fecha o buffer atual e pergunta o que fazer se houver alterações sem salvar.

`Espaço b t` ou `:TerminalBuffer` cria um terminal na janela atual e já permite digitar comandos. Ele aparece na barra superior e na lista `Espaço b b`. Cada execução abre um shell novo no diretório atual do Neovim, preservando os outros buffers. Para trocar de buffer, pressione `Ctrl+\`, depois `Ctrl+N`, e use `Ctrl+Tab` ou `Espaço b b`. Ao voltar ao terminal, pressione `i` para digitar. Trocar de buffer mantém o processo; `exit` encerra o shell. O comando nativo equivalente é `:enew | terminal`.

### Arquivos lado a lado

Pressione Esc e depois `Espaço b v`. Isso abre outra janela à direita com o buffer atual. Nela, use `Espaço b b` para escolher um buffer já aberto, `Ctrl+E` para abrir outro arquivo ou `Ctrl+N` para criar um rascunho vazio. Os dois painéis continuam abertos.

Os comandos nativos são `:vsplit` para dividir com o mesmo buffer, `:vsplit caminho/do/arquivo` para abrir outro arquivo à direita e `:vnew` para criar um buffer vazio à direita. Pressione Enter depois do comando. Para mudar o foco, use `Ctrl+W`, solte e aperte a seta na direção do painel desejado.

### Fechar uma tela ou voltar ao código

Um buffer é o conteúdo; uma janela ou painel é o espaço que mostra esse conteúdo. Fechar um painel pode deixar o buffer aberto na barra superior.

| Onde você está | Como sair |
| --- | --- |
| Histórico de notificações da tecla `Espaço n` | `Esc` ou `q` |
| Busca de arquivos, buffers ou temas | `Esc`; se ficar em navegação, pressione Esc novamente |
| Campo de entrada, como renomear um símbolo | `Esc` para sair da digitação, depois `Esc` para cancelar |
| Editando código ou com autocomplete aberto | `Esc` volta à navegação; repita se a primeira tecla só fechar o menu |
| Painel ou popup com foco | Em modo normal, `Espaço x` fecha o painel atual |
| Arquivo ou rascunho na barra superior | `Espaço b d` fecha o buffer e pergunta sobre alterações sem salvar |
| Revisão de changes | `Espaço g q` fecha a revisão inteira |
| Terminal ou conversa do Codex | `Ctrl+\`, depois `Ctrl+N`, sai da digitação; `Ctrl+W` e uma seta muda o foco |
| Neovim inteiro | `Esc`, depois `Espaço q`; há confirmação para alterações sem salvar |

`Espaço x` executa `:confirm close`. Ele mantém os rascunhos em memória e não força o descarte de alterações. Na última janela, o Neovim avisa que não pode fechá-la: use `Espaço b d` para fechar apenas o buffer ou `Espaço q` para sair do editor. Evite `:q!` quando quiser preservar alterações; esse comando força a saída sem salvar.

As janelas flutuantes ficam sem moldura, incluindo histórico, campos de entrada, diagnósticos e popups que definem borda própria. O histórico mostra no cabeçalho as teclas para fechar, e os campos mantêm o nome da ação ao lado da entrada. Reinicie o Neovim para carregar os ajustes.

### Código, terminal e conversa ao mesmo tempo

Abra o arquivo e pressione Esc antes das sequências com Espaço:

1. `Espaço a r` abre o seletor de conversas do Codex à direita. Escolha uma conversa para retomá-la. `Espaço a n` abre o painel de uma conversa nova ou mostra a que já está em execução nesse painel.
2. No painel do Codex, pressione `Ctrl+\`, depois `Ctrl+N`, para sair da digitação no terminal. Isso mantém a conversa aberta.
3. Pressione `Ctrl+W`, solte e aperte `←` para voltar ao código.
4. No código, `Espaço t` abre um terminal de comandos embaixo. O painel de conversa permanece aberto.

Para trocar o foco, saia da digitação com `Ctrl+\`, depois `Ctrl+N`, se estiver em um terminal; use Esc se estiver editando código. Depois use:

| Teclas em sequência | Destino |
| --- | --- |
| `Ctrl+W`, `←` ou `h` | Painel à esquerda |
| `Ctrl+W`, `→` ou `l` | Painel à direita |
| `Ctrl+W`, `↑` ou `k` | Painel acima |
| `Ctrl+W`, `↓` ou `j` | Painel abaixo |
| `Ctrl+W`, `w` | Próximo painel |

Ao chegar ao código, `i` começa a editar. Os terminais do painel normalmente retomam a digitação ao ganhar foco; pressione `i` se ainda estiver em navegação. Dois Esc em menos de 200 ms também saem da digitação nos terminais do Snacks. `Alt+F12` abre ou oculta o terminal de comandos; ocultar mantém o processo em execução.

Se quiser um terminal comum à direita do código, abra a linha de comandos com `:` e execute:

```vim
:botright vnew | terminal
```

Esse comando cria um terminal novo a cada execução. Para encerrá-lo, digite `exit` no shell. As conversas ficam nos painéis do Codex; a lista de conversas anteriores é aberta por `Espaço a r`, e não fica como uma lista lateral permanente do Zed.

### Usar o autocomplete de linguagem

Abra ou salve o arquivo com sua extensão, como `.c`, `.go`, `.ts` ou `.py`, dentro do projeto. Pressione `i` e comece a escrever. O menu sugere funções, variáveis, palavras do arquivo e caminhos. `Ctrl+Espaço` solicita sugestões; Tab ou as setas escolhem uma opção, e Enter aceita. Sem opção selecionada, Enter insere uma linha.

Se o menu não aparecer, `:set filetype?` mostra a linguagem detectada, `:checkhealth vim.lsp` mostra os servidores conectados e `:Mason` mostra as instalações. Um rascunho sem nome pode não ter linguagem definida. O autocomplete de linguagem funciona no buffer de código; o terminal tem a conclusão de comandos do zsh.

### Erros e imports

`Ctrl+Shift+Q` abre os erros e avisos reportados para o arquivo atual, inclusive enquanto você digita. Escolha um item e pressione Enter para ir até a linha. Esc fecha a lista; pressione novamente se ainda estiver no campo de busca. `F2` e `Shift+F2` navegam pelos diagnósticos, e `Alt+Enter` mostra as correções oferecidas para o código. `Alt+6` mostra diagnósticos dos arquivos analisados no projeto.

As mensagens vêm dos servidores de linguagem. Por exemplo, em TypeScript, atribuir uma string a uma variável declarada como `number` aparece nessa lista. O servidor precisa estar conectado e ter terminado de analisar o arquivo; `:checkhealth vim.lsp` ajuda a conferir isso.

O Blink aplica o import fornecido pelo servidor quando você aceita uma sugestão de símbolo externo. Use `Ctrl+Espaço`, escolha a sugestão e pressione Enter. A organização de imports também roda ao salvar com `Ctrl+S` ou `:w`:

| Linguagem | Ao salvar |
| --- | --- |
| JavaScript, TypeScript, JSX e TSX | Vtsls adiciona imports que consegue resolver, remove os não usados e organiza a lista |
| Go | Gopls adiciona imports ausentes e remove os não usados |
| Python | Ruff organiza e remove imports não usados; respeita `noqa` e não aplica fixes classificados como inseguros |

`Ctrl+Alt+O`, `Espaço c o` e `:OrganizarImports` executam a organização sem salvar o arquivo. Nas demais linguagens, esse comando solicita a ação de organizar imports ao servidor, quando disponível. Para Python, a inclusão vem das sugestões de autoimport do Basedpyright; a limpeza ao salvar não adivinha módulos para nomes desconhecidos.

Se quiser salvar um rascunho mantendo os imports ainda sem uso, execute `:noautocmd write`. Uma falha ou demora da ferramenta de imports gera uma notificação e permite salvar o conteúdo. A limpeza usa os plugins Blink/nvim-lspconfig e as ferramentas já instaladas. Referências: [Vtsls](https://github.com/yioneko/vtsls#code-actions), [Gopls](https://go.dev/gopls/editor/vim#imports-and-formatting) e [Ruff](https://docs.astral.sh/ruff/linter/#fixes).

### Ghostty e Alacritty

No Ghostty, as antigas ações de `Ctrl+Z` e `Ctrl+D` impediam desfazer e duplicar no editor. Agora fechar painel usa `Ctrl+Shift+W`, e dividir à direita usa `Ctrl+Shift+D`. Reinicie o terminal para garantir que os novos atalhos foram carregados.

`Ctrl+Shift+←/→` e `Ctrl+Tab`/`Ctrl+Shift+Tab` chegam ao Neovim para selecionar palavras e trocar buffers. Para trocar as abas do próprio Ghostty, use `Ctrl+PageUp/PageDown`.

No Neovim, o Alacritty encaminha `Ctrl+Shift+Q/F/B/T` e `Shift+Esc` ao editor. Na tela normal do shell, `Ctrl+Shift+F/B` continuam abrindo a busca do terminal. Essa distinção usa o modo de tela alternativa do terminal. Combinações com Ctrl e Shift podem chegar como a mesma tecla em outros terminais sem suporte a teclado estendido. Nem todos os atalhos do Zed têm equivalente direto no Neovim.

### Fonte e legibilidade

O terminal desenha as letras do Neovim e do shell. No Alacritty, a fonte usa Cascadia Code Light, peso 300, em 13 pt, com Light Italic para o itálico. O peso define a espessura dos traços e não usa pixels como unidade. O fundo do Alacritty também é `#080808`, com opacidade total. Essas mudanças valem para todo o terminal.

O Fontconfig desta máquina já habilita antialiasing e hinting leve, com suavização em tons de cinza. A nitidez depende também da resolução e da escala do monitor; o resultado precisa ser avaliado na sua tela. Peso e tamanho ficam na seção `[font]` de `~/dotfiles/alacritty/alacritty.toml`. Veja a [configuração de fontes do Alacritty](https://alacritty.org/config-alacritty.html#FONT).

Salve o trabalho e reabra o Alacritty e o Neovim para carregar tudo. No Alacritty, `Ctrl+0` restaura os 13 pt configurados caso você tenha alterado o zoom. O backup anterior está em `~/.config/alacritty/alacritty.toml.before-neovim`.

O Ghostty tem uma configuração separada em `~/dotfiles/ghostty/config.ghostty`, com Cascadia Code Medium em 14 pt. Ajustar essa fonte não muda a aparência do Alacritty.

## Temas e prévia

Para experimentar, pressione Esc e digite `:Temas`, seguido de Enter. O atalho `Espaço f t` abre o mesmo seletor. Digite parte do nome e use as setas para escolher: a prévia aplica as cores ao editor e mostra uma amostra de código C. Enter confirma; dois Esc cancelam e restauram o tema anterior.

A coleção [tinted-nvim](https://github.com/tinted-theming/tinted-nvim) está instalada com 642 temas, além dos dois temas locais. Inclui opções claras e escuras; nem todas são minimalistas. Estes são alguns nomes para começar:

| Preferência | Nomes para digitar no seletor |
| --- | --- |
| Branco pastel da imagem | `pastel-branco` |
| Claros suaves | `base16-catppuccin-latte`, `base16-rose-pine-dawn`, `base16-atelier-cave-light` |
| Claros com poucas cores | `base16-grayscale-light`, `base16-zenbones` |
| Escuros com poucas cores | `base16-grayscale-dark`, `base16-ashes` |
| Escuros pastel | `base16-rose-pine-moon`, `base16-catppuccin-mocha`, `base16-nord` |
| Tomorrow Night do Zed | `tomorrow-zed` |

Para trocar diretamente:

```vim
:colorscheme pastel-branco
:colorscheme tomorrow-zed
```

A escolha vale para a sessão atual. Ao reabrir o Neovim, ele volta a Tomorrow Night. Para mudar o padrão, edite `~/dotfiles/nvim/lua/plugins.lua` e troque o nome em `vim.cmd.colorscheme("tomorrow-zed")` pelo tema escolhido.

O Pastel Branco usa fundo `#fdfcf9`, texto escuro, comentários verdes, palavras-chave lilás, números roxos e macros marrons. Ele está instalado também no Zed. Abra a paleta de comandos com `Ctrl+Shift+A`, procure `theme selector: toggle`, escolha **Pastel Branco** e pressione Enter. Se o nome ainda não aparecer, reabra o Zed. A escolha pelo seletor do Zed é salva nas configurações, conforme a [documentação de temas](https://zed.dev/docs/themes).

O Zed continua com Tomorrow Night selecionado até você trocar pelo seletor. Seus outros temas locais foram preservados. Os dois editores compartilham a paleta do Pastel Branco, mas podem classificar um mesmo trecho de código de formas diferentes. O tema Tomorrow Night do Neovim usa as cores da [extensão Tomorrow do Zed](https://github.com/biaqat/tomorrow-theme-zed), versão 1.2.1 instalada nesta máquina.

## Git: revisar e montar commits por trecho

`Espaço g f` abre a busca de arquivos alterados, incluindo arquivos novos e mudanças no stage, com prévia. `Espaço g F`, com F maiúsculo, busca os trechos do diff dos arquivos rastreados, dentro e fora do stage. Para encontrar um arquivo novo ainda fora do Git, use a busca de arquivos alterados.

Digite para filtrar, escolha com as setas e pressione Enter para abrir o resultado no editor. Na busca de trechos, o cursor vai para a região do diff. Esc fecha a busca; pressione novamente se a primeira tecla só sair da digitação. As listas refletem os arquivos salvos em disco; abrir e navegar na busca preserva os rascunhos e o stage.

Ao parar o cursor por meio segundo, o fim da linha mostra o autor, a data e a mensagem do último commit que alterou aquele trecho. Uma linha ainda não commitada mostra `Alteração local (sem commit)`. Essa indicação vem do histórico do Git e não identifica quem digitou uma alteração ainda sem commit. `Espaço g B`, com B maiúsculo, mostra ou oculta a indicação; `Espaço g b` abre os detalhes.

1. Abra `Espaço g v` (`:Changes`) para revisar o repositório. O painel lateral reúne alterações fora do stage em `Changes` e as preparadas para commit em `Staged changes`, incluindo arquivos novos, removidos e renomeados. Enter abre a comparação do arquivo.
2. No arquivo editável, `]c` e `[c` navegam pelos trechos alterados. `Espaço g p` mostra o trecho atual.
3. Use `Espaço g s` para colocar só esse trecho no stage. Uma seleção com `V`, seguida do mesmo atalho, prepara apenas o intervalo selecionado. `Espaço g u` desfaz o último stage de trecho.
4. Confira `Espaço g D`, com D maiúsculo, para revisar exatamente o que está no stage.
5. Abra `Espaço g g`. No Neogit, `Tab` expande, `s` prepara o item e `u` retira do stage. `c` seguido de `c` abre a mensagem do commit. Digite a mensagem e conclua com `Ctrl+C` duas vezes; `Ctrl+C`, depois `Ctrl+K`, cancela.

No painel do Neogit, `Ctrl+S` apenas atualiza a tela. `?` mostra a ajuda. Push é uma ação separada do commit.

`:Changes` usa o repositório do arquivo atual ou do diretório em que você abriu o Neovim. A lista vem do Git: salve os arquivos que deseja incluir, especialmente os novos. A revisão preserva os rascunhos abertos e não salva nem altera o stage automaticamente. Use `Espaço g q` para fechar a revisão e voltar ao editor. `Espaço g d` continua abrindo o Diffview com suas opções padrão; `Espaço g D` mostra somente o stage.

Outros atalhos:

| Ação | Teclas |
| --- | --- |
| Fechar a visão de diff | `Espaço g q` |
| Histórico do arquivo | `Espaço g h` |
| Histórico do projeto | `Espaço g H` |
| Autor da linha | `Espaço g b` |
| Mostrar / ocultar autor ao lado da linha | `Espaço g B` |

Durante um conflito, abra `Espaço g d` e selecione o arquivo em conflito. O layout mostra as versões e o resultado editável. Revise o resultado, salve e coloque o arquivo resolvido no stage. `g?` mostra os comandos locais do Diffview. Nenhum atalho global descarta alterações automaticamente.

## Conversas de IA

`Espaço a n` abre ou oculta o painel do Codex no projeto atual. O painel usa o CLI e a conta já configurados na máquina. Para começar outra conversa dentro dele, use `/new`.

`Espaço a r` abre `codex resume`, com o seletor das conversas anteriores do diretório. Para procurar também em outros diretórios, execute `codex resume --all` no terminal integrado.

As conversas ficam no histórico do Codex, separadas das threads do Zed. Esta configuração não importa conversas antigas do Zed. O painel serve para conversar e pedir mudanças. As sugestões enquanto você digita vêm dos servidores de linguagem.

## Pull requests e threads do GitHub

O painel usa Octo e o GitHub CLI (`gh`). Verifique a conta no seu terminal:

```sh
gh auth status
# Se a autenticação falhar:
gh auth login
```

Abra o Neovim dentro do repositório que tem o remote do GitHub.

| Ação | Teclas ou comando |
| --- | --- |
| Listar PRs | `Espaço o p` |
| Abrir um PR pelo endereço | `:Octo https://github.com/owner/repo/pull/123` |
| Ações do GitHub | `Espaço o o` |
| Iniciar uma revisão no PR aberto | `Espaço o r` |
| Retomar revisão pendente | `:Octo review resume` |
| Ver threads da revisão | `Espaço o t` |
| Adicionar comentário | `Espaço o c` |
| Enviar a revisão | `:Octo review submit` |

Dentro de um buffer do Octo, Enter mostra ações do contexto. Comentários e textos são editados como buffers; salvar com `:w` ou `Ctrl+S` sincroniza a edição com o GitHub. A revisão tem sua própria etapa de envio. Esses comandos podem publicar conteúdo quando você os executar.

## Linguagens e instalação

Há 27 configurações de servidores de linguagem, além da conexão com o Godot. Quando um servidor já existe no sistema ou nos diretórios do Zed, ele é reutilizado. O Mason tem prioridade quando instala sua própria cópia. Não há duas instâncias de TypeScript configuradas: JavaScript, JSX, TypeScript e TSX usam `vtsls`.

Na primeira abertura interativa, o Mason tenta baixar os servidores ausentes. Nix e Haskell só entram nessa instalação automática quando Cargo e `ghcup`, respectivamente, estão disponíveis. Abra `Espaço c m` (`:Mason`) para acompanhar. `Espaço c l` mostra os clientes e configurações do LSP. A formatação usa os servidores conectados e depende de cada linguagem e projeto.

| Linguagens | Servidores | Situação verificada |
| --- | --- | --- |
| JavaScript, JSX, TypeScript, TSX | vtsls, ESLint | Executáveis disponíveis; autocomplete TypeScript testado |
| Python | basedpyright, Ruff | Executáveis disponíveis; autocomplete Python testado |
| HTML, CSS, SCSS, LESS | HTML, CSS, Emmet | Executáveis do Zed disponíveis |
| Tailwind CSS | tailwindcss | Executável do Zed disponível; depende do projeto |
| JSON, JSONC, YAML | jsonls, yamlls | Executáveis do Zed disponíveis |
| Bash, shell, `.env` | bashls | Executável do Zed disponível; zsh tem diferenças de sintaxe |
| C, C++, Objective-C | clangd | Executável disponível no sistema |
| Dockerfile e Docker Compose | docker_language_server | Executável do Zed disponível |
| Go | gopls | Executável disponível; Go está instalado |
| Rust | rust_analyzer | Executável disponível; projetos precisam do toolchain Rust |
| Lua e anotações Lua | lua_ls | Executável disponível |
| Java | jdtls | Executável disponível; Java está instalado |
| Gradle e Gradle Kotlin | gradle_ls | Executável disponível; atende arquivos de build |
| CMake | neocmake | Executável disponível |
| Terraform e variáveis Terraform | terraformls | Executável disponível |
| TOML | taplo | Executável disponível |
| Markdown e `.txt` | marksman | Executável disponível |
| SQL | sqlls | Executável disponível; schemas dependem da conexão configurada no projeto |
| Zig | zls | Executável disponível; depende da versão do Zig do projeto |
| Nix | nil_ls | Mason precisa de Cargo, ausente na preparação; também aceita `nil` já instalado |
| Odin | ols | Executável disponível; biblioteca padrão depende da instalação do Odin |
| Haskell, Literate Haskell e Cabal | hls | Mason precisa de `ghcup`, ausente; GHC/HLS devem ser compatíveis |
| GDScript | servidor do Godot | Requer o projeto aberto no Godot, em `127.0.0.1:6005` |

Alex, GDShader, arquivos de recursos do Godot, properties e arquivos Git têm sugestões de palavras/caminhos; esta configuração não atribui a eles um servidor semântico específico. O destaque de sintaxe usa o runtime do Neovim e os tokens fornecidos pelos LSPs, quando disponíveis.

Na preparação inicial, a rede impediu parte dos downloads. Na conferência posterior, só `hls` e `nil_ls` continuavam sem executáveis disponíveis. A presença do executável não confirma o funcionamento em todos os projetos; confira o servidor conectado com `:checkhealth vim.lsp`. A autenticação do `gh` ainda precisa ser conferida no terminal normal antes do uso online.

## Arquivos e manutenção

As configurações ficam em `~/.config/nvim`, um link para `~/dotfiles/nvim`. No editor, `:e $MYVIMRC` abre o arquivo principal. Para ajustar o autocomplete, use `:e ~/.config/nvim/lua/plugins.lua` e procure `blink.cmp`. Salve com `Ctrl+S` e reabra o Neovim para carregar as mudanças.

| Caminho | Função |
| --- | --- |
| `~/dotfiles/.zshrc` | Adiciona `/opt/nvim-linux-x86_64/bin` ao PATH |
| `~/dotfiles/nvim/init.lua` | Opções do editor e início do carregamento |
| `~/dotfiles/nvim/lua/plugins.lua` | Interface, autocomplete, Git e GitHub |
| `~/dotfiles/nvim/lua/languages.lua` | Servidores de linguagem |
| `~/dotfiles/nvim/lua/keymaps.lua` | Atalhos e painéis do Codex |
| `~/dotfiles/nvim/lua/bufferbar.lua` | Cores dos arquivos na barra conforme o Git, preservando o fundo do tema |
| `~/dotfiles/nvim/colors/tomorrow-zed.lua` | Tomorrow Night baseado na paleta do Zed |
| `~/dotfiles/nvim/colors/pastel-branco.lua` | Tema claro personalizado do Neovim |
| `~/dotfiles/nvim/examples/theme-preview.c` | Código exibido na prévia de temas |
| `~/dotfiles/zed/themes/pastel-branco.json` | Tema claro do Zed, ligado a `~/.config/zed/themes/pastel-branco.json` |
| `~/dotfiles/nvim/lazy-lock.json` | Versões dos plugins |
| `~/.config/nvim` | Link para `~/dotfiles/nvim` |
| `~/dotfiles/ghostty/config.ghostty` | Configuração do Ghostty, ligada a `~/.config/ghostty/config.ghostty` |
| `~/.config/ghostty/config.ghostty.before-neovim` | Backup original do Ghostty |
| `~/dotfiles/alacritty/alacritty.toml` | Fonte e cores do Alacritty, ligado a `~/.config/alacritty/alacritty.toml` |
| `~/.config/alacritty/alacritty.toml.before-neovim` | Backup do Alacritty antes do ajuste de fonte e fundo |
| `~/.local/share/nvim/lazy` | Plugins instalados |
| `~/.local/share/nvim/mason` | Servidores instalados pelo Mason |
| `~/Documentos/work/Ferramentas/Neovim.md` | Cópia deste guia no Obsidian |

`:Lazy` abre o gerenciador de plugins. `:Lazy restore` restaura as versões do lockfile; atualizar plugins altera esse arquivo. `:Mason` gerencia servidores e mostra falhas de instalação. Servidores reaproveitados do Zed não aparecem como instalados no Mason. Se remover o Zed ou seus caches, instale os substitutos pelo Mason.

### Mudar opções e atalhos por conta própria

Use `:e $MYVIMRC` para abrir `init.lua`. As opções gerais usam `vim.opt`; por exemplo, `vim.opt.wrap = true` quebra visualmente linhas longas. Procure a opção existente e altere seu valor. Salve com `Ctrl+S` e reabra o Neovim.

Os atalhos ficam em `:e ~/.config/nvim/lua/keymaps.lua`. Para descobrir quem definiu uma combinação, execute `:verbose nmap <C-M-l>`; troque `nmap` por `imap` para conferir o modo de edição. `Espaço Espaço` também permite procurar atalhos pela descrição.

Um exemplo usando o histórico visual já instalado:

```lua
vim.keymap.set("n", "<leader>u", function()
  Snacks.picker.undo()
end, { desc = "Historico de edicao", silent = true })
```

Coloque esse exemplo antes do `return M` no fim de `keymaps.lua`. `n` significa modo normal; `i`, modo de edição. `<leader>` é Espaço, `<C-...>` é Ctrl, `<M-...>` é Alt e `<S-...>` é Shift. Se o atalho já existir, edite a definição correspondente para evitar duplicação. O exemplo acima não foi adicionado aos atalhos.

### Adicionar um plugin pelo Lazy

1. Abra o README do plugin e confira seus requisitos e o exemplo para `lazy.nvim`.
2. Execute `:e ~/.config/nvim/lua/plugins.lua`.
3. Dentro do `return { ... }` existente, antes do último `}`, acrescente o bloco do plugin. Mantenha a vírgula entre os blocos.

Por exemplo, para instalar o [Grug Far](https://github.com/MagicDuck/grug-far.nvim), que busca e substitui texto com prévia, adicione somente este bloco:

```lua
{
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = {},
},
```

O primeiro campo identifica o repositório no GitHub. `cmd` carrega o plugin quando você executa aquele comando; `opts` contém as opções passadas à função `setup` do plugin. Dependências declaradas no README entram no campo `dependencies`. Esses campos estão descritos na [documentação do Lazy](https://lazy.folke.io/spec).

4. Salve e reabra o Neovim para que o Lazy leia a nova configuração. Ele pode iniciar a instalação dos plugins ausentes; se precisar, execute `:Lazy install`.
5. Espere a instalação terminar e execute `:GrugFar` para abrir o exemplo. `:Lazy` mostra o estado da instalação, e `:checkhealth grug-far` ajuda a investigar erros.

O Grug Far é apenas um exemplo deste guia e não está instalado. Evite substituir o arquivo inteiro pelo exemplo de instalação de outro projeto: sua lista de plugins já existe aqui.

Para atualizar plugins, use `:Lazy update`. `:Lazy sync` combina instalação, remoção de plugins fora da configuração e atualização. Para remover um plugin, apague seu bloco e os atalhos associados, salve, reabra o editor e execute `:Lazy clean`. O arquivo `lazy-lock.json` registra as versões instaladas. Referência: [comandos do Lazy](https://lazy.folke.io/usage).

Se uma alteração quebrar a inicialização, abra o arquivo pelo terminal com `nvim --clean ~/.config/nvim/lua/plugins.lua` e corrija ou remova o bloco que acabou de adicionar. `:messages` mostra erros de carregamento; `:checkhealth` verifica dependências. No terminal, `git -C ~/dotfiles diff -- nvim` mostra o que mudou na configuração.

Para abrir temporariamente sem esta configuração, use `nvim --clean`. Para desativá-la, renomeie o link `~/.config/nvim`; os arquivos em `~/dotfiles/nvim` permanecem. Para restaurar o Ghostty, remova apenas o link de configuração e copie o backup de volta para `~/.config/ghostty/config.ghostty`.

Para restaurar o Alacritty, remova apenas o link `~/.config/alacritty/alacritty.toml` e copie `alacritty.toml.before-neovim` para esse mesmo caminho.

## Verificações

O teste de integração usa arquivos e commits descartáveis em `/tmp`. Ele não faz commits nos projetos, não envia prompts de IA e não publica comentários no GitHub.

Os testes específicos do terminal e da interface Git conferem a preservação de rascunhos, o shell em execução, as cores antes e depois do stage/commit, renomes, remoções, conflitos e autoria da linha. Na validação desses ajustes, a suíte geral parou no teste de copiar com Ctrl+C em modo headless; o mesmo resultado ocorreu com a configuração anterior. A verificação passou a exigir um resultado booleano verdadeiro, evitando que uma resposta nula do processo fosse tratada como sucesso. O comportamento físico de Ctrl+C no Alacritty não foi conferido nessa investigação.

O teste de janelas verifica o histórico sem borda e seu fechamento por Esc, q e Espaço x, bordas explícitas de plugins, diagnósticos, campos de entrada com rótulo visível, popup local do Octo e buscas nos temas claro e escuro. Também confere a divisão vertical e o fechamento de um painel com dois rascunhos preservados.

O teste de imports usa servidores reais de TypeScript, Go e Python. Verifica a abertura de um erro de tipo com Ctrl+Shift+Q, o autoimport ao aceitar uma sugestão do Blink, inclusão/remoção ao salvar, organização manual, preservação de `noqa`, tratamento de timeout e os atalhos de navegação e terminal. As sequências de teclado do Alacritty também foram enviadas a um Neovim em PTY para conferir a decodificação; o teclado físico na janela gráfica não foi conferido.

O teste de navegação usa o gopls para percorrer funções e métodos com Ctrl+Alt e as quatro setas, incluindo o modo de edição e a volta pelo histórico. Também verifica os limites do arquivo, símbolos fora de ordem e o descarte de respostas recebidas depois de mover o cursor, editar ou trocar de buffer. As teclas são enviadas pela API do Neovim; esse teste não passa pelos atalhos globais do GNOME.

As verificações de aparência conferem o fundo uniforme, os marcadores `~` e a ausência de bordas nas janelas da busca, nos layouts vertical e horizontal. O teste de temas carrega as 642 opções da coleção, compara a paleta Pastel Branco entre os editores e confere a prévia, a confirmação e o cancelamento. A configuração do Alacritty passou pela leitura TOML e pelo comando de migração em modo de simulação.

O JSON do Pastel Branco passou pelo [schema oficial de temas do Zed](https://zed.dev/schema/themes/v0.2.0.json), e as cores principais do Tomorrow Night foram comparadas com a extensão instalada. A aparência do tema novo na janela do Zed não foi conferida. Na verificação desta mudança, a suíte geral passou na segunda execução: a primeira parou ao esperar a saída do modo de edição depois de fechar o autocomplete com Esc. O teste específico de temas passou.

```sh
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-themes.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-terminal.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-git-ui.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-windows.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-imports.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-navigation.lua
ghostty +validate-config
alacritty migrate --dry-run --silent --config-file ~/.config/alacritty/alacritty.toml
git -C ~/dotfiles diff --check
```

Passaram os testes de edição pelos atalhos, seleção por palavra e caractere, substituição de texto com acentos, copiar/recortar/colar com clipboard simulado e criação e reabertura de buffers preservando rascunhos. Também foram verificados o menu e as sugestões reais de TypeScript/Python, inicialização de CSS/HTML/JSON/YAML/shell/C/Docker, stage por trecho, retirada do stage, painel de commits e visualização de conflito real. Passaram a restrição do Gradle a arquivos de build, o encaminhamento dos comandos do Codex e o carregamento do Octo. A abertura do painel do Codex foi conferida separadamente em um terminal PTY, com CLI simulado.

O teste usa os plugins e servidores locais, com paginação de mensagens desativada para não esperar teclas no modo headless. Ele desativa a consulta ao catálogo do Mason e adapta o stdio do Node a pipes, pois o sandbox desta sessão restringe os canais usados por esses processos. A instalação dos servidores e a interação online com Codex/GitHub precisam de validação separada. O reconhecimento físico de todas as teclas, o clipboard no terminal gráfico e a aparência da fonte no monitor não foram testados.

Os atalhos foram comparados com o [mapa JetBrains do Zed](https://github.com/zed-industries/zed/blob/main/assets/keymaps/linux/jetbrains.json). Para detalhes dos painéis e manutenção, consulte as documentações de [Neogit](https://github.com/NeogitOrg/neogit), [Diffview](https://github.com/sindrets/diffview.nvim), [Octo](https://github.com/pwntester/octo.nvim), [Blink](https://cmp.saghen.dev/configuration/keymap) e [Mason LSP](https://github.com/mason-org/mason-lspconfig.nvim).
