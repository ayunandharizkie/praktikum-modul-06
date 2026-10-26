
import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';

class LoginPengayaanScreen extends StatefulWidget {
  const LoginPengayaanScreen({
    super.key,
    required this.controller,
  });

  final SesiController controller;

  @override
  State<LoginPengayaanScreen> createState() =>
      _LoginPengayaanScreenState();
}

class _LoginPengayaanScreenState
    extends State<LoginPengayaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();

  bool _menyembunyikanSandi = true;
  bool _sedangLogin = false;
  bool _dibatalkan = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (_sedangLogin) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sedangLogin = true;
      _dibatalkan = false;
    });

    try {
      await widget.controller.masuk(
        email: _emailController.text,
        sandi: _sandiController.text,
      );
    } finally {
      if (mounted && !_dibatalkan) {
        setState(() {
          _sedangLogin = false;
        });
      }
    }
  }

  void _batalkan() {
    if (!_sedangLogin) return;

    widget.controller.batalkanMasuk();

    setState(() {
      _dibatalkan = true;
      _sedangLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Pengayaan Fase B'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Login dan Pemulihan Sesi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk untuk menguji penyimpanan dan pemulihan sesi.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi.';
                      }
                      if (!value.contains('@')) {
                        return 'Masukkan email yang valid.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sandiController,
                    obscureText: _menyembunyikanSandi,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      prefixIcon: const Icon(Icons.key_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _menyembunyikanSandi
                            ? 'Tampilkan kata sandi'
                            : 'Sembunyikan kata sandi',
                        onPressed: () {
                          setState(() {
                            _menyembunyikanSandi =
                                !_menyembunyikanSandi;
                          });
                        },
                        icon: Icon(
                          _menyembunyikanSandi
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi wajib diisi.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _masuk(),
                  ),
                  const SizedBox(height: 16),

                  // Tombol login dan batal
                  FilledButton.icon(
                    onPressed: _sedangLogin ? null : _masuk,
                    icon: _sedangLogin
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      _sedangLogin ? 'Memproses...' : 'Masuk',
                    ),
                  ),

                  if (_sedangLogin) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _batalkan,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Batal'),
                    ),
                  ],

                  if (_dibatalkan) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Login dibatalkan.',
                      textAlign: TextAlign.center,
                    ),
                  ],

                  AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, child) {
                      final pesan = widget.controller.pesan;

                      if (pesan == null || _dibatalkan) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          pesan,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Akun demo: student@trpl.test\n'
                    'Kata sandi: belajar123',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
