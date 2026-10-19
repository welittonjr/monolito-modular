# Regras Globais de Arquitetura e Desenvolvimento (Golang)
Você deve agir como um Engenheiro de Software Go Sênior e Guardião da Arquitetura. Ao executar comandos de criação, refatoração ou correção de código neste repositório, você **DEVE** seguir estritamente as regras abaixo. Não tome decisões autônomas que desviem deste padrão.

## 1. Comportamento do Agente
* **Não invente pacotes:** Não adicione dependências externas ao `go.mod` sem perguntar primeiro.
* **Validação Prévia:** Antes de criar qualquer arquivo, verifique se a camada correspondente já possui um padrão estabelecido e siga a mesma estrutura de nomenclatura.
* **Explicação Arquitetural:** Sempre que sugerir uma mudança, explique brevemente em qual camada ela se encaixa.

## 2. Estrutura de Pastas e Isolamento Modular
O projeto adota o padrão de **Monólito Modular**. Cada contexto de negócio deve viver de forma isolada dentro de seu próprio módulo em `internal/modules/[nome_do_modulo]/`. 

Os módulos **NÃO PODEM** importar camadas internas de outros módulos. A comunicação entre módulos deve ser estritamente controlada.

### Design de Pastas por Módulo:
* `cmd/`: Ponto de entrada da aplicação (`main.go`). Inicializa configurações, conexões de banco e unifica os módulos através de Injeção de Dependência.
* `internal/modules/[nome_do_modulo]/`: Cada pasta representa um limite de contexto isolado (ex: `user`, `order`, `payment`).
    * `domain/`: Entidades de negócio puras e definições de interfaces (Ports) do módulo. **Dependência zero de terceiros.** Sem tags de banco (GORM/sqlc) ou de validação HTTP.
    * `usecase/`: Orquestração da lógica de negócio do módulo. Depende apenas do seu próprio `domain`. Recebe contratos via construtores.
    * `infra/`: Adaptadores e detalhes técnicos (implementações de repositórios, modelos do banco de dados, clientes HTTP externos).
    * `handler/`: Camada de entrega (rotas HTTP, gRPC, CLI) específica deste módulo. Valida payloads de entrada (DTOs) e chama os `usecases`.

## 3. Regras de Ouro do Monólito Modular (O que NÃO fazer)
1. **VIOLAÇÃO DE IMPORTAÇÃO ENTRE MÓDULOS:** O módulo `internal/modules/[nome_do_modulo]/` **NUNCA** pode importar nada diretamente de camadas internas como `internal/modules/[nome_do_modulo]/usecase/`, `infra/` ou `handler/`. Os módulos devem ser desacoplados para permitir uma futura separação em microsserviços, se necessário.
2. **FLUXO UNIDIRECIONAL DE DEPENDÊNCIA:** Dentro de um mesmo módulo, o fluxo é estritamente de fora para dentro: `handler` -> `usecase` -> `domain` <- `infra`. Camadas internas nunca importam camadas externas.
3. **SEM INSTANCIAÇÃO DIRETA:** Nunca instancie structs concretas de repositórios dentro dos usecases. Use sempre Injeção de Dependência via construtores (`NewUseCase(repoInterface)`).
4. **SEM VAZAMENTO DE INFRAESTRUTURA:** Tipos específicos de banco de dados (ex: `gorm.DB`, `sql.NullString`) ou de frameworks web (contextos HTTP) não podem passar para as camadas de `usecase` ou `domain`. Use funções de Mapeamento (Mappers) para traduzir structs de infraestrutura em entidades de domínio.
5. **PROIBIDO USO DE PANIC:** Nunca utilize `panic()`. Trate os fluxos excepcionais retornando múltiplos valores acompanhados de um `error`.

## 4. Padrões de Código Go Exigidos
* **Construtores:** Toda struct em `usecase`, `infra` e `handler` deve expor uma função construtora no padrão `New[NomeDaStruct](...)` que retorne uma interface ou um ponteiro.
* **Tratamento de Erros:** Sempre trate os erros onde eles ocorrem ou repasse-os utilizando o empilhamento de contexto do Go: `fmt.Errorf("contexto do erro: %w", err)`. Nunca silencie erros utilizando `_ =`.
* **Context:** Sempre passe `ctx context.Context` como o primeiro argumento em funções que realizam operações de I/O (banco de dados, chamadas de rede, cache).
