-- ========================================
-- FALAÍ - SCHEMA DO BANCO DE DADOS
-- ========================================

-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS falai_sa;
USE falai_sa;

-- ========================================
-- TABELA: tb_usuario (Usuários)
-- ========================================
CREATE TABLE IF NOT EXISTS tb_usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nm_login VARCHAR(100) UNIQUE NOT NULL,
    ds_senha VARCHAR(255) NOT NULL,
    nm_email VARCHAR(100) NOT NULL,
    img_perfil VARCHAR(255),
    dt_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_login (nm_login),
    INDEX idx_email (nm_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABELA: tb_admin (Administradores)
-- ========================================
CREATE TABLE IF NOT EXISTS tb_admin (
    id_admin INT PRIMARY KEY AUTO_INCREMENT,
    nm_login VARCHAR(100) UNIQUE NOT NULL,
    ds_senha VARCHAR(255) NOT NULL,
    isadmin BOOLEAN DEFAULT TRUE,
    dt_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_login (nm_login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABELA: tb_comunidade (Comunidades)
-- ========================================
CREATE TABLE IF NOT EXISTS tb_comunidade (
    id_comunidade INT PRIMARY KEY AUTO_INCREMENT,
    nm_comunidade VARCHAR(100) NOT NULL,
    ds_comunidade TEXT,
    criado_por INT NOT NULL,
    max_usuario INT DEFAULT 50,
    img_perfil VARCHAR(255),
    dt_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (criado_por) REFERENCES tb_usuario(id_usuario) ON DELETE CASCADE,
    INDEX idx_criador (criado_por),
    INDEX idx_nome (nm_comunidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABELA: tb_usuario_comunidade (Membros)
-- ========================================
CREATE TABLE IF NOT EXISTS tb_usuario_comunidade (
    id_usuario INT NOT NULL,
    id_comunidade INT NOT NULL,
    ultima_visualizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_comunidade),
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_comunidade) REFERENCES tb_comunidade(id_comunidade) ON DELETE CASCADE,
    INDEX idx_usuario (id_usuario),
    INDEX idx_comunidade (id_comunidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABELA: tb_chat (Mensagens)
-- ========================================
CREATE TABLE IF NOT EXISTS tb_chat (
    id_chat INT PRIMARY KEY AUTO_INCREMENT,
    id_chat_comunidade INT NOT NULL,
    id_chat_usuario INT NOT NULL,
    mensagem TEXT,
    tipo VARCHAR(50) DEFAULT 'texto',
    arquivo_url VARCHAR(255),
    lida BOOLEAN DEFAULT FALSE,
    dt_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_chat_comunidade) REFERENCES tb_comunidade(id_comunidade) ON DELETE CASCADE,
    FOREIGN KEY (id_chat_usuario) REFERENCES tb_usuario(id_usuario) ON DELETE CASCADE,
    INDEX idx_comunidade (id_chat_comunidade),
    INDEX idx_usuario (id_chat_usuario),
    INDEX idx_data (dt_envio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- DADOS INICIAIS (Opcional)
-- ========================================

-- Usuário de teste
INSERT INTO tb_usuario (nm_login, ds_senha, nm_email, img_perfil) VALUES 
('admin', 'admin123', 'admin@falai.com', 'perfilplaceholder.png');

-- Admin de teste
INSERT INTO tb_admin (nm_login, ds_senha, isadmin) VALUES 
('administrador', 'admin123', TRUE);

-- ========================================
-- VIEWS ÚTEIS (Opcional)
-- ========================================

-- View para contar membros de comunidades
CREATE OR REPLACE VIEW vw_comunidade_membros AS
SELECT 
    c.id_comunidade,
    c.nm_comunidade,
    c.criado_por,
    COUNT(uc.id_usuario) as total_membros,
    u.nm_login as nome_criador
FROM tb_comunidade c
LEFT JOIN tb_usuario_comunidade uc ON c.id_comunidade = uc.id_comunidade
LEFT JOIN tb_usuario u ON c.criado_por = u.id_usuario
GROUP BY c.id_comunidade;

-- View para mensagens não lidas
CREATE OR REPLACE VIEW vw_mensagens_nao_lidas AS
SELECT 
    c.id_chat_comunidade,
    c.id_chat_usuario,
    COUNT(*) as total_nao_lidos
FROM tb_chat c
WHERE c.lida = FALSE
GROUP BY c.id_chat_comunidade, c.id_chat_usuario;

-- ========================================
-- FIM DO SCHEMA
-- ========================================
