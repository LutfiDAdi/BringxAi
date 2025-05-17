#!/bin/bash

# Script Instalasi Worker Node BrinxAI
# Keterangan: Script ini untuk menginstalasi, konfigurasi, atau menghapus worker node BrinxAI

function install_brinxai() {
    echo "Memulai instalasi BrinxAI Worker Node..."
    
    # Update sistem
    echo "Memperbarui paket sistem..."
    sudo apt update -y && sudo apt upgrade -y

    # Instal Docker
    echo "Menginstal Docker..."
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

    # Aktifkan Docker
    echo "Mengaktifkan Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Konfigurasi Firewall
    echo "Mengkonfigurasi firewall..."
    sudo ufw allow OpenSSH
    sudo ufw allow 5011/tcp    # Port Worker
    sudo ufw allow 1194/udp    # Port Relay
    sudo ufw --force enable

    # Clone repository BrinxAI Worker
    echo "Mengunduh script BrinxAI Worker..."
    git clone https://github.com/admier1/BrinxAI-Worker-Nodes
    cd BrinxAI-Worker-Nodes
    chmod +x install_ubuntu.sh

    echo "=================================================="
    echo "Instalasi dasar selesai. Silakan jalankan script install_ubuntu.sh"
    echo "Setelah itu, copy UUID worker Anda."
    echo "=================================================="
    echo ""

    show_model_commands
}

function show_model_commands() {
    echo "Pilihan model yang bisa dijalankan:"
    echo ""
    echo "1. Untuk VPS 4 Core/8GB RAM (Disarankan):"
    echo "   - Upscaler Models"
    echo "   - Text-UI Models"
    echo "   - Rembg Models"
    echo ""
    echo "2. Untuk VPS 8 Core/16GB RAM:"
    echo "   - Semua model termasuk Stable Diffusion"
    echo ""
    echo "Perintah untuk menjalankan model:"

    cat << EOF

# Upscaler Models
docker run -d --name upscaler --network brinxai-network --cpus=2 --memory=8192m -p 127.0.0.1:3800:3800 admier/brinxai_nodes-upscaler:latest

# Text-ui Models
docker run -d --name text-ui --network brinxai-network --cpus=4 --memory=8192m -p 127.0.0.1:5012:5012 admier/brinxai_nodes-text-ui:latest

# Rembg Models
docker run -d --name rembg --network brinxai-network --cpus=2 --memory=4096m -p 127.0.0.1:7000:7000 admier/brinxai_nodes-rembg:latest

# Stable Diffusion Models (Hanya untuk VPS 8 Core/16GB RAM)
docker run -d --name stable-diffusion --network brinxai-network --cpus=6 --memory=8192m -p 127.0.0.1:5060:5060 -e PORT=5060 admier/brinxai_nodes-stabled:latest

EOF
}

function cleanup_brinxai() {
    echo "Membersihkan instalasi BrinxAI..."
    
    # Hentikan dan hapus container
    echo "Menghentikan dan menghapus container Docker..."
    docker stop upscaler text-ui rembg stable-diffusion 2>/dev/null
    docker rm upscaler text-ui rembg stable-diffusion 2>/dev/null
    
    # Hapus jaringan Docker
    echo "Menghapus jaringan brinxai-network..."
    docker network rm brinxai-network 2>/dev/null
    
    # Hapus direktori BrinxAI-Worker-Nodes
    echo "Menghapus repository BrinxAI..."
    cd ~
    rm -rf BrinxAI-Worker-Nodes 2>/dev/null
    
    echo "Pembersihan selesai."
}

# Menu utama
while true; do
    echo ""
    echo "======================================"
    echo " BrinxAI Worker Node Management Script"
    echo "======================================"
    echo "1. Install BrinxAI Worker Node"
    echo "2. Tampilkan perintah untuk menjalankan model"
    echo "3. Hapus BrinxAI Worker Node (Cleanup)"
    echo "4. Keluar"
    echo ""
    read -p "Pilih opsi [1-4]: " choice
    
    case $choice in
        1) install_brinxai ;;
        2) show_model_commands ;;
        3) cleanup_brinxai ;;
        4) echo "Keluar dari script."; exit 0 ;;
        *) echo "Pilihan tidak valid. Silakan coba lagi." ;;
    esac
done
