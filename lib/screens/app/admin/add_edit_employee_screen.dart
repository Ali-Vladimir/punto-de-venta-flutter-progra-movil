import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../models/employee_dto.dart';
import '../../../services/employee_service.dart';
import '../../../services/auth_service.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final EmployeeDTO? employee;

  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;

  String _selectedPosition = 'Cajero';
  String? _selectedDepartment;
  DateTime _hireDate = DateTime.now();
  bool _isActive = true;
  bool _isLoading = false;
  XFile? _selectedImage;
  String? _photoURL;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Colores del tema
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF00BFA5);

  final List<String> _positions = [
    'Cajero',
    'Vendedor',
    'Gerente',
    'Supervisor',
    'Almacenista',
    'Contador',
    'Asistente',
    'Repartidor',
  ];

  final List<String> _departments = [
    'Ventas',
    'Almacén',
    'Administración',
    'Contabilidad',
    'Logística',
    'Recursos Humanos',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();

    _displayNameController =
        TextEditingController(text: widget.employee?.displayName ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phone ?? '');
    _salaryController = TextEditingController(
        text: widget.employee?.salary.toString() ?? '');
    _addressController =
        TextEditingController(text: widget.employee?.address ?? '');
    _emergencyContactController =
        TextEditingController(text: widget.employee?.emergencyContact ?? '');
    _emergencyPhoneController =
        TextEditingController(text: widget.employee?.emergencyPhone ?? '');

    if (widget.employee != null) {
      _selectedPosition = widget.employee!.position;
      _selectedDepartment = widget.employee!.department;
      _hireDate = widget.employee!.hireDate;
      _isActive = widget.employee!.isActive;
      _photoURL = widget.employee!.photoURL;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectHireDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _hireDate) {
      setState(() {
        _hireDate = picked;
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final companyId = _authService.currentCompanyId;
      if (companyId == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar la información de la compañía. Intenta cerrar sesión y volver a iniciar.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // TODO: En una implementación real, aquí subirías la imagen a Firebase Storage
      // y obtendrías la URL. Por ahora, usamos la URL existente o null.
      String? imageUrl = _photoURL;
      if (_selectedImage != null) {
        // Aquí iría la lógica para subir la imagen
        // imageUrl = await _uploadImage(_selectedImage!);
        imageUrl = null; // Por ahora
      }

      final employee = EmployeeDTO(
        employeeId: widget.employee?.employeeId,
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        position: _selectedPosition,
        department: _selectedDepartment,
        salary: double.parse(_salaryController.text.trim()),
        photoURL: imageUrl,
        companyId: companyId,
        isActive: _isActive,
        hireDate: _hireDate,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        createdAt: widget.employee?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.employee == null) {
        // Crear nuevo empleado
        await _employeeService.insert(companyId, employee);
      } else {
        // Actualizar empleado existente
        await _employeeService.update(
            companyId, employee.employeeId!, employee);
      }

      // Animación de éxito
      if (mounted) {
        await _showSuccessAnimation();
      }

      if (!mounted) return;
      
      // Guardar el contexto antes de la operación async
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.employee == null
                ? 'Empleado creado exitosamente'
                : 'Empleado actualizado exitosamente',
          ),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar empleado: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Icon(
                        Icons.check_circle,
                        color: accentColor,
                        size: 80 * value,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  widget.employee == null ? '¡Empleado Creado!' : '¡Empleado Actualizado!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          widget.employee == null ? 'Nuevo Empleado' : 'Editar Empleado',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Foto de perfil
            ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryColor,
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : (_photoURL != null
                                ? NetworkImage(_photoURL!)
                                : null) as ImageProvider?,
                        child: _selectedImage == null && _photoURL == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Información Personal
            _buildSectionTitle('Información Personal'),
            _buildTextField(
              controller: _displayNameController,
              label: 'Nombre Completo',
              icon: Icons.person,
              validator: RequiredValidator(errorText: 'El nombre es requerido'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: MultiValidator([
                RequiredValidator(errorText: 'El email es requerido'),
                EmailValidator(errorText: 'Email inválido'),
              ]),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Teléfono',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Dirección',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Información Laboral
            _buildSectionTitle('Información Laboral'),
            _buildDropdown(
              label: 'Posición',
              icon: Icons.work,
              value: _selectedPosition,
              items: _positions,
              onChanged: (value) {
                setState(() {
                  _selectedPosition = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Departamento',
              icon: Icons.business,
              value: _selectedDepartment,
              items: _departments,
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                });
              },
              allowNull: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _salaryController,
              label: 'Salario',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: MultiValidator([
                RequiredValidator(errorText: 'El salario es requerido'),
                PatternValidator(r'^\d+\.?\d{0,2}$',
                    errorText: 'Ingrese un salario válido'),
              ]),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectHireDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha de Contratación',
                  prefixIcon: const Icon(Icons.calendar_today, color: primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_hireDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contacto de Emergencia
            _buildSectionTitle('Contacto de Emergencia'),
            _buildTextField(
              controller: _emergencyContactController,
              label: 'Nombre de Contacto',
              icon: Icons.contact_emergency,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emergencyPhoneController,
              label: 'Teléfono de Emergencia',
              icon: Icons.phone_in_talk,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Estado
            _buildSectionTitle('Estado'),
            SwitchListTile(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              title: const Text('Empleado Activo'),
              subtitle: Text(_isActive
                  ? 'El empleado está activo en el sistema'
                  : 'El empleado está inactivo'),
              activeColor: accentColor,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 32),

            // Botón Guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEmployee,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.employee == null
                          ? 'Crear Empleado'
                          : 'Actualizar Empleado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool allowNull = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      items: [
        if (allowNull)
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Ninguno'),
          ),
        ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )),
      ],
      onChanged: onChanged,
      validator: allowNull
          ? null
          : (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            },
    );
  }
}
