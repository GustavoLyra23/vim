# Neovim no dia a dia

Configuração de Gustavo, preparada em 23/11/2026. O tema padrão é Tomorrow Night, com a paleta da extensão instalada no Zed: fundo `#1e1f21` e texto `#c5c8c6`. O fundo é uniforme entre texto, números de linha e área vazia; os marcadores `~` ficam visíveis. A busca mantém a prévia dos arquivos, sem molduras ou linha divisória abaixo do campo de texto. Os atalhos seguem o mapa JetBrains selecionado no Zed. O Neovim continua tendo modos de edição; os painéis de Git e GitHub têm seus próprios atalhos.

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
| `:ls` | Lista os buffers e seus números |
| `:buffer 3` | Abre o buffer de número 3 |

Para treinar, execute `nvim /tmp/treino-neovim.txt` no terminal. Aperte `i`, escreva uma frase e pressione Esc. Digite `:w` e Enter para salvar; depois `:q` e Enter para sair. Abra o mesmo arquivo novamente para conferir o texto salvo.

No trabalho, comece com `Ctrl+E` para escolher um arquivo, `i` para editar e `Ctrl+S` para salvar. Pressione Esc e Espaço quando precisar descobrir uma ação. `Espaço g d` abre o diff; `Espaço g s` prepara o trecho atual para um commit; `Espaço g g` abre o painel de Git. Preparar um trecho, também chamado de *stage*, escolhe o que entrará no próximo commit. O commit é uma etapa separada.

Para IA, `Espaço a n` abre o Codex e `Espaço a r` retoma conversas anteriores. Para GitHub, `Espaço o p` lista os PRs do repositório atual.

## Atalhos

Na coluna alternativa, as teclas depois de `Espaço` são uma sequência, em modo de navegação. Por exemplo, `Espaço f f` abre a busca de arquivos.

| Ação | Atalho próximo do Zed | Alternativa |
| --- | --- | --- |
| Abrir arquivo | `Ctrl+E` ou `Ctrl+Shift+N` | `Espaço f f` |
| Novo buffer | `Ctrl+N` | `Espaço b a` |
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
| Definição | `Ctrl+B` | `Espaço c d` |
| Referências | `Alt+F7` | `Espaço c i` |
| Renomear símbolo | `Shift+F6` | `Espaço c r` |
| Ações de código | `Alt+Enter` | `Espaço c a` |
| Documentação / assinatura | `Ctrl+Q` / `Ctrl+P` | `K` para documentação |
| Formatar | `Ctrl+Alt+L` | `Espaço c f` |
| Próximo erro / anterior | `F2` / `Shift+F2` | `Espaço c e` mostra o erro da linha |
| Todos os diagnósticos | `Alt+6` | |
| Símbolos do arquivo | `Alt+7` | `Espaço c s` |
| Terminal integrado | `Alt+F12` | `Espaço t` |
| Git e commits | `Ctrl+K` ou `Alt+0` | `Espaço g g` |

Use `v` para selecionar caracteres e `V` para selecionar linhas. A área de transferência depende do suporte do terminal; a colagem do próprio terminal, normalmente `Ctrl+Shift+V`, também funciona.

### Seleção com Shift

Segure Ctrl e Shift e aperte ← ou → para selecionar palavras, tanto ao navegar quanto ao escrever. Repita para ampliar a seleção; use a direção contrária para reduzi-la. O movimento segue os limites de palavra do Neovim e pode incluir o espaço entre palavras. Shift com as setas seleciona por caractere ou linha; Shift+Home/End vai até o início ou fim da linha.

Essa seleção entra no modo Select: digitar substitui o trecho selecionado. `Ctrl+C` copia, `Ctrl+X` recorta e `Ctrl+V` substitui pelo conteúdo da área de transferência. Esc cancela a seleção. Para os comandos tradicionais do Vim, como `y`, use a seleção visual com `v` ou `V`, ou pressione `Ctrl+G` para converter a seleção atual em visual.

### Buffers abertos e rascunhos

Um buffer é o conteúdo aberto na memória do editor. Pode ser um arquivo existente ou um rascunho ainda sem nome. A barra superior mostra esses buffers.

- `Ctrl+N` cria um buffer vazio e já entra no modo de escrita. `Espaço b a` faz o mesmo no modo normal.
- `Esc`, depois `Espaço b b`, abre a lista. Digite parte do nome, escolha com as setas e pressione Enter. Buffers sem nome aparecem como `[Scratch]`.
- `Ctrl+Tab` avança e `Ctrl+Shift+Tab` volta entre os buffers. Trocar de buffer mantém as alterações na memória; ainda é preciso salvá-las no disco.
- Para dar um nome ao rascunho, pressione Esc e use `:w caminho/do/arquivo`, seguido de Enter. Depois, `Ctrl+S` salva normalmente.
- `Espaço b d` fecha o buffer atual e pergunta o que fazer se houver alterações sem salvar.

