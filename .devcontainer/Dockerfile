FROM debian:stable-slim

RUN apt-get update && apt-get install -y build-essential python3-pip python3 bash nodejs npm zsh jq openssh-client git curl vim zsh-autosuggestions zsh-syntax-highlighting && rm -rf /var/lib/apt/lists/*
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc && echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN curl https://get.starkli.sh | sh
RUN curl -L https://install.dojoengine.org | bash
RUN curl -L https://slot.cartridge.sh | bash
RUN echo "export PATH=$PATH:/root/.local/bin:/root/.dojo/bin:/root/.slot/bin:/root/.cargo/bin" >> ~/.zshrc

ENV SHELL /bin/zsh
RUN curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- --version 2.6.3
