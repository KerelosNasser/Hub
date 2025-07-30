import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';

class SyncBackupWidget extends StatelessWidget {
  final NoteController noteController;

  const SyncBackupWidget({
    super.key,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with connection status
          Row(
            children: [
              Icon(
                Icons.cloud,
                color: Colors.pink.shade700,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Cloud Sync & Backup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                ),
              ),
              Spacer(),
              Obx(() => _buildConnectionIndicator()),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Sync Status
          Obx(() => _buildSyncStatus()),
          
          SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                  onPressed: noteController.isSyncing.value 
                      ? null 
                      : () => noteController.syncAllToCloud(),
                  icon: noteController.isSyncing.value 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.cloud_upload),
                  label: Text(noteController.isSyncing.value ? 'Syncing...' : 'Sync to Cloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                )),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                  onPressed: noteController.isSyncing.value 
                      ? null 
                      : () => _showBackupOptions(context),
                  icon: Icon(Icons.backup),
                  label: Text('Backup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                )),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Restore button
          SizedBox(
            width: double.infinity,
            child: Obx(() => OutlinedButton.icon(
              onPressed: noteController.isSyncing.value || !noteController.isOnline.value
                  ? null 
                  : () => _showRestoreConfirmation(context),
              icon: Icon(Icons.cloud_download),
              label: Text('Restore from Cloud'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.pink.shade600),
                foregroundColor: Colors.pink.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: noteController.isOnline.value ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            noteController.isOnline.value ? 'Online' : 'Offline',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildStatusChip('Total', noteController.totalNotes.toString(), Colors.blue),
              SizedBox(width: 8),
              _buildStatusChip('Synced', noteController.syncedNotes.toString(), Colors.green),
              SizedBox(width: 8),
              if (noteController.pendingNotes > 0)
                _buildStatusChip('Pending', noteController.pendingNotes.toString(), Colors.orange),
              if (noteController.failedNotes > 0) ...[
                SizedBox(width: 8),
                _buildStatusChip('Failed', noteController.failedNotes.toString(), Colors.red),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            noteController.syncStatusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }

  void _showBackupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.file_download, color: Colors.pink.shade600),
              title: Text('Export Local Backup'),
              subtitle: Text('Create a local backup file'),
              onTap: () {
                Navigator.pop(context);
                noteController.exportBackup();
              },
            ),
            
            ListTile(
              leading: Icon(Icons.cloud_upload, color: Colors.blue.shade600),
              title: Text('Sync to Cloud'),
              subtitle: Text('Upload all notes to cloud storage'),
              onTap: () {
                Navigator.pop(context);
                noteController.syncAllToCloud();
              },
            ),
            
            ListTile(
              leading: Icon(Icons.refresh, color: Colors.green.shade600),
              title: Text('Check Connection'),
              subtitle: Text('Test cloud connection'),
              onTap: () {
                Navigator.pop(context);
                noteController.checkConnectionStatus();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Restore from Cloud?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will download all notes from the cloud and merge them with your local notes.',
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Existing notes will not be deleted, but duplicates may be created.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              noteController.restoreFromCloud();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Restore'),
          ),
        ],
      ),
    );
  }
}