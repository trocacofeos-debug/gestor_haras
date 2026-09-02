enum ModuloAcesso {
  dashboard,
  clientes,
  animais,
  funcionarios,
  fornecedores,
  produtos,
  gestao,
  propostas,
  site,
}

extension ModuloAcessoExt on ModuloAcesso {
  String get id => name;

  String get titulo => switch (this) {
    ModuloAcesso.dashboard => 'Dashboard',
    ModuloAcesso.clientes => 'Clientes',
    ModuloAcesso.animais => 'Animais',
    ModuloAcesso.funcionarios => 'Funcionários',
    ModuloAcesso.fornecedores => 'Fornecedores',
    ModuloAcesso.produtos => 'Produtos',
    ModuloAcesso.gestao => 'Gestão financeira',
    ModuloAcesso.propostas => 'Propostas',
    ModuloAcesso.site => 'Conteúdo do site',
  };

  String get descricao => switch (this) {
    ModuloAcesso.dashboard => 'Resumo recebido, pendente e total',
    ModuloAcesso.clientes => 'Cadastro, consulta e edição de clientes',
    ModuloAcesso.animais => 'Cadastro e fichas dos animais',
    ModuloAcesso.funcionarios => 'Funcionários e permissões de acesso',
    ModuloAcesso.fornecedores => 'Cadastro e consulta de fornecedores',
    ModuloAcesso.produtos => 'Cadastro de produtos',
    ModuloAcesso.gestao => 'Financeiro, lançamentos, relatórios e dívidas',
    ModuloAcesso.propostas => 'Propostas, contratos e aprovações',
    ModuloAcesso.site => 'Animais à venda, galeria e notícias',
  };
}

class ControleAcesso {
  ControleAcesso._();

  static bool _acessoTotal = true;
  static Set<String> _permissoes = const {};

  static bool get acessoTotal => _acessoTotal;
  static Set<String> get permissoes => Set.unmodifiable(_permissoes);

  static void liberarTudo() {
    _acessoTotal = true;
    _permissoes = const {};
  }

  static void configurarFuncionario(Iterable<String> permissoes) {
    _acessoTotal = false;
    _permissoes = permissoes.toSet();
  }

  static bool pode(ModuloAcesso modulo) =>
      _acessoTotal || _permissoes.contains(modulo.id);

  static void limpar() => liberarTudo();
}
