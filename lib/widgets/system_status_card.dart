import 'package:flutter/material.dart';

class SystemStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const SystemStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    active
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),

                child: Icon(
                  icon,
                  color:
                      active
                          ? Colors.green
                          : Colors.red,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color:
                      active
                          ? Colors.green
                          : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}