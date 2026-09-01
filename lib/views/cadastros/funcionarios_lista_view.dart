import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/funcionario_model.dart';
import '../../widgets/desktop_window.dart';
import '../../widgets/funcionario_foto.dart';
import '../home/admin_home.dart';
import '../home/admin_top_bar.dart';
import 'cadastro_funcionario_page.dart';
import 'funcionario_detalhes_page.dart';

class FuncionariosListaView extends StatefulWidget {
  final bool desktop;
  final Stream<List<FuncionarioModel>>? funcionarios;
  const FuncionariosListaView({
    super.key,
    required this.desktop,
    this.funcionarios,
  });
  @override
  State<FuncionariosListaView> createState() => _FuncionariosListaViewState();
}

class _FuncionariosListaViewState extends State<FuncionariosListaView> {
  final _busca = TextEditingController();
  late Stream<List<FuncionarioModel>> _stream;
  static const _borda = Color(0xFFE5E7EB);
  static const _fundo = Color(0xFFF3F4F6);
  static const _secundario = Color(0xFF6B7280);

  Stream<List<FuncionarioModel>> _carregar() =>
      widget.funcionarios ??
      FirebaseFirestore.instance
          .collection('funcionarios')
          .orderBy('nome')
          .snapshots()
          .map(
            (s) => s.docs
                .map((d) => FuncionarioModel.fromMap(d.data(), d.id))
                .toList(),
          );
  @override
  void initState() {
    super.initState();
    _stream = _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  String _normalizar(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[áàâã]'), 'a')
      .replaceAll(RegExp('[éê]'), 'e')
      .replaceAll('í', 'i')
      .replaceAll(RegExp('[óôõ]'), 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
  void _novo() => openDesktopWindow(
    context,
    title: 'Novo funcionário',
    icon: Icons.badge_outlined,
    builder: (_) => const CadastroFuncionarioPage(),
  );
  void _abrir(FuncionarioModel f) =>
      abrirPopupDetalhesFuncionario(context, f.id);
  Future<void> _voltar() async {
    if (!await Navigator.maybePop(context) && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _fundo,
    appBar: widget.desktop
        ? null
        : AppBar(
            leading: IconButton(
              tooltip: 'Voltar ao dashboard',
              onPressed: _voltar,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Funcionários'),
            actions: [
              IconButton(
                tooltip: 'Novo funcionário',
                onPressed: _novo,
                icon: const Icon(Icons.person_add_alt_1_outlined),
              ),
              IconButton(
                tooltip: 'Atualizar',
                onPressed: () => setState(() => _stream = _carregar()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
    body: SafeArea(
      child: Column(
        children: [
          if (widget.desktop) const AdminTopBar(),
          if (widget.desktop)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: _borda)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Voltar ao dashboard',
                    onPressed: _voltar,
                    icon: const Icon(Icons.arrow_back, size: 22),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Funcionários',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Novo funcionário',
                    onPressed: _novo,
                    icon: const Icon(
                      Icons.person_add_alt_1_outlined,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Atualizar',
                    onPressed: () => setState(() => _stream = _carregar()),
                    icon: const Icon(Icons.refresh, color: _secundario),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.desktop ? 20 : 16,
              16,
              widget.desktop ? 20 : 16,
              12,
            ),
            child: TextField(
              controller: _busca,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar funcionário...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _busca.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: () => setState(_busca.clear),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: widget.desktop
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: _borda),
                      )
                    : null,
                enabledBorder: widget.desktop
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: _borda),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FuncionarioModel>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Não foi possível carregar os funcionários. Tente atualizar.',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtro = _normalizar(_busca.text);
                final lista = snapshot.data!
                    .where(
                      (f) => [
                        f.nome,
                        f.cargo,
                        f.matricula,
                        f.telefone,
                        f.email,
                        f.cpf,
                      ].any((v) => _normalizar(v).contains(filtro)),
                    )
                    .toList();
                if (lista.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum funcionário encontrado',
                      style: TextStyle(color: _secundario),
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    widget.desktop ? 20 : 16,
                    10,
                    widget.desktop ? 20 : 16,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: widget.desktop
                          ? _tabela(lista)
                          : Column(children: lista.map(_linhaMobile).toList()),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _tabela(List<FuncionarioModel> lista) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _borda),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowHeight: 40,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(_fundo),
          columns: const [
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Cargo')),
            DataColumn(label: Text('Telefone')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Ações')),
          ],
          rows: lista
              .map(
                (f) => DataRow(
                  onSelectChanged: (_) => _abrir(f),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          FuncionarioFoto(url: f.fotoUrl, tamanho: 32),
                          const SizedBox(width: 10),
                          Text(
                            f.nome.isEmpty ? 'Funcionário sem nome' : f.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(f.cargo.isEmpty ? '—' : f.cargo)),
                    DataCell(Text(f.telefone.isEmpty ? '—' : f.telefone)),
                    DataCell(Text(f.email.isEmpty ? '—' : f.email)),
                    DataCell(
                      Text(
                        f.ativo ? 'Ativo' : 'Inativo',
                        style: const TextStyle(
                          color: _secundario,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        tooltip: 'Ver detalhes',
                        onPressed: () => _abrir(f),
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
  Widget _linhaMobile(FuncionarioModel f) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _abrir(f),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borda),
        ),
        child: Row(
          children: [
            FuncionarioFoto(url: f.fotoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.nome.isEmpty ? 'Funcionário sem nome' : f.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    f.cargo,
                    style: const TextStyle(color: _secundario, fontSize: 12),
                  ),
                  Text(
                    f.telefone.isEmpty ? 'Sem telefone' : f.telefone,
                    style: const TextStyle(color: _secundario, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: f.ativo
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                f.ativo ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  color: f.ativo ? const Color(0xFF166534) : _secundario,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _secundario,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
