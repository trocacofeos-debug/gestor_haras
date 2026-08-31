// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cliente_model.dart';
import '../../models/divida_model.dart';
import '../../services/divida_service.dart';
import '../../widgets/campos_grid.dart';
import 'cliente_modulo_page.dart';
import 'cadastro_cliente_page.dart';
import '../../widgets/desktop_window.dart';

class ClienteDetalhesPageDesktop extends StatelessWidget {
  final ClienteModel cliente;
  const ClienteDetalhesPageDesktop({super.key, required this.cliente});
  final Color primaria = const Color(0xFF374151);
  final Color fundo = const Color(0xFFFFFFFF);

  String tipoTexto() {
    switch (cliente.tipoCliente) {
      case TipoCliente.fisica:
        return "Pessoa Física";
      case TipoCliente.juridica:
        return "Pessoa Jurídica";
      case TipoCliente.rural:
        return "Haras / Rural";
    }
  }

  void abrirModulo(BuildContext context, String modulo) {
    openDesktopWindow(
      context,
      title: '$modulo — ${cliente.nomeExibicao}',
      icon: Icons.folder_open_rounded,
      builder: (_) => ClienteModuloPage(cliente: cliente, modulo: modulo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth - 32,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _dados()),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ResumoDividaCliente(
                                    clienteId: cliente.id,
                                    primaria: primaria,
                                  ),
                                  const SizedBox(height: 16),
                                  _modulos(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: DesktopWindowScope.isInside(context) ? 'Fechar' : 'Voltar',
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              DesktopWindowScope.isInside(context)
                  ? Icons.close
                  : Icons.arrow_back,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _perfil()),
          TextButton.icon(
            onPressed: () {
              openDesktopWindow(
                context,
                title: 'Editar cliente',
                icon: Icons.edit_outlined,
                builder: (_) => CadastroClientePage(cliente: cliente),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
            style: TextButton.styleFrom(foregroundColor: primaria),
          ),
        ],
      ),
    );
  }

  Widget _perfil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          cliente.nomeExibicao.isEmpty
              ? 'Cliente sem nome'
              : cliente.nomeExibicao,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${tipoTexto()} · ${cliente.ativo ? "Ativo" : "Inativo"}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _dados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo("Dados pessoais", Icons.person_outline_rounded),
        CamposGrid(
          larguraMinimaColuna: 220,
          maximoColunas: 2,
          campos: [
            _campo("CPF / CNPJ", cliente.cpfCnpj, Icons.badge_outlined),
            _campo("Telefone", cliente.telefone, Icons.phone_rounded),
            _campo("Email", cliente.email, Icons.email_outlined),
          ],
        ),
        const SizedBox(height: 10),
        _titulo("Endereço", Icons.location_on_outlined),
        CamposGrid(
          larguraMinimaColuna: 220,
          maximoColunas: 2,
          campos: [
            _campo("CEP", cliente.cep, Icons.markunread_mailbox_outlined),
            _campo(
              "Endereço",
              "${cliente.endereco}, ${cliente.numero}",
              Icons.home_outlined,
            ),
            if (cliente.complemento.isNotEmpty)
              _campo("Complemento", cliente.complemento, Icons.info_outline),
            _campo(
              "Cidade / Estado",
              "${cliente.cidade} - ${cliente.estado}",
              Icons.location_city_rounded,
            ),
          ],
        ),
        if (cliente.tipoCliente == TipoCliente.juridica) _empresa(),
        if (cliente.tipoCliente == TipoCliente.rural) _haras(),
      ],
    );
  }

  Widget _empresa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _titulo("Dados empresariais", Icons.business_center_outlined),
        CamposGrid(
          larguraMinimaColuna: 220,
          maximoColunas: 2,
          campos: [
            _campo(
              "Razão Social",
              cliente.razaoSocial,
              Icons.apartment_rounded,
            ),
            _campo("Nome Fantasia", cliente.nomeFantasia, Icons.store_rounded),
          ],
        ),
      ],
    );
  }

  Widget _haras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _titulo("Dados do Haras", Icons.house_rounded),
        CamposGrid(
          larguraMinimaColuna: 220,
          maximoColunas: 2,
          campos: [
            _campo("Nome do Haras", cliente.nomeHaras, Icons.home_work_rounded),
            _campo("Registro Rural", cliente.idRural, Icons.assignment_rounded),
            _campo(
              "Endereço do Haras",
              cliente.enderecoHaras,
              Icons.location_on_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _titulo(String texto, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _campo(String titulo, String valor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 2),
          SelectableText(
            valor.trim().isEmpty ? '—' : valor,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }

  Widget _modulos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo("Módulos do Cliente", Icons.dashboard_customize_rounded),
        _botaoModulo(
          context,
          "Financeiro",
          "Dívidas, pagamentos e cobranças",
          Icons.account_balance_wallet_rounded,
          Colors.red,
          "Dívidas",
        ),
        _botaoModulo(
          context,
          "Propostas",
          "Orçamentos e negociações comerciais",
          Icons.description_rounded,
          Colors.orange,
          "Propostas",
        ),
      ],
    );
  }

  Widget _botaoModulo(
    BuildContext context,
    String titulo,
    String descricao,
    IconData icon,
    Color cor,
    String modulo,
  ) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => abrirModulo(context, modulo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaria, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CARD "SITUAÇÃO FINANCEIRA" COM VALORES OCULTOS
// =====================================================
//
// Mostra Total / Pago / Aberto da dívida do cliente,
// mas os valores só aparecem depois que o usuário toca
// no card (fica em modo "oculto" por padrão).
class _ResumoDividaCliente extends StatefulWidget {
  final String clienteId;
  final Color primaria;
  const _ResumoDividaCliente({required this.clienteId, required this.primaria});
  @override
  State<_ResumoDividaCliente> createState() => _ResumoDividaClienteState();
}

class _ResumoDividaClienteState extends State<_ResumoDividaCliente> {
  bool _revelado = false;
  final DividaService _dividaService = DividaService();
  final NumberFormat _money = NumberFormat.currency(
    locale: "pt_BR",
    symbol: "R\$",
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _dividaService.buscarCliente(widget.clienteId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        final dividas = snapshot.data!.docs
            .map((doc) => DividaModel.fromMap(doc.data(), doc.id))
            .toList();
        if (dividas.isEmpty) {
          return const SizedBox();
        }
        double total = 0;
        double pago = 0;
        double aberto = 0;
        for (final divida in dividas) {
          total += divida.valorTotal;
          final status = divida.status.toLowerCase();
          final quitada =
              status == "pago" ||
              status == "quitado" ||
              status == "quitada" ||
              status == "finalizado";
          if (quitada) {
            pago += divida.valorTotal;
          } else {
            aberto += divida.valorTotal;
          }
        }
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            setState(() {
              _revelado = !_revelado;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 20,
                        color: widget.primaria,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Situação Financeira",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      _revelado
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _miniFinanceiro("Total", total, Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniFinanceiro("Pago", pago, Colors.green),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniFinanceiro("Aberto", aberto, Colors.red),
                    ),
                  ],
                ),
                if (!_revelado)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Toque para ver os valores",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniFinanceiro(String titulo, double valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            _revelado ? _money.format(valor) : "••••••",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
