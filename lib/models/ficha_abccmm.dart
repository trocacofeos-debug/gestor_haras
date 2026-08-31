/// Informações da ficha da associação, independentes da gestão do haras.
class FichaAbccmm {
  static const rotulos = <String, String>{
    'chip': 'Chip',
    'livro': 'Livro',
    'idAnimal': 'ID do animal na ABCCMM',
    'exame': 'Exame',
    'criador': 'Criador',
    'proprietario': 'Proprietário na ABCCMM',
    'paiLivro': 'Livro do pai',
    'paiRegistro': 'Registro do pai',
    'paiPelagem': 'Pelagem do pai',
    'paiExame': 'Exame do pai',
    'maeLivro': 'Livro da mãe',
    'maeRegistro': 'Registro da mãe',
    'maePelagem': 'Pelagem da mãe',
    'maeExame': 'Exame da mãe',
  };
  final String chip;
  final String livro;
  final String idAnimal;
  final String exame;
  final String criador;
  final String proprietario;
  final String paiLivro;
  final String paiRegistro;
  final String paiPelagem;
  final String paiExame;
  final String maeLivro;
  final String maeRegistro;
  final String maePelagem;
  final String maeExame;
  final DateTime? dataNascimento;
  final bool? registrado;
  final bool? vivo;
  final bool? bloqueado;

  const FichaAbccmm({
    this.chip = '',
    this.livro = '',
    this.idAnimal = '',
    this.exame = '',
    this.criador = '',
    this.proprietario = '',
    this.paiLivro = '',
    this.paiRegistro = '',
    this.paiPelagem = '',
    this.paiExame = '',
    this.maeLivro = '',
    this.maeRegistro = '',
    this.maePelagem = '',
    this.maeExame = '',
    this.dataNascimento,
    this.registrado,
    this.vivo,
    this.bloqueado,
  });

  factory FichaAbccmm.fromMap(Map<String, dynamic> map) => FichaAbccmm(
    chip: map['chip'] is String ? map['chip'] as String : '',
    livro: map['livro'] is String ? map['livro'] as String : '',
    idAnimal: map['idAnimal'] is String ? map['idAnimal'] as String : '',
    exame: map['exame'] is String ? map['exame'] as String : '',
    criador: map['criador'] is String ? map['criador'] as String : '',
    proprietario: map['proprietario'] is String
        ? map['proprietario'] as String
        : '',
    paiLivro: map['paiLivro'] is String ? map['paiLivro'] as String : '',
    paiRegistro: map['paiRegistro'] is String
        ? map['paiRegistro'] as String
        : '',
    paiPelagem: map['paiPelagem'] is String ? map['paiPelagem'] as String : '',
    paiExame: map['paiExame'] is String ? map['paiExame'] as String : '',
    maeLivro: map['maeLivro'] is String ? map['maeLivro'] as String : '',
    maeRegistro: map['maeRegistro'] is String
        ? map['maeRegistro'] as String
        : '',
    maePelagem: map['maePelagem'] is String ? map['maePelagem'] as String : '',
    maeExame: map['maeExame'] is String ? map['maeExame'] as String : '',
    dataNascimento: lerData(map['dataNascimento']?.toString() ?? ''),
    registrado: map['registrado'] is bool ? map['registrado'] as bool : null,
    vivo: map['vivo'] is bool ? map['vivo'] as bool : null,
    bloqueado: map['bloqueado'] is bool ? map['bloqueado'] as bool : null,
  );

  Map<String, dynamic> toMap() => {
    'chip': chip,
    'livro': livro,
    'idAnimal': idAnimal,
    'exame': exame,
    'criador': criador,
    'proprietario': proprietario,
    'paiLivro': paiLivro,
    'paiRegistro': paiRegistro,
    'paiPelagem': paiPelagem,
    'paiExame': paiExame,
    'maeLivro': maeLivro,
    'maeRegistro': maeRegistro,
    'maePelagem': maePelagem,
    'maeExame': maeExame,
    // Data civil, sem conversão de fuso horário.
    'dataNascimento': dataNascimento == null
        ? null
        : '${dataNascimento!.year.toString().padLeft(4, '0')}-${dataNascimento!.month.toString().padLeft(2, '0')}-${dataNascimento!.day.toString().padLeft(2, '0')}',
    'registrado': registrado, 'vivo': vivo,
    'bloqueado': bloqueado,
  };

  static DateTime? lerData(String texto) {
    final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto.trim());
    if (br == null && iso == null) return null;
    final ano = int.parse(br?[3] ?? iso![1]!);
    final mes = int.parse(br?[2] ?? iso![2]!);
    final dia = int.parse(br?[1] ?? iso![3]!);
    final data = DateTime(ano, mes, dia);
    if (ano < 1 || data.year != ano || data.month != mes || data.day != dia) {
      return null;
    }
    return data;
  }

  static String formatarData(DateTime? data) => data == null
      ? ''
      : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year.toString().padLeft(4, '0')}';

  static String? validarNascimento(String texto) {
    if (texto.trim().isEmpty) return null;
    final data = lerData(texto);
    if (data == null) return 'Informe uma data válida (DD/MM/AAAA)';
    final agora = DateTime.now();
    if (data.isAfter(DateTime(agora.year, agora.month, agora.day))) {
      return 'O nascimento não pode estar no futuro';
    }
    return null;
  }

  String idadeEm(DateTime hoje) {
    final data = dataNascimento;
    if (data == null || hoje.isBefore(data)) return '';
    var meses = (hoje.year - data.year) * 12 + hoje.month - data.month;
    if (hoje.day < data.day) meses--;
    return '${meses ~/ 12} ano(s) e ${meses % 12} mês(es)';
  }
}
