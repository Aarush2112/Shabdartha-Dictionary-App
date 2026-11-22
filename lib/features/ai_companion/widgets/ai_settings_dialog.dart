import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/ai_service.dart';
import '../../../services/storage_service.dart';

class AiSettingsDialog extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onSaved;

  const AiSettingsDialog({
    super.key,
    required this.storageService,
    required this.onSaved,
  });

  @override
  State<AiSettingsDialog> createState() => _AiSettingsDialogState();
}

class _AiSettingsDialogState extends State<AiSettingsDialog> {
  late TextEditingController _apiKeyController;
  late String _selectedModel;
  bool _obscureKey = true;
  bool _isTesting = false;
  String? _testStatusMessage;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.storageService.getAiApiKey() ?? '');
    _selectedModel = widget.storageService.getAiModel();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final key = _apiKeyController.text.trim();
    setState(() {
      _isTesting = true;
      _testStatusMessage = null;
    });

    try {
      final AiService service;
      if (key.isEmpty) {
        service = GarudaDemoAiService();
      } else {
        service = GoogleGeminiAiService(apiKey: key, model: _selectedModel);
      }

      final result = await service.testConnection();
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = true;
          _testStatusMessage = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _testStatusMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _save() async {
    final key = _apiKeyController.text.trim();
    await widget.storageService.setAiApiKey(key.isEmpty ? null : key);
    await widget.storageService.setAiModel(_selectedModel);
    widget.onSaved();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(key.isEmpty
              ? 'Switched to Garuda Linguistic Engine (Demo Mode).'
              : 'Configured Google Gemini API Key successfully.'),
          backgroundColor: AppColors.deepInk,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 20, color: AppColors.terracotta),
          const SizedBox(width: 8),
          Text(
            'Ask Garuda Configuration',
            style: AppTypography.serifHeading(fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Garuda Lexicon provides a built-in scholarly linguistic engine (Demo Mode) with authentic responses. For live unbounded generation, enter your Google Gemini API key below.',
              style: AppTypography.sansBody(fontSize: 13, color: AppColors.warmGray, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              'GOOGLE GEMINI API KEY',
              style: AppTypography.sansLabel(fontSize: 11, color: AppColors.deepInk),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              style: AppTypography.sansBody(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'AIzaSy... (leave blank for Demo Engine)',
                hintStyle: AppTypography.sansBody(fontSize: 12, color: AppColors.warmGray),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppColors.warmGray,
                  ),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'MODEL SELECTION',
              style: AppTypography.sansLabel(fontSize: 11, color: AppColors.deepInk),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedModel,
              dropdownColor: AppColors.surface,
              style: AppTypography.sansBody(fontSize: 13, color: AppColors.deepInk),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('Gemini 1.5 Flash (Fast & Balanced)')),
                DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('Gemini 1.5 Pro (Deep Reasoning)')),
                DropdownMenuItem(value: 'gemini-2.0-flash', child: Text('Gemini 2.0 Flash')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedModel = val);
              },
            ),
            const SizedBox(height: 12),
            // Test Connection Button & Status View
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      : const Icon(Icons.network_check_rounded, size: 15),
                  label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.terracotta,
                    side: const BorderSide(color: AppColors.terracottaBorder),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            if (_testStatusMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _testSuccess ? AppColors.sageGreenSurface : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _testSuccess ? AppColors.sageGreenBorder : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      size: 15,
                      color: _testSuccess ? AppColors.sageGreen : Colors.red.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _testStatusMessage!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _testSuccess ? AppColors.sageGreen : Colors.red.shade800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSand,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.sageGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keys are stored strictly in local device preferences and never committed to repository or sent to telemetry.',
                      style: AppTypography.sansBody(fontSize: 11.5, color: AppColors.warmGray),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTypography.sansLabel(fontSize: 12, color: AppColors.warmGray)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracotta,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Save Configuration', style: AppTypography.sansLabel(fontSize: 12, color: Colors.white)),
        ),
      ],
    );
  }
}