No terminal integrado, `Ctrl+\` seguido de `Ctrl+N` volta à navegação. Dois Esc rápidos também funcionam. Pressione `i` para voltar ao terminal.

### Ghostty e Alacritty

No Ghostty, as antigas ações de `Ctrl+Z` e `Ctrl+D` impediam desfazer e duplicar no editor. Agora fechar painel usa `Ctrl+Shift+W`, e dividir à direita usa `Ctrl+Shift+D`. Reinicie o terminal para garantir que os novos atalhos foram carregados.

`Ctrl+Shift+←/→` e `Ctrl+Tab`/`Ctrl+Shift+Tab` chegam ao Neovim para selecionar palavras e trocar buffers. Para trocar as abas do próprio Ghostty, use `Ctrl+PageUp/PageDown`.

O Alacritty mantém seus atalhos atuais e captura algumas combinações, como `Ctrl+Shift+F`. Use as alternativas com Espaço quando isso acontecer. Combinações com Ctrl e Shift também podem chegar como a mesma tecla em terminais sem suporte a teclado estendido. Nem todos os atalhos do Zed têm equivalente direto no Neovim.

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

1. Abra `Espaço g d` para comparar as alterações com o índice do Git. O painel lateral lista os arquivos; Enter abre a comparação.
2. No arquivo editável, `]c` e `[c` navegam pelos trechos alterados. `Espaço g p` mostra o trecho atual.
3. Use `Espaço g s` para colocar só esse trecho no stage. Uma seleção com `V`, seguida do mesmo atalho, prepara apenas o intervalo selecionado. `Espaço g u` desfaz o último stage de trecho.
4. Confira `Espaço g D`, com D maiúsculo, para revisar exatamente o que está no stage.
5. Abra `Espaço g g`. No Neogit, `Tab` expande, `s` prepara o item e `u` retira do stage. `c` seguido de `c` abre a mensagem do commit. Digite a mensagem e conclua com `Ctrl+C` duas vezes; `Ctrl+C`, depois `Ctrl+K`, cancela.

No painel do Neogit, `Ctrl+S` apenas atualiza a tela. `?` mostra a ajuda. Push é uma ação separada do commit.

Outros atalhos:

| Ação | Teclas |
| --- | --- |
| Fechar a visão de diff | `Espaço g q` |
| Histórico do arquivo | `Espaço g h` |
| Histórico do projeto | `Espaço g H` |
| Autor da linha | `Espaço g b` |

Durante um conflito, abra `Espaço g d` e selecione o arquivo em conflito. O layout mostra as versões e o resultado editável. Revise o resultado, salve e coloque o arquivo resolvido no stage. `g?` mostra os comandos locais do Diffview. Nenhum atalho global descarta alterações automaticamente.

## Conversas de IA

`Espaço a n` abre ou oculta o painel do Codex no projeto atual. O painel usa o CLI e a conta já configurados na máquina. Para começar outra conversa dentro dele, use `/new`.

`Espaço a r` abre `codex resume`, com o seletor das conversas anteriores do diretório. Para procurar também em outros diretórios, execute `codex resume --all` no terminal integrado.

As conversas ficam no histórico do Codex, separadas das threads do Zed. Esta configuração não importa conversas antigas do Zed e não adiciona previsão de texto por IA ao autocomplete: as sugestões de código vêm dos servidores de linguagem. O painel de IA é interativo e só recebe o que você envia nele.

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

| Linguagens | Servidores | Situação na preparação |
| --- | --- | --- |
| JavaScript, JSX, TypeScript, TSX | vtsls, ESLint | Executáveis disponíveis; autocomplete TypeScript testado |
| Python | basedpyright, Ruff | Executáveis disponíveis; autocomplete Python testado |
| HTML, CSS, SCSS, LESS | HTML, CSS, Emmet | Executáveis do Zed disponíveis |
| Tailwind CSS | tailwindcss | Executável do Zed disponível; depende do projeto |
| JSON, JSONC, YAML | jsonls, yamlls | Executáveis do Zed disponíveis |
| Bash, shell, `.env` | bashls | Executável do Zed disponível; zsh tem diferenças de sintaxe |
| C, C++, Objective-C | clangd | Executável disponível no sistema |
| Dockerfile e Docker Compose | docker_language_server | Executável do Zed disponível |
| Go | gopls | Aguarda instalação pelo Mason; Go está instalado |
| Rust | rust_analyzer | Aguarda download; projetos precisam do toolchain Rust |
| Lua e anotações Lua | lua_ls | Aguarda download |
| Java | jdtls | Aguarda download; Java está instalado |
| Gradle e Gradle Kotlin | gradle_ls | Aguarda download; suporte ao arquivo de build, não a todo projeto Kotlin |
| CMake | neocmake | Aguarda download |
| Terraform e variáveis Terraform | terraformls | Aguarda download |
| TOML | taplo | Aguarda download |
| Markdown e `.txt` | marksman | Aguarda download; completa palavras e caminhos enquanto isso |
| SQL | sqlls | Aguarda instalação; schemas dependem da conexão configurada no projeto |
| Zig | zls | Aguarda download; depende da versão do Zig do projeto |
| Nix | nil_ls | Mason precisa de Cargo, ausente na preparação; também aceita `nil` já instalado |
| Odin | ols | Aguarda download; biblioteca padrão depende da instalação do Odin |
| Haskell, Literate Haskell e Cabal | hls | Mason precisa de `ghcup`, ausente; GHC/HLS devem ser compatíveis |
| GDScript | servidor do Godot | Requer o projeto aberto no Godot, em `127.0.0.1:6005` |

Alex, GDShader, arquivos de recursos do Godot, properties e arquivos Git têm sugestões de palavras/caminhos; esta configuração não atribui a eles um servidor semântico específico. O destaque de sintaxe usa o runtime do Neovim e os tokens fornecidos pelos LSPs, quando disponíveis.

A rede desta sessão não permitiu os downloads do Mason/npm. Por isso, os 14 servidores marcados como pendentes não foram instalados nem validados. Também não foi possível confirmar a autenticação do `gh`; o resultado precisa ser conferido no terminal normal antes do uso online.

## Arquivos e manutenção

| Caminho | Função |
| --- | --- |
| `~/dotfiles/.zshrc` | Adiciona `/opt/nvim-linux-x86_64/bin` ao PATH |
| `~/dotfiles/nvim/init.lua` | Opções do editor e início do carregamento |
| `~/dotfiles/nvim/lua/plugins.lua` | Interface, autocomplete, Git e GitHub |
| `~/dotfiles/nvim/lua/languages.lua` | Servidores de linguagem |
| `~/dotfiles/nvim/lua/keymaps.lua` | Atalhos e painéis do Codex |
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

Para abrir temporariamente sem esta configuração, use `nvim --clean`. Para desativá-la, renomeie o link `~/.config/nvim`; os arquivos em `~/dotfiles/nvim` permanecem. Para restaurar o Ghostty, remova apenas o link de configuração e copie o backup de volta para `~/.config/ghostty/config.ghostty`.

Para restaurar o Alacritty, remova apenas o link `~/.config/alacritty/alacritty.toml` e copie `alacritty.toml.before-neovim` para esse mesmo caminho.

## Verificações

O teste de integração usa arquivos e commits descartáveis em `/tmp`. Ele não faz commits nos projetos, não envia prompts de IA e não publica comentários no GitHub.

As verificações de aparência conferem o fundo uniforme, os marcadores `~` e a ausência de bordas nas janelas da busca, nos layouts vertical e horizontal. O teste de temas carrega as 642 opções da coleção, compara a paleta Pastel Branco entre os editores e confere a prévia, a confirmação e o cancelamento. A configuração do Alacritty passou pela leitura TOML e pelo comando de migração em modo de simulação.

O JSON do Pastel Branco passou pelo [schema oficial de temas do Zed](https://zed.dev/schema/themes/v0.2.0.json), e as cores principais do Tomorrow Night foram comparadas com a extensão instalada. A aparência do tema novo na janela do Zed não foi conferida. Na verificação desta mudança, a suíte geral passou na segunda execução: a primeira parou ao esperar a saída do modo de edição depois de fechar o autocomplete com Esc. O teste específico de temas passou.

```sh
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim.lua
nvim --headless -u NONE -i NONE -l ~/dotfiles/tests/neovim-themes.lua
ghostty +validate-config
alacritty migrate --dry-run --silent --config-file ~/.config/alacritty/alacritty.toml
git -C ~/dotfiles diff --check
```

Passaram os testes de edição pelos atalhos, seleção por palavra e caractere, substituição de texto com acentos, copiar/recortar/colar com clipboard simulado e criação e reabertura de buffers preservando rascunhos. Também foram verificados o menu e as sugestões reais de TypeScript/Python, inicialização de CSS/HTML/JSON/YAML/shell/C/Docker, stage por trecho, retirada do stage, painel de commits e visualização de conflito real. Passaram a restrição do Gradle a arquivos de build, o encaminhamento dos comandos do Codex e o carregamento do Octo. A abertura do painel do Codex foi conferida separadamente em um terminal PTY, com CLI simulado.

O teste usa os plugins e servidores locais, com paginação de mensagens desativada para não esperar teclas no modo headless. Ele desativa a consulta ao catálogo do Mason e adapta o stdio do Node a pipes, pois o sandbox desta sessão restringe os canais usados por esses processos. A instalação dos servidores e a interação online com Codex/GitHub precisam de validação separada. O reconhecimento físico de todas as teclas, o clipboard no terminal gráfico e a aparência da fonte no monitor não foram testados.

Os atalhos foram comparados com o [mapa JetBrains do Zed](https://github.com/zed-industries/zed/blob/main/assets/keymaps/linux/jetbrains.json). Para detalhes dos painéis e manutenção, consulte as documentações de [Neogit](https://github.com/NeogitOrg/neogit), [Diffview](https://github.com/sindrets/diffview.nvim), [Octo](https://github.com/pwntester/octo.nvim), [Blink](https://cmp.saghen.dev/configuration/keymap) e [Mason LSP](https://github.com/mason-org/mason-lspconfig.nvim).
