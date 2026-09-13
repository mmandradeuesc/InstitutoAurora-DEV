-- Instituto Aurora — dados fictícios de sistema acadêmico (staging)
-- Banco: aurora_dw | Schema: staging

CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.stg_financeiro;
DROP TABLE IF EXISTS staging.stg_conclusao;
DROP TABLE IF EXISTS staging.stg_frequencia;
DROP TABLE IF EXISTS staging.stg_matriculas;
DROP TABLE IF EXISTS staging.stg_alunos;

CREATE TABLE staging.stg_alunos (
    id_aluno           INTEGER PRIMARY KEY,
    nome_completo      TEXT NOT NULL,
    cpf                VARCHAR(14) NOT NULL,
    data_nascimento    DATE NOT NULL,
    sexo               VARCHAR(1) NOT NULL,
    email              TEXT,
    telefone           VARCHAR(20),
    cidade             TEXT,
    uf                 CHAR(2),
    bairro             TEXT,
    data_cadastro      DATE NOT NULL,
    status_aluno       TEXT NOT NULL,
    origem_sistema     TEXT NOT NULL DEFAULT 'SGA',
    dt_carga           TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE staging.stg_matriculas (
    id_matricula       INTEGER PRIMARY KEY,
    id_aluno           INTEGER NOT NULL,
    codigo_curso       TEXT NOT NULL,
    nome_curso         TEXT NOT NULL,
    turma              TEXT NOT NULL,
    unidade            TEXT NOT NULL,
    modalidade         TEXT NOT NULL,
    ano_letivo         INTEGER NOT NULL,
    semestre           INTEGER NOT NULL,
    data_matricula     DATE NOT NULL,
    data_inicio        DATE NOT NULL,
    data_fim_prevista  DATE,
    situacao           TEXT NOT NULL,
    origem_sistema     TEXT NOT NULL DEFAULT 'SGA',
    dt_carga           TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE staging.stg_frequencia (
    id_frequencia      BIGINT PRIMARY KEY,
    id_matricula       INTEGER NOT NULL,
    id_aluno           INTEGER NOT NULL,
    data_aula          DATE NOT NULL,
    disciplina         TEXT NOT NULL,
    presente           BOOLEAN NOT NULL,
    carga_horaria      NUMERIC(5,1) NOT NULL,
    justificativa      TEXT,
    origem_sistema     TEXT NOT NULL DEFAULT 'SGA',
    dt_carga           TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE staging.stg_conclusao (
    id_conclusao       INTEGER PRIMARY KEY,
    id_matricula       INTEGER NOT NULL,
    id_aluno           INTEGER NOT NULL,
    data_conclusao     DATE,
    situacao           TEXT NOT NULL,
    nota_final         NUMERIC(4,1),
    carga_horaria_cumprida INTEGER,
    certificado_emitido BOOLEAN NOT NULL DEFAULT FALSE,
    codigo_certificado TEXT,
    origem_sistema     TEXT NOT NULL DEFAULT 'SGA',
    dt_carga           TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE staging.stg_financeiro (
    id_lancamento      INTEGER PRIMARY KEY,
    id_matricula       INTEGER NOT NULL,
    id_aluno           INTEGER NOT NULL,
    tipo_lancamento    TEXT NOT NULL,
    descricao          TEXT NOT NULL,
    valor              NUMERIC(12,2) NOT NULL,
    data_competencia   DATE NOT NULL,
    data_vencimento    DATE NOT NULL,
    data_pagamento     DATE,
    status_pagamento   TEXT NOT NULL,
    origem_sistema     TEXT NOT NULL DEFAULT 'SGA',
    dt_carga           TIMESTAMP NOT NULL DEFAULT now()
);

DO $$
DECLARE
    v_nomes TEXT[] := ARRAY[
        'Ana','Bruno','Carla','Diego','Elisa','Felipe','Gabriela','Henrique','Isabela','João',
        'Karina','Lucas','Mariana','Nicolas','Olivia','Pedro','Quitéria','Rafael','Sofia','Thiago',
        'Úrsula','Vinícius','Wanessa','Xavier','Yasmin','Zeca','Beatriz','Caio','Daniela','Eduardo'
    ];
    v_sobrenomes TEXT[] := ARRAY[
        'Silva','Santos','Oliveira','Souza','Rodrigues','Ferreira','Almeida','Nascimento','Lima','Araújo',
        'Costa','Carvalho','Gomes','Martins','Rocha','Barbosa','Ribeiro','Teixeira','Mendes','Castro'
    ];
    v_cidades TEXT[] := ARRAY['São Paulo','Guarulhos','Osasco','Santo André','São Bernardo do Campo','Diadema','Mauá'];
    v_ufs TEXT[] := ARRAY['SP','SP','SP','SP','SP','SP','SP'];
    v_bairros TEXT[] := ARRAY['Centro','Jardim das Flores','Vila Nova','Parque Aurora','Jardim Esperança','Vila Aurora','Cidade Nova'];
    v_cursos TEXT[][] := ARRAY[
        ARRAY['INF-BAS','Informática Básica','Turma A','Unidade Centro','Presencial'],
        ARRAY['EXC-DAD','Excel e Análise de Dados','Turma B','Unidade Centro','Híbrido'],
        ARRAY['EJA-FND','EJA — Ensino Fundamental','Turma C','Unidade Leste','Presencial'],
        ARRAY['EMP-OFC','Oficina de Empregabilidade','Turma D','Unidade Centro','Presencial'],
        ARRAY['ING-INS','Inglês Instrumental','Turma E','Unidade Oeste','Híbrido'],
        ARRAY['GPS-SOC','Gestão de Projetos Sociais','Turma F','Unidade Centro','EAD'],
        ARRAY['ADM-AUX','Auxiliar Administrativo','Turma G','Unidade Sul','Presencial'],
        ARRAY['CUI-IDO','Cuidador de Idosos','Turma H','Unidade Leste','Presencial']
    ];
    v_disciplinas TEXT[] := ARRAY['Módulo 1','Módulo 2','Oficina prática','Projeto integrador','Avaliação'];
    i INTEGER;
    j INTEGER;
    k INTEGER;
    n_alunos CONSTANT INTEGER := 80;
    v_nome TEXT;
    v_sexo CHAR(1);
    v_id_mat INTEGER := 0;
    v_id_freq BIGINT := 0;
    v_id_conc INTEGER := 0;
    v_id_fin INTEGER := 0;
    v_curso INTEGER;
    v_sit TEXT;
    v_dt_mat DATE;
    v_dt_ini DATE;
    v_dt_fim DATE;
    v_aula DATE;
    v_presente BOOLEAN;
    v_tipo TEXT;
    v_valor NUMERIC(12,2);
    v_venc DATE;
    v_pago DATE;
    v_status TEXT;
    v_n_mats INTEGER;
    rec RECORD;
BEGIN
    FOR i IN 1..n_alunos LOOP
        v_nome := v_nomes[1 + ((i - 1) % array_length(v_nomes, 1))]
               || ' '
               || v_sobrenomes[1 + ((i * 3 - 1) % array_length(v_sobrenomes, 1))]
               || ' '
               || v_sobrenomes[1 + ((i * 7 - 1) % array_length(v_sobrenomes, 1))];
        v_sexo := CASE WHEN i % 2 = 0 THEN 'M' ELSE 'F' END;

        INSERT INTO staging.stg_alunos (
            id_aluno, nome_completo, cpf, data_nascimento, sexo, email, telefone,
            cidade, uf, bairro, data_cadastro, status_aluno
        ) VALUES (
            i,
            v_nome,
            lpad((10000000000 + i)::TEXT, 11, '0'),
            DATE '1985-01-01' + ((i * 97) % 12000),
            v_sexo,
            lower(replace(split_part(v_nome, ' ', 1), 'ú', 'u')) || i || '@emailficticio.aurora.br',
            '(11) 9' || lpad((80000000 + i * 137)::TEXT, 8, '0'),
            v_cidades[1 + ((i - 1) % array_length(v_cidades, 1))],
            v_ufs[1 + ((i - 1) % array_length(v_ufs, 1))],
            v_bairros[1 + ((i * 2 - 1) % array_length(v_bairros, 1))],
            DATE '2024-01-05' + ((i * 3) % 400),
            CASE WHEN i % 17 = 0 THEN 'Inativo' ELSE 'Ativo' END
        );

        v_n_mats := CASE WHEN i % 9 = 0 THEN 2 ELSE 1 END;
        FOR j IN 1..v_n_mats LOOP
            v_id_mat := v_id_mat + 1;
            v_curso := 1 + ((i + j) % array_length(v_cursos, 1));
            v_dt_mat := DATE '2024-02-01' + ((i * 5 + j * 20) % 360);
            v_dt_ini := v_dt_mat + 7;
            v_dt_fim := v_dt_ini + 150;
            v_sit := CASE
                WHEN i % 13 = 0 THEN 'Cancelada'
                WHEN i % 11 = 0 THEN 'Trancada'
                WHEN v_dt_fim < CURRENT_DATE AND i % 5 <> 0 THEN 'Concluída'
                ELSE 'Ativa'
            END;

            INSERT INTO staging.stg_matriculas (
                id_matricula, id_aluno, codigo_curso, nome_curso, turma, unidade,
                modalidade, ano_letivo, semestre, data_matricula, data_inicio,
                data_fim_prevista, situacao
            ) VALUES (
                v_id_mat, i,
                v_cursos[v_curso][1], v_cursos[v_curso][2], v_cursos[v_curso][3],
                v_cursos[v_curso][4], v_cursos[v_curso][5],
                EXTRACT(YEAR FROM v_dt_ini)::INTEGER,
                CASE WHEN EXTRACT(MONTH FROM v_dt_ini) <= 6 THEN 1 ELSE 2 END,
                v_dt_mat, v_dt_ini, v_dt_fim, v_sit
            );
        END LOOP;
    END LOOP;

    FOR rec IN
        SELECT id_matricula, id_aluno, nome_curso, data_inicio, data_fim_prevista, situacao
        FROM staging.stg_matriculas
    LOOP
        FOR k IN 0..11 LOOP
            v_aula := rec.data_inicio + (k * 7);
            EXIT WHEN v_aula > LEAST(rec.data_fim_prevista, CURRENT_DATE);
            CONTINUE WHEN rec.situacao = 'Cancelada' AND k > 2;

            v_id_freq := v_id_freq + 1;
            v_presente := NOT ((rec.id_aluno + k) % 7 = 0);

            INSERT INTO staging.stg_frequencia (
                id_frequencia, id_matricula, id_aluno, data_aula, disciplina,
                presente, carga_horaria, justificativa
            ) VALUES (
                v_id_freq, rec.id_matricula, rec.id_aluno, v_aula,
                v_disciplinas[1 + (k % array_length(v_disciplinas, 1))],
                v_presente, 4.0,
                CASE WHEN v_presente THEN NULL ELSE 'Falta registrada no SGA' END
            );
        END LOOP;

        IF rec.situacao IN ('Concluída', 'Cancelada', 'Trancada')
           OR (rec.situacao = 'Ativa' AND rec.id_aluno % 8 = 0) THEN
            v_id_conc := v_id_conc + 1;
            INSERT INTO staging.stg_conclusao (
                id_conclusao, id_matricula, id_aluno, data_conclusao, situacao,
                nota_final, carga_horaria_cumprida, certificado_emitido, codigo_certificado
            ) VALUES (
                v_id_conc, rec.id_matricula, rec.id_aluno,
                CASE WHEN rec.situacao = 'Concluída' THEN rec.data_fim_prevista ELSE rec.data_inicio + 60 END,
                CASE
                    WHEN rec.situacao = 'Concluída' THEN 'Concluído'
                    WHEN rec.situacao = 'Cancelada' THEN 'Evadido'
                    WHEN rec.situacao = 'Trancada' THEN 'Trancado'
                    ELSE 'Em andamento'
                END,
                CASE WHEN rec.situacao = 'Concluída' THEN 60 + (rec.id_aluno % 41) ELSE NULL END,
                CASE WHEN rec.situacao = 'Concluída' THEN 48 ELSE 12 + (rec.id_aluno % 20) END,
                rec.situacao = 'Concluída',
                CASE WHEN rec.situacao = 'Concluída'
                     THEN 'CERT-AURORA-' || lpad(rec.id_matricula::TEXT, 5, '0')
                     ELSE NULL END
            );
        END IF;

        FOR k IN 0..4 LOOP
            v_id_fin := v_id_fin + 1;
            v_tipo := CASE WHEN k = 0 THEN 'Taxa de matrícula' ELSE 'Mensalidade' END;
            v_valor := CASE WHEN k = 0 THEN 80.00 ELSE 180.00 END;
            IF rec.id_aluno % 10 = 0 THEN
                v_tipo := CASE WHEN k = 0 THEN 'Taxa de matrícula' ELSE 'Bolsa' END;
                v_valor := CASE WHEN k = 0 THEN 0.00 ELSE 0.00 END;
            END IF;
            v_venc := date_trunc('month', rec.data_inicio)::DATE + (k * 30) + 9;
            IF rec.situacao = 'Cancelada' AND k > 1 THEN
                CONTINUE;
            END IF;
            IF v_valor = 0 THEN
                v_status := 'Isento';
                v_pago := v_venc;
            ELSIF rec.id_aluno % 6 = 0 AND k >= 3 THEN
                v_status := 'Pendente';
                v_pago := NULL;
            ELSIF rec.id_aluno % 15 = 0 AND k = 4 THEN
                v_status := 'Atrasado';
                v_pago := NULL;
            ELSE
                v_status := 'Pago';
                v_pago := v_venc - 2;
            END IF;

            INSERT INTO staging.stg_financeiro (
                id_lancamento, id_matricula, id_aluno, tipo_lancamento, descricao,
                valor, data_competencia, data_vencimento, data_pagamento, status_pagamento
            ) VALUES (
                v_id_fin, rec.id_matricula, rec.id_aluno, v_tipo,
                v_tipo || ' — ' || rec.nome_curso,
                v_valor, date_trunc('month', v_venc)::DATE, v_venc, v_pago, v_status
            );
        END LOOP;
    END LOOP;
END $$;

CREATE INDEX IF NOT EXISTS ix_stg_matriculas_aluno ON staging.stg_matriculas (id_aluno);
CREATE INDEX IF NOT EXISTS ix_stg_frequencia_aluno ON staging.stg_frequencia (id_aluno);
CREATE INDEX IF NOT EXISTS ix_stg_frequencia_mat ON staging.stg_frequencia (id_matricula);
CREATE INDEX IF NOT EXISTS ix_stg_conclusao_mat ON staging.stg_conclusao (id_matricula);
CREATE INDEX IF NOT EXISTS ix_stg_financeiro_mat ON staging.stg_financeiro (id_matricula);
