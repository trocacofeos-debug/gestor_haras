// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';
import 'package:intl/intl.dart';

import '../../models/cliente_model.dart';
import '../../models/divida_model.dart';

import '../../services/divida_service.dart';
import '../../services/proposta_service.dart';

import '../propostas/admin/detalhes_proposta_page.dart';
import '../home/admin_top_bar.dart';

import '../financeiro/nova_conta_page.dart';
import '../../widgets/desktop_window.dart';

class ClienteModuloPageDesktop extends StatefulWidget {
  final ClienteModel cliente;

  final String modulo;

  const ClienteModuloPageDesktop({
    super.key,

    required this.cliente,

    required this.modulo,
  });

  @override
  State<ClienteModuloPageDesktop> createState() =>
      _ClienteModuloPageDesktopState();
}

class _ClienteModuloPageDesktopState extends State<ClienteModuloPageDesktop> {
  final DividaService _dividaService = DividaService();

  final PropostaService _propostaService = PropostaService();

  // Acumula, por dívida, a soma das parcelas
  // realmente pagas (preenchido pelos StreamBuilders
  // "silenciosos" criados em _agregadorPagamentos).
  final Map<String, double> _pagoPorDivida = {};

  // Controla se os valores do resumo financeiro
  // estão visíveis ou ocultos (toque para revelar).
  bool _valoresRevelados = false;

  // IDs das dívidas cuja lista de parcelas está
  // aberta (expandida) no momento.
  final Set<String> _parcelasExpandidas = {};

  final Color primaria = const Color(0xFF1565C0);

  final Color fundo = const Color(0xffF4F7FB);

  final NumberFormat money = NumberFormat.currency(
    locale: "pt_BR",

    symbol: "R\$",
  );

  // =====================================================
  // UTILITÁRIOS
  // =====================================================

  String inicialCliente() {
    final nome = widget.cliente.nomeExibicao.trim();

    if (nome.isEmpty) {
      return "?";
    }

    return nome.substring(0, 1).toUpperCase();
  }

  String tipoCliente() {
    switch (widget.cliente.tipoCliente) {
      case TipoCliente.fisica:
        return "Pessoa Física";

      case TipoCliente.juridica:
        return "Pessoa Jurídica";

      case TipoCliente.rural:
        return "Haras / Rural";
    }
  }

