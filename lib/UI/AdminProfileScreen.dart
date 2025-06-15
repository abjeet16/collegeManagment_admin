import 'package:flutter/material.dart';
import '../helper/api_service.dart';
import '../modules/AdminDetailsResponse.dart';
import '../modules/UserDetailChangeReq.dart';

class AdminProfileScreen extends StatefulWidget {
  final String adminId;

  const AdminProfileScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  AdminDetailResponse? adminDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    final details = await ApiService.getAdminById(widget.adminId);
    setState(() {
      adminDetails = details;
      isLoading = false;
    });
  }

  void showChangeDetailsDialog() {
    final _firstName = TextEditingController(text: adminDetails?.firstName ?? '');
    final _lastName = TextEditingController(text: adminDetails?.lastName ?? '');
    final _email = TextEditingController(text: adminDetails?.email ?? '');
    final _phone = TextEditingController(text: adminDetails?.phone ?? '');
    final _adminPassword = TextEditingController();

    bool obscureAdminPassword = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Change Admin Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField("First Name", _firstName),
                _textField("Last Name", _lastName),
                _textField("Email", _email),
                _textField("Phone", _phone, type: TextInputType.phone),
                _passwordField("Admin Password", _adminPassword, obscureAdminPassword, () {
                  setState(() => obscureAdminPassword = !obscureAdminPassword);
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                Navigator.pop(context);

                UserDetailChangeReq req = UserDetailChangeReq(
                  universityId: widget.adminId,
                  firstName: _firstName.text.trim(),
                  lastName: _lastName.text.trim(),
                  email: _email.text.trim(),
                  phone: int.tryParse(_phone.text.trim()),
                  password: null,
                  adminPassword: _adminPassword.text.trim(),
                );

                final response = await ApiService.changeUserDetails(req);
                await fetchAdminDetails();

                _showResultDialog(response);
              },
            )
          ],
        ),
      ),
    );
  }

  void showChangePasswordDialog() {
    final _newPassword = TextEditingController();
    final _confirmPassword = TextEditingController();
    final _adminPassword = TextEditingController();

    bool obscureNew = true;
    bool obscureConfirm = true;
    bool obscureAdmin = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _passwordField("New Password", _newPassword, obscureNew, () {
                  setState(() => obscureNew = !obscureNew);
                }),
                _passwordField("Confirm Password", _confirmPassword, obscureConfirm, () {
                  setState(() => obscureConfirm = !obscureConfirm);
                }),
                _passwordField("Admin Password", _adminPassword, obscureAdmin, () {
                  setState(() => obscureAdmin = !obscureAdmin);
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              child: Text("Change"),
              onPressed: () async {
                if (_newPassword.text.trim() != _confirmPassword.text.trim()) {
                  Navigator.pop(context);
                  _showErrorDialog("Passwords do not match");
                  return;
                }

                Navigator.pop(context);

                UserDetailChangeReq req = UserDetailChangeReq(
                  universityId: widget.adminId,
                  password: _newPassword.text.trim(),
                  adminPassword: _adminPassword.text.trim(),
                );

                final response = await ApiService.changeUserDetails(req);
                _showResultDialog(response);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(response.containsKey('statusCode') ? "Error" : "Success"),
        content: Text(response['message'] ?? "No response"),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Validation Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller,
      bool obscure, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Edit Details',
            onPressed: showChangeDetailsDialog,
          ),
          IconButton(
            icon: Icon(Icons.lock_reset),
            tooltip: 'Change Password',
            onPressed: showChangePasswordDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : adminDetails == null
          ? Center(child: Text("Failed to load admin details"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                  ),
                ),
                SizedBox(height: 20),
                _infoTile(Icons.person, "Admin ID", adminDetails!.adminId),
                _infoTile(Icons.badge, "First Name", adminDetails!.firstName),
                _infoTile(Icons.badge_outlined, "Last Name", adminDetails!.lastName),
                _infoTile(Icons.email, "Email", adminDetails!.email),
                _infoTile(Icons.phone, "Phone", adminDetails!.phone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




