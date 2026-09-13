# Oficina Prática Módulo 8 - Segurança Operacional e Controle de Acesso

## 1. Escopo da revisão

Revisão aplicada ao projeto Instituto Aurora no Apache Hop com foco em:

- credenciais e conexões;
- uso de variáveis sensíveis;
- dados pessoais em arquivos e saídas;
- exposição de dados em logs;
- definição de papéis de acesso simulados;
- registro de riscos operacionais e mitigações.

## 2. Evidência de credenciais fora dos pipelines

Não foram encontradas senhas reais gravadas diretamente nos pipelines, workflows ou no README. A conexão com PostgreSQL está parametrizada no metadado `metadata/rdbms/CONN_POSTGRES_AURORA.json` com variáveis:

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`

Evidência observada:

- `hostname`: `${DB_HOST}`
- `port`: `${DB_PORT}`
- `databaseName`: `${DB_NAME}`
- `username`: `${DB_USER}`
- `password`: `${DB_PASSWORD}`

Conclusão: o repositório já atende ao controle básico de não versionar senha real no pipeline institucional. O valor real das credenciais deve permanecer apenas no ambiente local, fora do Git.

## 3. Variáveis sensíveis documentadas sem valor real

| Variável | Finalidade | Onde é usada | Regra de segurança |
|---|---|---|---|
| `DB_HOST` | Host do banco | metadado da conexão | documentar sem valor real |
| `DB_PORT` | Porta do banco | metadado da conexão | documentar sem valor real |
| `DB_NAME` | Nome do banco | metadado da conexão | documentar sem valor real |
| `DB_USER` | Usuário de acesso | metadado da conexão | documentar sem valor real |
| `DB_PASSWORD` | Senha do banco | metadado da conexão | nunca registrar em pipeline, log ou README |
| `PROJECT_HOME` | Raiz do projeto | workflows e pipelines | evitar caminhos absolutos locais |

Orientação de documentação: registrar apenas nome, finalidade, escopo e responsável pela configuração. Não registrar valor, token, senha ou string de conexão completa.

## 4. Dados pessoais identificados e medidas de minimização

### Dados pessoais identificados

Nos arquivos de entrada e saída foram identificados os seguintes campos pessoais:

- `nome`
- `cpf`
- `data_nasc` ou `data_nascimento`
- `email`

Esses campos aparecem principalmente em `data/in/alunos.csv` e também podem ser reproduzidos em arquivos gerados em `data/out/`.

### Necessidade para os indicadores acadêmicos

Para indicadores acadêmicos básicos, os campos estritamente necessários tendem a ser:

- `id_aluno`
- `cod_curso`
- `status`
- `data_matricula`
- `semestre`

Os campos `nome`, `cpf` e `email` não são necessários para contagem de matrículas, taxa por curso, situação acadêmica e volumetria operacional. `data_nascimento` só deve ser mantida se houver indicador etário formalmente justificado.

### Medidas adotadas e propostas

- Adotada: `data/out` está ignorada no Git para evitar versionamento de saídas operacionais.
- Adotada: logs locais têm orientação explícita para não registrar CPF, e-mail, nome completo, senha ou token.
- Proposta: manter `data/in` apenas com dados fictícios em laboratório e nunca usar dados reais nessa pasta compartilhada.
- Proposta: gerar dataset derivado para indicadores sem `nome`, `cpf` e `email`.
- Proposta: pseudonimizar `id_aluno` quando a análise não exigir identificador operacional direto.
- Proposta: mascarar CPF e e-mail em amostras de evidência, prints e documentação.

## 5. Revisão dos logs

Foram revisados os arquivos:

- `logs/README.md`
- `logs/execucao-2026-09-13-sucesso.log`
- `logs/execucao-2026-09-13-falha-controlada.log`

Resultado da revisão:

- os logs de exemplo registram status, workflow, ambiente, contagens e duração;
- não expõem CPF, e-mail, nome completo, senha ou token;
- o log de falha informa o arquivo ausente e o código de saída, sem vazar dado pessoal;
- a política de logging do projeto já orienta o uso de mensagens sanitizadas.

Recomendação operacional: manter logs com contagens, etapa, `execucao_id`, status e causa técnica resumida; evitar imprimir linhas completas de CSV ou payloads com dados pessoais.

## 6. Papéis simulados de acesso

| Papel | Pode editar pipelines/metadados | Pode executar workflows | Pode alterar conexões | Pode consultar logs | Responsabilidade principal |
|---|---|---|---|---|---|
| Desenvolvedor | Sim | Sim, em desenvolvimento | Não em produção | Limitado ao próprio ambiente | implementar e corrigir pipelines |
| Operador | Não | Sim | Não | Sim | executar rotinas e registrar incidentes |
| Revisor | Sim, para revisão controlada | Não | Não | Sim | revisar mudanças técnicas e segurança |
| Responsável pela validação | Não | Pode acompanhar execução homologada | Não | Sim, em leitura | aprovar evidências e resultados institucionais |

Princípio aplicado: segregação mínima de funções. Quem altera conexão ou pipeline não deve ser a única pessoa a validar a evidência final.

## 7. Riscos operacionais identificados e mitigação

| Risco | Evidência no projeto | Impacto | Probabilidade | Mitigação proposta |
|---|---|---|---|---|
| Exposição de credencial em metadado local futuro | conexão existe e depende de configuração manual | Alto | Médio | manter apenas variáveis no repositório e usar arquivo local fora do Git |
| Dados pessoais em pasta compartilhada | `data/in/alunos.csv` contém nome, CPF, e-mail e data de nascimento | Alto | Médio | reduzir campos, usar dados fictícios e criar versão minimizada para indicadores |
| Reprodução de PII em saídas operacionais | pipelines geram arquivos em `data/out` | Médio | Médio | evitar versionamento, limitar retenção e mascarar amostras |
| Exposição de PII em logs | risco operacional clássico do fluxo | Alto | Baixo | manter logs sanitizados com contagens e identificadores técnicos |
| Permissão excessiva sobre artefatos | papéis ainda são simulados, sem controle técnico automatizado | Médio | Médio | definir responsáveis por editar, executar, revisar e validar |
| Caminhos locais sensíveis em execução | workflows usam `${PROJECT_HOME}` e dependem de ambiente local | Baixo | Médio | manter variáveis de ambiente e não documentar caminhos pessoais completos |
| Uso indevido de documentação com segredo | README e evidências podem receber cópia indevida de senha | Alto | Baixo | revisar documentos antes da entrega e proibir valores reais em prints ou anexos |

## 8. Respostas às perguntas norteadoras

1. Existem credenciais gravadas diretamente?
   Não foram identificadas credenciais reais gravadas. A conexão usa variáveis no metadado.

2. Quais variáveis devem proteger dados sensíveis?
   `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD`.

3. Há arquivos com dados pessoais em pasta compartilhada ou versionada?
   Sim. `data/in/alunos.csv` contém nome, CPF, e-mail e data de nascimento; `data/out` pode reproduzir parte desses dados durante a execução.

4. Algum log expõe dados sensíveis?
   Nos logs revisados, não. O padrão observado está adequado e deve ser mantido.

5. Quem pode editar, executar e consultar?
   Foi definida uma separação simulada entre desenvolvedor, operador, revisor e responsável pela validação.

6. Como documentar variáveis sensíveis?
   Documentar apenas nome, finalidade, escopo e responsável, sem registrar valor real.

## 9. Conclusão

O projeto já apresenta um bom ponto de partida para o Módulo 8 porque a conexão do banco está parametrizada e os logs de exemplo estão sanitizados. O principal risco remanescente está nos arquivos CSV com dados pessoais fictícios e na necessidade de formalizar melhor a segregação de acessos e a minimização dos dados usados em indicadores.

## 10. Evidências consultadas

- `metadata/rdbms/CONN_POSTGRES_AURORA.json`
- `workflows/wf_pipeline_indicadores_academicos.hwf`
- `README.md`
- `docs/diario_tecnico.md`
- `docs/evidencias_execucao.md`
- `logs/README.md`
- `logs/execucao-2026-09-13-sucesso.log`
- `logs/execucao-2026-09-13-falha-controlada.log`
- `data/in/alunos.csv`
- `.gitignore`