  double converterValor(dynamic valor) {
    if (valor == null) {
      return 0;
    }

    if (valor is double) {
      return valor;
    }

    if (valor is int) {
      return valor.toDouble();
    }

    if (valor is String) {
      return double.tryParse(valor.replaceAll(".", "").replaceAll(",", ".")) ??
          0;
    }

    return 0;
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      body: Column(
        children: [
          const AdminTopBar(),

          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              widget.modulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      _clienteCard(),

                      const SizedBox(height: 25),

                      Text(
                        widget.modulo,

                        style: const TextStyle(
                          fontSize: 22,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _conteudo(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: _fabModulo(),
    );
  }

  // =====================================================
  // BOTÃO FLUTUANTE
  // =====================================================

  Widget? _fabModulo() {
    if (widget.modulo == "Dívidas") {
      return FloatingActionButton(
        backgroundColor: primaria,

        onPressed: () {
          openDesktopWindow(
            context,

            title: 'Nova dívida',
            icon: Icons.account_balance_wallet_rounded,
            builder: (_) => NovaContaPage(
              clienteIdInicial: widget.cliente.id,

              clienteNomeInicial: widget.cliente.nomeExibicao,
            ),
          );
        },

        child: const Icon(Icons.add, color: Colors.white),
      );
    }

    if (widget.modulo == "Propostas") {
      return FloatingActionButton(
        backgroundColor: primaria,

        onPressed: _abrirFormularioProposta,

        child: const Icon(Icons.add, color: Colors.white),
      );
    }

    return null;
  }

  // =====================================================
  // CARD CLIENTE
  // =====================================================

  Widget _clienteCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 35,

            backgroundColor: primaria,

            child: Text(
              inicialCliente(),

              style: const TextStyle(
                color: Colors.white,

                fontSize: 28,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.cliente.nomeExibicao.isEmpty
                      ? "Cliente"
                      : widget.cliente.nomeExibicao,

                  style: const TextStyle(
                    fontSize: 20,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(tipoCliente(), style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 5),

                Text(
                  widget.cliente.telefone.isEmpty
                      ? "Sem telefone"
                      : widget.cliente.telefone,

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CONTROLE DOS MÓDULOS
  // =====================================================

  Widget _conteudo() {
    switch (widget.modulo) {
      case "Dívidas":
        return _moduloDividas();

      case "Propostas":
        return _moduloPropostas();

      default:
        return const SizedBox();
    }
  }

  // =====================================================
  // MÓDULO DÍVIDAS
  // =====================================================

  // =====================================================
  // OUVINTE SILENCIOSO DE PAGAMENTOS
  // =====================================================
  //
  // Escuta as parcelas de UMA dívida e mantém
  // _pagoPorDivida[dividaId] atualizado com a soma
  // real do que já foi pago. Não desenha nada na tela.

  Widget _agregadorPagamentos(String dividaId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _dividaService.parcelas(dividaId),

      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double soma = 0;

          for (final doc in snapshot.data!.docs) {
            final d = doc.data();

            final status = (d["status"] ?? "pendente").toString().toLowerCase();

            if (status == "pago") {
              soma += converterValor(d["valor"]);
            }
          }

          if (_pagoPorDivida[dividaId] != soma) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _pagoPorDivida[dividaId] = soma;
                });
              }
            });
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _moduloDividas() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _dividaService.buscarCliente(widget.cliente.id),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _erro(snapshot.error.toString());
        }

        final dividas = (snapshot.data?.docs ?? [])
            .map((doc) => DividaModel.fromMap(doc.data(), doc.id))
            .toList();

        double total = 0;

        double pago = 0;

        double aberto = 0;

        // Dívidas que ainda não foram totalmente quitadas
        // precisam de um "ouvinte" das parcelas para saber
        // quanto já foi pago de fato.
        final dividasParaAcompanhar = <String>[];

        for (final divida in dividas) {
          total += divida.valorTotal;

          final status = divida.status.toLowerCase();

          final quitadaCompleta =
              status == "pago" ||
              status == "quitado" ||
              status == "quitada" ||
              status == "finalizado";

          double pagoDaDivida;

          if (quitadaCompleta) {
            // Dívida encerrada manualmente (botão "Quitar"):
            // conta o valor total como pago.

            pagoDaDivida = divida.valorTotal;
          } else {
            // Ainda aberta: usa a soma real das parcelas
            // pagas individualmente (ou 0 se ainda não
            // carregou nada).

            pagoDaDivida = _pagoPorDivida[divida.id] ?? 0;

            dividasParaAcompanhar.add(divida.id);
          }

          pago += pagoDaDivida;

          aberto += (divida.valorTotal - pagoDaDivida);
        }

        return Column(
          children: [
            // Ouvintes invisíveis: mantêm _pagoPorDivida
            // atualizado com os pagamentos reais de parcelas.
            ...dividasParaAcompanhar.map((id) => _agregadorPagamentos(id)),

            if (aberto > 0) _alertaInadimplente(aberto),

            _resumoFinanceiro(total, pago, aberto),

            const SizedBox(height: 20),

            if (dividas.isEmpty)
              _semDados("Nenhuma dívida cadastrada")
            else
              ...dividas.map((d) => _dividaCard(d)),
          ],
        );
      },
    );
  }

  // =====================================================
  // ALERTA INADIMPLENTE
  // =====================================================

