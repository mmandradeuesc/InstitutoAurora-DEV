-- Carga completa das matriculas validas da oficina.
-- Executar com psql a partir de qualquer diretorio.

CREATE TEMP TABLE tmp_cursos (
    codigo_curso TEXT,
    nome_curso TEXT,
    carga_horaria INTEGER,
    turno TEXT
);

CREATE TEMP TABLE tmp_matriculas (
    num_matricula TEXT,
    id_aluno INTEGER,
    cod_curso TEXT,
    data_matricula TEXT,
    semestre TEXT
);

\copy tmp_cursos FROM 'C:/Projetos/InstitutoAurora/data/in/cursos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy tmp_matriculas FROM 'C:/Projetos/InstitutoAurora/data/in/matriculas.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

TRUNCATE TABLE staging.stg_matriculas;

INSERT INTO staging.stg_matriculas (
    id_matricula, id_aluno, codigo_curso, nome_curso, turma, unidade,
    modalidade, ano_letivo, semestre, data_matricula, data_inicio,
    data_fim_prevista, situacao
)
SELECT DISTINCT ON (regexp_replace(m.num_matricula, '[^0-9]', '', 'g')::INTEGER)
    regexp_replace(m.num_matricula, '[^0-9]', '', 'g')::INTEGER,
    m.id_aluno,
    upper(replace(trim(m.cod_curso), '-', '')),
    trim(c.nome_curso),
    'Importada',
    'Instituto Aurora',
    'Presencial',
    split_part(m.semestre, '.', 1)::INTEGER,
    split_part(m.semestre, '.', 2)::INTEGER,
    CASE
        WHEN m.data_matricula ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(m.data_matricula, 'DD/MM/YYYY')
        WHEN m.data_matricula ~ '^\d{2}-\d{2}-\d{4}$' THEN to_date(m.data_matricula, 'DD-MM-YYYY')
        WHEN m.data_matricula ~ '^\d{4}-\d{2}-\d{2}$' THEN to_date(m.data_matricula, 'YYYY-MM-DD')
        ELSE NULL
    END,
    CASE
        WHEN m.data_matricula ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(m.data_matricula, 'DD/MM/YYYY')
        WHEN m.data_matricula ~ '^\d{2}-\d{2}-\d{4}$' THEN to_date(m.data_matricula, 'DD-MM-YYYY')
        WHEN m.data_matricula ~ '^\d{4}-\d{2}-\d{2}$' THEN to_date(m.data_matricula, 'YYYY-MM-DD')
        ELSE NULL
    END,
    NULL,
    'Ativa'
FROM tmp_matriculas m
JOIN staging.stg_alunos a ON a.id_aluno = m.id_aluno
JOIN (
    SELECT DISTINCT ON (upper(replace(trim(codigo_curso), '-', '')))
        upper(replace(trim(codigo_curso), '-', '')) AS codigo_curso,
        trim(nome_curso) AS nome_curso
    FROM tmp_cursos
    WHERE NULLIF(trim(codigo_curso), '') IS NOT NULL
    ORDER BY upper(replace(trim(codigo_curso), '-', '')), nome_curso
) c ON c.codigo_curso = upper(replace(trim(m.cod_curso), '-', ''))
WHERE NULLIF(trim(m.num_matricula), '') IS NOT NULL
  AND NULLIF(trim(m.cod_curso), '') IS NOT NULL
  AND m.semestre ~ '^\d{4}\.[12]$'
  AND (
      m.data_matricula ~ '^\d{2}/\d{2}/\d{4}$'
      OR m.data_matricula ~ '^\d{2}-\d{2}-\d{4}$'
      OR m.data_matricula ~ '^\d{4}-\d{2}-\d{2}$'
  )
ORDER BY regexp_replace(m.num_matricula, '[^0-9]', '', 'g')::INTEGER;

SELECT COUNT(*) AS matriculas_carregadas FROM staging.stg_matriculas;
SELECT COUNT(*) AS matriculas_sem_aluno
FROM staging.stg_matriculas m
LEFT JOIN staging.stg_alunos a ON a.id_aluno = m.id_aluno
WHERE a.id_aluno IS NULL;
