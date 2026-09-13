-- Validacoes adicionais das fontes de cursos e matriculas.

CREATE TEMP TABLE tmp_cursos_validacao (
    codigo_curso TEXT,
    nome_curso TEXT,
    carga_horaria INTEGER,
    turno TEXT
);
CREATE TEMP TABLE tmp_matriculas_validacao (
    num_matricula TEXT,
    id_aluno INTEGER,
    cod_curso TEXT,
    data_matricula TEXT,
    semestre TEXT
);

\copy tmp_cursos_validacao FROM 'C:/Projetos/InstitutoAurora/data/in/cursos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy tmp_matriculas_validacao FROM 'C:/Projetos/InstitutoAurora/data/in/matriculas.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

SELECT COUNT(*) AS cursos_lidos FROM tmp_cursos_validacao;
SELECT COUNT(*) AS cursos_distintos
FROM (
    SELECT DISTINCT upper(replace(trim(codigo_curso), '-', '')) AS codigo
    FROM tmp_cursos_validacao
    WHERE NULLIF(trim(codigo_curso), '') IS NOT NULL
) cursos;
SELECT COUNT(*) AS matriculas_lidas FROM tmp_matriculas_validacao;
SELECT COUNT(*) AS matriculas_com_aluno_e_curso
FROM tmp_matriculas_validacao m
JOIN staging.stg_alunos a ON a.id_aluno = m.id_aluno
JOIN (
    SELECT DISTINCT upper(replace(trim(codigo_curso), '-', '')) AS codigo
    FROM tmp_cursos_validacao
    WHERE NULLIF(trim(codigo_curso), '') IS NOT NULL
) c ON c.codigo = upper(replace(trim(m.cod_curso), '-', ''));