  Widget _alertaInadimplente(double valor) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.red.shade50,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.red.shade200),
      ),

      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.red, size: 35),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "CLIENTE INADIMPLENTE",

                  style: TextStyle(
                    color: Colors.red,

                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Possui ${money.format(valor)} em aberto",

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // RESUMO FINANCEIRO
  // =====================================================

  Widget _resumoFinanceiro(double total, double pago, double aberto) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        setState(() {
          _valoresRevelados = !_valoresRevelados;
        });
      },

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Resumo Financeiro",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Icon(
                  _valoresRevelados
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,

                  color: Colors.grey.shade400,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _miniFinanceiro(
                    "Total",

                    money.format(total),

                    Colors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _miniFinanceiro(
                    "Pago",

                    money.format(pago),

                    Colors.green,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _miniFinanceiro(
                    "Aberto",

                    money.format(aberto),

                    Colors.red,
                  ),
                ),
              ],
            ),

            if (!_valoresRevelados)
              Padding(
                padding: const EdgeInsets.only(top: 12),

                child: Text(
                  "Toque para ver os valores",

                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniFinanceiro(String titulo, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: cor.withOpacity(.12),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [
          Text(
            titulo,

            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 5),

          Text(
            _valoresRevelados ? valor : "••••••",

            textAlign: TextAlign.center,

            style: TextStyle(
              color: cor,

              fontWeight: FontWeight.bold,

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CARD DIVIDA
  // =====================================================

  Widget _dividaCard(DividaModel divida) {
    final status = divida.status.toLowerCase();

    final paga =
        status == "pago" ||
        status == "quitado" ||
        status == "quitada" ||
        status == "finalizado";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                paga ? Icons.check_circle : Icons.warning,

                color: paga ? Colors.green : Colors.red,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  divida.descricao.isEmpty ? "Sem descrição" : divida.descricao,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),
              ),

              Text(
                money.format(divida.valorTotal),

                style: TextStyle(
                  color: paga ? Colors.green : Colors.red,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "Categoria: ${divida.categoria.isEmpty ? "-" : divida.categoria}",

            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          InkWell(
            borderRadius: BorderRadius.circular(12),

            onTap: () {
              setState(() {
                if (_parcelasExpandidas.contains(divida.id)) {
                  _parcelasExpandidas.remove(divida.id);
                } else {
                  _parcelasExpandidas.add(divida.id);
                }
              });
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),

              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,

                    size: 18,

                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "Parcelas",

                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    _parcelasExpandidas.contains(divida.id)
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,

                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          if (_parcelasExpandidas.contains(divida.id))
            Padding(
              padding: const EdgeInsets.only(top: 8),

              child: _parcelasDaDivida(divida.id, paga),
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                paga ? "QUITADA" : "ABERTA",

                style: TextStyle(
                  color: paga ? Colors.green : Colors.red,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              if (!paga)
                TextButton.icon(
                  onPressed: () => _confirmarQuitarDivida(divida.id),

                  icon: const Icon(Icons.done_all),

                  label: const Text("Quitar"),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PARCELAS DA DIVIDA
  // =====================================================

  Widget _parcelasDaDivida(String dividaId, bool dividaPaga) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _dividaService.parcelas(dividaId),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text(
            "Sem parcelas cadastradas",

            style: TextStyle(color: Colors.grey),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();

            final valor = converterValor(data["valor"]);

            final numero = data["numero"]?.toString() ?? "-";

            final status = (data["status"] ?? "pendente")
                .toString()
                .toLowerCase();

            final pago = status == "pago";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),

              child: Row(
                children: [
                  Icon(
                    pago ? Icons.check_circle : Icons.circle_outlined,

                    size: 18,

                    color: pago ? Colors.green : Colors.grey,
                  ),

                  const SizedBox(width: 8),

                  Expanded(child: Text("Parcela $numero")),

                  Text(
                    money.format(valor),

                    style: TextStyle(
                      color: pago ? Colors.green : Colors.black87,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (!pago && !dividaPaga)
                    IconButton(
                      icon: const Icon(Icons.payments, color: Colors.blue),

                      onPressed: () => _pagarParcela(dividaId, doc.id),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // =====================================================
  // PAGAR PARCELA
  // =====================================================

  Future<void> _pagarParcela(String dividaId, String parcelaId) async {
    try {
      await _dividaService.pagarParcela(dividaId, parcelaId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Parcela paga com sucesso")));
    } catch (e) {
      if (!mounted) return;

      _erro(e.toString());
    }
  }

  // =====================================================
  // QUITAR DIVIDA
  // =====================================================

  Future<void> _confirmarQuitarDivida(String dividaId) async {
    final confirmar = await showAppDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Quitar dívida"),

        content: const Text(
          "Deseja realmente marcar esta dívida como quitada?",
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),

            child: const Text("Quitar"),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    try {
      await _dividaService.quitarDivida(dividaId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Dívida quitada")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =====================================================
  // MÓDULO PROPOSTAS
  // =====================================================

  Color _corStatusProposta(String status) {
    switch (status) {
      case 'aguardando_aprovacao':
        return Colors.orange;

      case 'aprovada':
        return Colors.green;

      case 'aguardando_assinatura':
        return Colors.indigo;

      case 'assinado':
        return Colors.teal;

      case 'reprovada':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String _tituloStatusProposta(String status) {
    switch (status) {
      case 'aguardando_aprovacao':
        return 'Aguardando aprovação';

      case 'aprovada':
        return 'Aprovada';

      case 'aguardando_assinatura':
        return 'Aguardando assinatura';

      case 'assinado':
        return 'Contrato assinado';

      case 'reprovada':
        return 'Reprovada';

      default:
        return status.isEmpty ? 'Pendente' : status;
    }
  }

  Widget _moduloPropostas() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _propostaService.listarPorCliente(widget.cliente.id),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _erro(snapshot.error.toString());
        }

        final propostas = snapshot.data?.docs ?? [];

        if (propostas.isEmpty) {
          return _semDados("Nenhuma proposta cadastrada");
        }

        // Ordena localmente da mais recente para a mais antiga
        final propostasOrdenadas = propostas.toList()
          ..sort((a, b) {
            final da = a.data()["dataCriacao"];
            final db_ = b.data()["dataCriacao"];

            if (da is Timestamp && db_ is Timestamp) {
              return db_.compareTo(da);
            }

            return 0;
          });

        return Column(
          children: propostasOrdenadas.map((doc) {
            final data = doc.data();

            final valor = converterValor(data["valor"] ?? data["valorTotal"]);

            final status = (data["status"] ?? "aguardando_aprovacao")
                .toString();

            final cor = _corStatusProposta(status);

            return InkWell(
              borderRadius: BorderRadius.circular(18),

              onTap: () {
                openDesktopWindow(
                  context,

                  title: 'Detalhes da proposta',
                  icon: Icons.description_rounded,
                  builder: (_) => DetalhesPropostaPage(propostaId: doc.id),
                );
              },

              child: Container(
                margin: const EdgeInsets.only(bottom: 15),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),

                      blurRadius: 8,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (data["observacoes"] != null &&
                                    data["observacoes"]
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                ? data["observacoes"]
                                : "Proposta",

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 17,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: cor.withOpacity(.12),

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            _tituloStatusProposta(status),

                            style: TextStyle(
                              color: cor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      money.format(valor),

                      style: const TextStyle(
                        color: Colors.blue,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.chevron_right_rounded,

                          size: 18,

                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          "Toque para ver detalhes",

                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // =====================================================
  // NOVA PROPOSTA
  // =====================================================

  Future<void> _abrirFormularioProposta() async {
    final observacoes = TextEditingController();

    final valor = TextEditingController();

    final parcelas = TextEditingController(text: "1");

    final salvar = await showAppDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Nova Proposta"),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: observacoes,

              decoration: const InputDecoration(labelText: "Observações"),
            ),

            TextField(
              controller: valor,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(labelText: "Valor"),
            ),

            TextField(
              controller: parcelas,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "Parcelas"),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),

            child: const Text("Salvar"),
          ),
        ],
      ),
    );

    if (salvar != true) {
      return;
    }

    final dados = {
      "clienteId": widget.cliente.id,

      "clienteNome": widget.cliente.nomeExibicao,

      "observacoes": observacoes.text,

      "valor": converterValor(valor.text),

      "parcelas": int.tryParse(parcelas.text.trim()) ?? 1,

      "status": "aguardando_aprovacao",

      "contratoLiberado": false,

      "assinada": false,

      "dataCriacao": Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection("propostas").add(dados);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Proposta criada")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =====================================================
  // ERRO PADRÃO
  // =====================================================

  Widget _erro(String mensagem) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.red.shade50,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),

          const SizedBox(height: 10),

          Text(
            mensagem,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.red,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SEM DADOS
  // =====================================================

  Widget _semDados(String texto) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 50, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          Text(
            texto,

            textAlign: TextAlign.center,

            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

