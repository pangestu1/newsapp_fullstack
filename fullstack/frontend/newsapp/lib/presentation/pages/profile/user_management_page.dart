// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/presentation/blocs/user/user_event.dart';
import 'package:newsapp/presentation/blocs/user/user_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/role_badge.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    context.read<UserBloc>().add(LoadUsersEvent());
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (query.isEmpty) {
      context.read<UserBloc>().add(LoadUsersEvent());
    } else {
      context.read<UserBloc>().add(SearchUsersEvent(query: query));
    }
  }

  void _showRoleUpdateDialog(User user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ubah Role Pengguna'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah role untuk ${user.name}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih role baru:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...['pembaca', 'penulis', 'admin'].map((role) {
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        RoleBadge(role: role, small: true),
                        const SizedBox(width: 8),
                        Text(role),
                      ],
                    ),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateUserRole(user.id, selectedRole);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updateUserRole(int userId, String newRole) {
    context.read<UserBloc>().add(
          UpdateUserRoleEvent(userId: userId, newRole: newRole),
        );
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserDetailItem('Nama', user.name),
              _buildUserDetailItem('Email', user.email),
              _buildUserDetailItem('Role', user.role,
                  valueWidget: RoleBadge(role: user.role)),
              if (user.createdAt != null)
                _buildUserDetailItem(
                  'Bergabung',
                  '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRoleUpdateDialog(user);
            },
            child: const Text('Ubah Role'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailItem(String label, String value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          valueWidget ?? Text(value),
        ],
      ),
    );
  }

  List<User> _filterUsers(List<User> users) {
    var filteredUsers = users;

    // Filter berdasarkan role
    if (_selectedFilter != 'semua') {
      filteredUsers =
          filteredUsers.where((user) => user.role == _selectedFilter).toList();
    }

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers
          .where((user) =>
              user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),
          const SizedBox(height: 8),

          // Users List
          Expanded(
            child: BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {
                if (state is UserOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is UserLoaded) {
                  final filteredUsers = _filterUsers(state.users);

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Tidak ada pengguna ditemukan'),
                          if (_searchQuery.isNotEmpty || _selectedFilter != 'semua')
                            Text(
                              'Dengan filter: ${_searchQuery.isNotEmpty ? _searchQuery : _selectedFilter}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedFilter = 'semua';
                                _searchController.clear();
                              });
                              _loadUsers();
                            },
                            child: const Text('Reset Filter'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengguna...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        _loadUsers();
                      },
                    )
                  : null,
            ),
            onChanged: _onSearch,
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', 'semua'),
                _buildFilterChip('Admin', 'admin'),
                _buildFilterChip('Penulis', 'penulis'),
                _buildFilterChip('Pembaca', 'pembaca'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserColor(user.role),
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            RoleBadge(role: user.role, small: true),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'details') {
              _showUserDetails(user);
            } else if (value == 'change_role') {
              _showRoleUpdateDialog(user);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info, size: 18),
                  SizedBox(width: 8),
                  Text('Detail'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, size: 18),
                  SizedBox(width: 8),
                  Text('Ubah Role'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  Color _getUserColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'penulis':
        return Colors.blue;
      case 'pembaca':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}