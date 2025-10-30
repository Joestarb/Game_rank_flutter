import 'package:flutter/material.dart';

import '../login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF0055), width: 3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF0055).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: const Color(0xFFFF0055),
              ),
              const SizedBox(height: 16),
              Text(
                '¿CERRAR SESIÓN?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF0055),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '¿Estás seguro de que quieres salir del sistema de validación?',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFFE0E0E0),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF00F0FF),
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
                            color: const Color(0xFF00F0FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF0055),
                            const Color(0xFFFF0055).withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF0055).withOpacity(0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'SALIR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFF39FF14), width: 2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF39FF14),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF14).withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: const Color(0xFF39FF14),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'VALIDADOR',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF39FF14),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIVEL: EXPERTO',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF00F0FF),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección perfil
                _buildSectionTitle('PERFIL', Icons.account_circle),
                const SizedBox(height: 12),
                _buildSettingCard(
                  context,
                  'Mi Cuenta',
                  'Gestiona tu información personal',
                  Icons.person,
                  const Color(0xFF00F0FF),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo cuenta')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  'Estadísticas',
                  'Revisa tu desempeño como validador',
                  Icons.bar_chart,
                  const Color(0xFF00F0FF),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo estadísticas')),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Sección configuración
                _buildSectionTitle('CONFIGURACIÓN', Icons.settings),
                const SizedBox(height: 12),
                _buildSettingCard(
                  context,
                  'Notificaciones',
                  'Configura alertas del evento',
                  Icons.notifications,
                  const Color(0xFFFF00FF),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo notificaciones')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  'Tema',
                  'Personaliza la apariencia',
                  Icons.palette,
                  const Color(0xFFFF00FF),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo tema')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  'Privacidad',
                  'Gestiona tu privacidad y seguridad',
                  Icons.security,
                  const Color(0xFFFF00FF),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo privacidad')),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Sección soporte
                _buildSectionTitle('SOPORTE', Icons.help),
                const SizedBox(height: 12),
                _buildSettingCard(
                  context,
                  'Ayuda',
                  'Encuentra respuestas a tus dudas',
                  Icons.help_outline,
                  const Color(0xFFFFFF00),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo ayuda')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  'Acerca de',
                  'Versión 1.0.0 - Game Validator 2025',
                  Icons.info,
                  const Color(0xFFFFFF00),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo acerca de')),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Botón de cerrar sesión
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF0055),
                        const Color(0xFFFF0055).withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF0055).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout, size: 24),
                    label: Text(
                      'CERRAR SESIÓN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '© 2025 GAME VALIDATOR EVENT',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF607D8B),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00F0FF), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00F0FF),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF607D8B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
