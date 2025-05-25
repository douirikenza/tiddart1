import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/artisan_management_controller.dart';

class AdminArtisanManagementPage extends StatelessWidget {
  final AdminArtisanController controller = Get.put(AdminArtisanController());

  AdminArtisanManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des artisans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liste des artisans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: controller.artisans.length,
                        itemBuilder: (context, index) {
                          final artisan = controller.artisans[index];
                          final bool isApproved = artisan['isApproved'] ?? false;
                          final bool isSuspended = artisan['isSuspended'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSuspended
                                    ? Colors.red
                                    : isApproved
                                        ? Colors.green
                                        : Colors.orange,
                                child: Icon(
                                  isSuspended
                                      ? Icons.block
                                      : isApproved
                                          ? Icons.check
                                          : Icons.pending,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(artisan['name'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(artisan['email'] ?? ''),
                                  Text(
                                    isSuspended
                                        ? 'Compte suspendu'
                                        : isApproved
                                            ? 'Compte approuvé'
                                            : 'En attente d\'approbation',
                                    style: TextStyle(
                                      color: isSuspended
                                          ? Colors.red
                                          : isApproved
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'approve':
                                      controller.approveArtisan(artisan['id']);
                                      break;
                                    case 'reject':
                                      controller.rejectArtisan(artisan['id']);
                                      break;
                                    case 'suspend':
                                      controller.suspendArtisan(artisan['id']);
                                      break;
                                    case 'unsuspend':
                                      controller.unsuspendArtisan(artisan['id']);
                                      break;
                                  }
                                },
                                itemBuilder: (context) {
                                  if (isSuspended) {
                                    return [
                                      const PopupMenuItem(
                                        value: 'unsuspend',
                                        child: Text('Réactiver le compte'),
                                      ),
                                    ];
                                  } else if (isApproved) {
                                    return [
                                      const PopupMenuItem(
                                        value: 'suspend',
                                        child: Text('Suspendre le compte'),
                                      ),
                                    ];
                                  } else {
                                    return [
                                      const PopupMenuItem(
                                        value: 'approve',
                                        child: Text('Approuver'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'reject',
                                        child: Text('Rejeter'),
                                      ),
                                    ];
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 