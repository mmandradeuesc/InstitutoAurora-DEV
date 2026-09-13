# Oficina Prática — Módulo 3 — Ingestão, Transformação e Validação no Apache Hop

## 1. Objetivo

Construir a primeira etapa controlada de ingestão, tratamento e validação dos dados acadêmicos fictícios do Instituto Aurora, separando registros válidos dos rejeitados e preservando a rastreabilidade da origem.

## 2. Fontes utilizadas

- `data/in/alunos.csv`
- `data/in/cursos.csv`
- `data/in/matriculas.csv`

As fontes foram escolhidas porque permitem demonstrar problemas reais de qualidade: duplicidade, campos obrigatórios ausentes, formatos de data diferentes, códigos inconsistentes e chaves sem correspondência.

## 3. Regras de transformação

### Alunos

1. Remover espaços externos dos campos textuais.
2. Padronizar `id_aluno` para inteiro.
3. Padronizar `data_nasc` para `DATE` aceitando `DD/MM/YYYY`, `YYYY-MM-DD` e `DD-MM-YYYY`.
4. Padronizar CPF para o formato `999.999.999-99` quando possuir 11 dígitos.
5. Exigir `id_aluno`, `nome`, `cpf`, `data_nasc` e `email`.
6. Validar data de nascimento: não pode ser futura.
7. Validar `status` no domínio: `Ativa`, `Trancada`, `Concluída`, `Evasão`.
8. Deduplicar por `id_aluno`, mantendo a primeira ocorrência e encaminhando as ocorrências posteriores para rejeição.

### Cursos

1. Remover espaços externos de `cod_curso`.
2. Converter código para maiúsculas.
3. Normalizar códigos equivalentes, por exemplo `ADM-002` → `ADM002`.
4. Exigir `cod_curso`, `nome_curso` e `carga_horaria`.
5. Validar `carga_horaria` como número positivo.
6. Deduplicar por código normalizado, mantendo a primeira ocorrência.

### Matrículas

1. Remover espaços externos.
2. Padronizar `cod_curso` para maiúsculas e remover hífen quando a regra de normalização permitir.
3. Converter `data_matricula` para `DATE` nos três formatos esperados.
4. Exigir `num_matricula`, `id_aluno`, `cod_curso`, `data_matricula` e `semestre`.
5. Validar existência do aluno na fonte de alunos válida.
6. Validar existência do curso na fonte de cursos válida.
7. Validar o domínio de `semestre` no padrão `AAAA.N`.
8. Encaminhar registros inválidos para a saída de rejeição com motivo explícito.

## 4. Junções e integridade referencial

A validação das matrículas será feita relacionando `matriculas` com `alunos` por `id_aluno` e com `cursos` por `cod_curso` normalizado.

A regra é: uma matrícula somente pode seguir para a saída válida se possuir aluno e curso correspondentes. A cardinalidade esperada é `N:1` de matrícula para aluno e `N:1` de matrícula para curso.

## 5. Rejeições esperadas nos dados de laboratório

Exemplos identificados antes da execução do Hop:

- aluno `101`: segunda ocorrência é duplicada;
- aluno `109`: nome e e-mail ausentes;
- aluno `110`: CPF inválido e data `40/13/1990` inválida;
- aluno `111`: data de nascimento futura;
- aluno `112`: CPF ausente e status fora do domínio;
- curso `ads001`: duplicidade após normalização para `ADS001`;
- curso `ADM-002`: código precisa ser normalizado para `ADM002`;
- curso ` ENF006`: espaço externo precisa ser removido;
- matrícula `M0010`: aluno `109` é inválido pela regra de aluno obrigatório;
- matrícula `M0011`: aluno `999` não existe;
- matrícula `M0013`: código de curso ausente;
- matrícula `M0015`: data de matrícula ausente.

A lista acima é uma expectativa baseada na inspeção das fontes. Os quantitativos finais devem ser obtidos na execução real do pipeline.

## 6. Arquitetura proposta no Apache Hop

```text
alunos.csv ───────> pip_ingestao_alunos.hpl ─────> alunos_validos
                                      └───────────> alunos_rejeitados

cursos.csv ───────> pip_ingestao_cursos.hpl ─────> cursos_validos
                                      └───────────> cursos_rejeitados

matriculas.csv ──> pip_ingestao_matriculas.hpl ──> normalização
                                                     │
                           alunos_validos ───────────┤
                           cursos_validos ───────────┤
                                                     ▼
                                              validação/junção
                                               │             │
                                               ▼             ▼
                                      matriculas_validas  matriculas_rejeitadas
```

## 7. Evidências a coletar na execução

- tela do pipeline aberto no Apache Hop;
- preview da entrada;
- preview da saída válida;
- preview/arquivo de rejeitados com `motivo_rejeicao`;
- log da execução sem erro técnico;
- contagem de entrada, válidos e rejeitados;
- evidência de que matrícula sem aluno ou curso não chega à saída válida.

## 8. Critério de sucesso

O pipeline será considerado funcional quando todos os registros forem classificados como válidos ou rejeitados, sem perda silenciosa, e cada rejeição possuir um motivo compreensível e rastreável.

## 9. Observações

Os arquivos de entrada contêm dados fictícios de laboratório. Não devem ser tratados como dados reais de pessoas. O projeto deve manter os arquivos de entrada como evidência da origem e evitar exposição desnecessária de dados pessoais em logs.
