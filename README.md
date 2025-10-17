# Workspace Setup Automation

Sistema automatizado para configurar seu ambiente de desenvolvimento com Ansible e Chezmoi.

## 🚀 Características

- **Multi-distro**: Suporte para Arch Linux, Debian/Ubuntu, Fedora/RHEL
- **Ansible**: Gerenciamento de pacotes e configurações via playbooks
- **Chezmoi**: Sincronização de dotfiles
- **Menu interativo**: Interface amigável para escolher o que instalar
- **Verificações de segurança**: Validação de pré-requisitos antes da execução

## 📋 Pré-requisitos

- Linux (Arch, Debian/Ubuntu, Fedora/RHEL)
- Acesso sudo
- Conexão com internet
- Mínimo 2GB de espaço em disco

## 🛠️ Instalação

1. Clone o repositório:
```bash
git clone <seu-repositorio> init-setup
cd init-setup
```

2. Execute o script principal:
```bash
./setup.sh
```

## 📖 Como Usar

### Menu Principal

O script oferece um menu interativo com as seguintes opções:

1. **Setup Completo**: Instala Ansible, executa playbooks e configura Chezmoi
2. **Instalar Ansible**: Apenas instala o Ansible
3. **Instalar Chezmoi**: Apenas instala e configura o Chezmoi
4. **Executar Playbooks**: Roda os playbooks Ansible
5. **Aplicar Dotfiles**: Aplica configurações do Chezmoi
6. **Informações do Sistema**: Mostra status das ferramentas instaladas
7. **Sair**: Encerra o programa

### Estrutura do Projeto

```
init-setup/
├── setup.sh                 # Script principal
├── scripts/
│   ├── install-ansible.sh   # Instalação do Ansible
│   ├── install-chezmoi.sh   # Instalação do Chezmoi
│   └── utils.sh             # Funções auxiliares
├── ansible/
│   ├── playbooks/
│   │   ├── common.yml       # Pacotes comuns
│   │   ├── arch.yml         # Específico Arch
│   │   ├── debian.yml       # Específico Debian/Ubuntu
│   │   └── fedora.yml       # Específico Fedora/RHEL
│   ├── inventory/
│   │   └── localhost.ini
│   └── requirements.yml
├── chezmoi/
│   └── .chezmoi.toml.tmpl   # Template de configuração
└── README.md
```

## 📦 Pacotes Instalados

### Comuns (todas as distros)
- git, curl, wget, vim, neovim, tmux, zsh
- htop, tree, unzip, jq, ripgrep, fd, bat, exa, fzf
- build-essential/gcc, make

### Arch Linux
- yay (AUR helper), firefox, chromium, discord
- telegram-desktop, vlc, gimp, libreoffice-fresh
- docker, docker-compose, nodejs, npm, python, rust, go
- neofetch, alacritty, kitty, rofi, i3-wm, i3status, polybar
- AUR: visual-studio-code-bin, google-chrome, spotify, slack-desktop

### Debian/Ubuntu
- firefox, chromium-browser, discord, telegram-desktop
- vlc, gimp, libreoffice, docker.io, docker-compose
- nodejs, npm, python3, rustc, cargo, golang-go
- neofetch, alacritty, kitty, rofi, i3, i3status, polybar
- VS Code, Google Chrome

### Fedora/RHEL
- firefox, chromium, discord, telegram-desktop
- vlc, gimp, libreoffice, docker, docker-compose
- nodejs, npm, python3, rust, cargo, golang
- neofetch, alacritty, kitty, rofi, i3, i3status, polybar
- VS Code, Google Chrome

## 🔧 Configuração do Chezmoi

O script cria uma estrutura básica de dotfiles com:

- `.bashrc` com aliases e configurações básicas
- `.zshrc` com Oh My Zsh e plugins
- `.vimrc` com configurações básicas do Vim
- `.tmux.conf` com configurações do Tmux

### Personalização

1. Edite os arquivos em `~/.local/share/chezmoi/`
2. Execute `chezmoi apply` para aplicar as mudanças
3. Use `chezmoi edit <arquivo>` para editar arquivos específicos

## 🛡️ Segurança

- Verifica se não está rodando como root
- Valida conexão com internet
- Verifica espaço em disco disponível
- Cria backups antes de mudanças críticas
- Opção de confirmação para todas as operações

## 🐛 Troubleshooting

### Erro de permissões
```bash
chmod +x setup.sh scripts/*.sh
```

### Ansible não encontrado
```bash
./scripts/install-ansible.sh
```

### Chezmoi não encontrado
```bash
./scripts/install-chezmoi.sh
```

### Verificar logs
Os scripts criam logs detalhados durante a execução. Verifique a saída do terminal para mensagens de erro específicas.

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🙏 Agradecimentos

- [Ansible](https://www.ansible.com/) - Automação de infraestrutura
- [Chezmoi](https://www.chezmoi.io/) - Gerenciamento de dotfiles
- Comunidade Linux por todas as ferramentas incríveis