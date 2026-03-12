import 'package:flutter/material.dart';

class CreatePoolScreen extends StatefulWidget {
  @override
  State<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends State<CreatePoolScreen> {

  final nameController = TextEditingController();
  final targetController = TextEditingController();
  final membersController = TextEditingController();
  final searchController = TextEditingController();

  bool showSearch = false;

  List<String> allUsers = [
    "Rahul",
    "Arun",
    "Vikram",
    "Karthik",
    "Ajay"
  ];

  List<String> filteredUsers = [];
  List<String> selectedMembers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = allUsers;
  }

  void searchUsers(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((u) => u.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addMember(String name) {
    if (!selectedMembers.contains(name)) {
      setState(() {
        selectedMembers.add(name);
      });
    }
  }

  void removeMember(String name) {
    setState(() {
      selectedMembers.remove(name);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Pool"),
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Pool Name",
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Amount",
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: membersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Total Members",
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    showSearch = !showSearch;
                  });
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Add Members"),
              ),

              const SizedBox(height: 15),

              if (showSearch)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: "Search Members",
                      ),
                      onChanged: searchUsers,
                    ),

                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {

                        String user = filteredUsers[index];

                        return ListTile(
                          title: Text(user),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              addMember(user);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              if (selectedMembers.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Selected Members",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: selectedMembers.map((member) {

                        return Chip(
                          label: Text(member),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            removeMember(member);
                          },
                        );

                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {

                    if (nameController.text.isEmpty ||
                        targetController.text.isEmpty) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                        ),
                      );

                      return;
                    }

                    Map<String, dynamic> newPool = {
                      "name": nameController.text,
                      "collected": 0,
                      "target": int.parse(targetController.text)
                    };

                    Navigator.pop(context, newPool);
                  },

                  child: const Text("Create Pool"),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}