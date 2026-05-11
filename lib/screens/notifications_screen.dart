import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart'
    as timeago;

import '../providers/notification_provider.dart';
 

class NotificationsScreen
    extends StatelessWidget {
  const NotificationsScreen({
    super.key,
  });

  Color _getColor(String type) {
    switch (type) {
      case 'emergency':
        return Colors.red;

      case 'zone':
        return Colors.orange;

      case 'fall':
        return Colors.amber;

      case 'safe':
        return Colors.green;

      default:
        return Colors.blueGrey;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'emergency':
        return Icons.warning;

      case 'zone':
        return Icons.location_on;

      case 'fall':
        return Icons.personal_injury;

      case 'safe':
        return Icons.check_circle;

      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<NotificationProvider>(
      context,
    );

    final notifications =
        provider.allNotifications;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Alert Center'),
      ),

      body: Column(
        children: [
          // =========================
          // FILTERS
          // =========================

          SizedBox(
            height: 60,

            child: ListView(
              scrollDirection:
                  Axis.horizontal,

              padding:
                  const EdgeInsets.all(12),

              children: [
                _filterChip(
                  context,
                  'all',
                  'All',
                ),

                _filterChip(
                  context,
                  'emergency',
                  'Emergency',
                ),

                _filterChip(
                  context,
                  'fall',
                  'Fall',
                ),

                _filterChip(
                  context,
                  'zone',
                  'Zone',
                ),

                _filterChip(
                  context,
                  'safe',
                  'Safe',
                ),
              ],
            ),
          ),

          Expanded(
            child:
                notifications.isEmpty
                    ? const Center(
                      child: Text(
                        'No alerts yet',
                      ),
                    )
                    : ListView.builder(
                      itemCount:
                          notifications.length,

                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final notification =
                            notifications[index];

                        return Dismissible(
                          key: Key(
                            notification.id,
                          ),

                          onDismissed: (_) {
                            provider
                                .deleteNotification(
                                  notification.id,
                                );
                          },

                          background:
                              Container(
                                color:
                                    Colors.red,

                                alignment:
                                    Alignment
                                        .centerRight,

                                padding:
                                    const EdgeInsets.only(
                                      right:
                                          20,
                                    ),

                                child: const Icon(
                                  Icons.delete,
                                  color:
                                      Colors
                                          .white,
                                ),
                              ),

                          child: Card(
                            elevation:
                                notification
                                        .isRead
                                    ? 1
                                    : 4,

                            margin:
                                const EdgeInsets.symmetric(
                                  horizontal:
                                      12,
                                  vertical: 6,
                                ),

                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color:
                                    _getColor(
                                      notification
                                          .type,
                                    ),

                                width: 2,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                            ),

                            child: ListTile(
                              onTap: () {
                                provider
                                    .markAsRead(
                                      notification
                                          .id,
                                    );
                              },

                              leading: CircleAvatar(
                                backgroundColor:
                                    _getColor(
                                      notification
                                          .type,
                                    ),

                                child: Icon(
                                  _getIcon(
                                    notification
                                        .type,
                                  ),

                                  color:
                                      Colors
                                          .white,
                                ),
                              ),

                              title: Text(
                                notification
                                    .title,

                                style: TextStyle(
                                  fontWeight:
                                      notification
                                              .isRead
                                          ? FontWeight
                                              .normal
                                          : FontWeight
                                              .bold,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    notification
                                        .body,
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    timeago.format(
                                      notification
                                          .time,
                                    ),

                                    style:
                                        const TextStyle(
                                          fontSize:
                                              12,
                                          color:
                                              Colors
                                                  .grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String value,
    String label,
  ) {
    final provider =
        Provider.of<NotificationProvider>(
      context,
    );

    final isSelected =
        provider.selectedFilter ==
        value;

    return Padding(
      padding:
          const EdgeInsets.only(
            right: 8,
          ),

      child: ChoiceChip(
        label: Text(label),

        selected: isSelected,

        onSelected: (_) {
          provider.setFilter(value);
        },
      ),
    );
  }
}